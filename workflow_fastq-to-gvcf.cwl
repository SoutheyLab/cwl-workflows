#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

label: Subworkflow that processes a fastq pair up to gVCF

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}

#------------------------------------------------------------#
#             Workflow Level Inputs and Outputs
#------------------------------------------------------------#
inputs:
  cores:          int
  scatter_degree: int
  paired_fastq:   Any
  reference:      File
  bwa_reference:  File
  intervals:      File
  reference_dict: File
  # dbsnp:          File
  known_indels:   File
  mills_indels:   File

outputs:
  gather_recal_bam:
    type: File
    outputSource: gather_bams/gather_recal_bam
  merged_gvcf:
    type: File
    outputSource: mergevcfs/merged_gvcf
  metrics_archive:
    type: File
    outputSource: archive_metrics/archive

#------------------------------------------------------------#
#                           Steps
#------------------------------------------------------------#
steps:
  #------------------------------------------------------------#
  #                 Step 1 - Align Reads (BWA)
  #------------------------------------------------------------#
  align_reads:
    in:
      reference: bwa_reference
      cores: cores
      output_name:
        source: paired_fastq
        valueFrom: $(String(self.forward.nameroot).replace(/\.fastq/, "") + ".bam")
      forward:
        source: paired_fastq
        valueFrom: $(self.forward)
      reverse:
        source: paired_fastq
        valueFrom: $(self.reverse)
      read_group:
        source: paired_fastq
        valueFrom: |
          ${
            var id = String(self.forward.nameroot).replace(/(.+)_R1_001/, "$1");
            var sample = String(self.forward.nameroot).replace(/(.+)_L001_R1_001/, "$1");
            console.log(sample);
            return "@RG\\tID:" + id +  "\\tSM:" + sample +  "\\tPU:lib1\\tPL:Illumina";
          }
    out: [aligned_bam]
    run: tool_align-bwa.cwl
  #----------------------------------------#
  #    Step 1a - Quality Yield Metrics
  #----------------------------------------#
  collect_quality_yield_metrics:
    in:
      input_bam: align_reads/aligned_bam
      output_name:
        source: align_reads/aligned_bam
        valueFrom: $(self.basename + ".quality_yield_metrics")
    out: [quality_yield_metrics]
    run: tool_collect-quality-yield-metrics.cwl
  #----------------------------------------#
  #    Step 1b - Unsorted Bam Metrics
  #----------------------------------------#
  collect_unsorted_multiple_metrics:
    in:
      input_bam: align_reads/aligned_bam
      output_prefix:
        source: align_reads/aligned_bam
        valueFrom: $(self.basename)
      assume_sorted: {default: "true"}
      metric_accumulation_level: {default: ["null", "ALL_READS"]}
      program:
        default:
          - "null"
          - "CollectBaseDistributionByCycle"
          - "CollectInsertSizeMetrics"
          - "MeanQualityByCycle"
          - "QualityScoreDistribution"
    out: [multiple_metrics]
    run: tool_collect-multiple-metrics.cwl


  #------------------------------------------------------------#
  #             Step 3 - Mark Duplicates (Picard)
  #------------------------------------------------------------#
  mark_duplicates:
    in:
      aligned_bam: align_reads/aligned_bam
    out: [marked_bam, markduplicates_metrics]
    run: tool_mark-duplicates-picard.cwl

  #------------------------------------------------------------#
  #                 Step 4 - Sort Bam (Picard)
  #------------------------------------------------------------#
  sort_bam:
    in:
      input_bam: mark_duplicates/marked_bam
    out: [sorted_bam]
    run: tool_sort-index-picard.cwl

  #------------------------------------------------------------#
  #         Step 5 - Create Sequence Grouping (Python)
  #------------------------------------------------------------#
  # Creates the groupings and saves to file
  group_dictionary:
    in:
      reference_dict: reference_dict
      scatter_degree: scatter_degree
    out: [grouped_dict]
    run: tool_py-simple-group-dictionary.cwl

  # Reads the groups into the pipeline from the file
  create_sequence_grouping:
    in:
      reference_dict: group_dictionary/grouped_dict
    out: [sequence_grouping, sequence_grouping_with_unmapped]
    run: tool_read-grouped-sequence.cwl

  #------------------------------------------------------------#
  #            Step 6 - Generate BQSR Model (GATK)
  #------------------------------------------------------------#
  generate_bqsr_model:
    in:
      reference: reference
      sorted_bam: sort_bam/sorted_bam
      sequence_grouping: create_sequence_grouping/sequence_grouping
      known_sites:
        - mills_indels
        - known_indels
        # Commented for testing purposes
        # - dbsnp
    out: [recal_report]
    scatter: [sequence_grouping]
    scatterMethod: dotproduct
    run: tool_generate-bqsr-model.cwl
  #----------------------------------------#
  #  Step 6a - Gather BQSR Reports (GATK)
  #----------------------------------------#
  gather_bqsr_reports:
    in:
      recal_report: generate_bqsr_model/recal_report
      output_report_filename:
        source: sort_bam/sorted_bam
        valueFrom: $(self.nameroot + ".merged_recal_report.csv")
    out: [merged_recal_report]
    run: tool_gather-bqsr-reports.cwl

  #------------------------------------------------------------#
  #              Step 7 - Apply BQSR Model (GATK)
  #------------------------------------------------------------#
  apply_bqsr_model:
    in:
      reference: reference
      sorted_bam: sort_bam/sorted_bam
      sequence_grouping: create_sequence_grouping/sequence_grouping
      recal_report: generate_bqsr_model/recal_report
    out: [recal_bam]
    scatter: [sequence_grouping, recal_report]
    scatterMethod: dotproduct
    run: tool_apply-bqsr-model.cwl

  #------------------------------------------------------------#
  #             Step 8 - Gather Bam files (Picard)
  #------------------------------------------------------------#
  gather_bams:
    label: Aggregate scattered recalibrated bam file chunks
    in:
      recal_bam: apply_bqsr_model/recal_bam
      output_name:
        source: sort_bam/sorted_bam
        valueFrom: $(self.nameroot + ".gather.recal.bam")
    out: [gather_recal_bam]
    run: tool_gather-bams.cwl
  #----------------------------------------#
  #      Step 8a - Final Bam Metrics
  #----------------------------------------#
  collect_sorted_multiple_metrics:
    in:
      input_bam: gather_bams/gather_recal_bam
      output_prefix:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.basename)
      reference_sequence: reference
      assume_sorted: {default: "true"}
      metric_accumulation_level: {default: ["null", "READ_GROUP"]}
      program:
        default:
          - "null"
          - "CollectAlignmentSummaryMetrics"
          - "CollectGcBiasMetrics"
    out: [multiple_metrics]
    run: tool_collect-multiple-metrics.cwl
  #----------------------------------------#
  #      Step 8b - Aggregation Metrics
  #----------------------------------------#
  collect_aggregate_multiple_metrics:
    in:
      input_bam: gather_bams/gather_recal_bam
      output_prefix:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.basename)
      reference_sequence: reference
      assume_sorted: {default: "true"}
      metric_accumulation_level: {default: ["null", "SAMPLE", "LIBRARY"]}
      program:
        default:
          - "null"
          - "CollectAlignmentSummaryMetrics"
          - "CollectInsertSizeMetrics"
          - "CollectSequencingArtifactMetrics"
          - "CollectGcBiasMetrics"
          - "QualityScoreDistribution"
          - "CollectAlignmentSummaryMetrics"
          - "CollectGcBiasMetrics"
    out: [multiple_metrics]
    run: tool_collect-multiple-metrics.cwl
  #----------------------------------------#
  #         Step 8c - WGS Metrics
  #----------------------------------------#
  collect_wgs_metrics:
    in:
      input_bam: gather_bams/gather_recal_bam
      output_name:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.basename + ".wgs_metrics")
      reference_sequence: reference
      intervals: intervals
    out: [wgs_metrics]
    run: tool_collect-wgs-metrics.cwl
  #----------------------------------------#
  #       Step 8d - Raw WGS Metrics
  #----------------------------------------#
  collect_raw_wgs_metrics:
    in:
      input_bam: gather_bams/gather_recal_bam
      output_name:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.basename + ".raw_wgs_metrics")
      reference_sequence: reference
      intervals: intervals
    out: [raw_wgs_metrics]
    run: tool_collect-raw-wgs-metrics.cwl

  #------------------------------------------------------------#
  #       Step 9 - Calculate Scatter Intervals (Picard)
  #------------------------------------------------------------#
  calculate_scatter_intervals:
    in:
      input: intervals
      scatter_count: scatter_degree
    out: [subinterval]
    run: tool_calculate-scatter-intervals.cwl

  #------------------------------------------------------------#
  #             Step 10 - HaplotypeCaller (GATK)
  #------------------------------------------------------------#
  haplotypecaller:
    in:
      reference: reference
      bam: gather_bams/gather_recal_bam
      interval: calculate_scatter_intervals/subinterval
      interval_padding:      {default: 500}
      erc:                   {default: GVCF}
      max_alternate_alleles: {default: 3}
      read_filter:           {default: OverclippedReadFilter}
    out: [gvcf]
    scatter: [interval]
    scatterMethod: dotproduct
    run: tool_haplotypecaller.cwl

  #------------------------------------------------------------#
  #                 Step 11 - MergeVcfs (GATK)
  #------------------------------------------------------------#
  mergevcfs:
    in:
      gvcf: haplotypecaller/gvcf
      output_name:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.nameroot + ".merge.g.vcf.gz")
    out: [merged_gvcf]
    run: tool_mergevcfs.cwl
  ##----------------------------------------#
  ##        Step 11a - gVCF Metrics
  ##----------------------------------------#
  #collect_variant_calling_metrics:
  #  in:
  #    input_gvcf: mergevcfs/merged_gvcf
  #    reference_dict: reference_dict
  #    intervals: intervals
  #    dbsnp: dbsnp
  #    output_prefix:
  #      source: mergevcfs/merged_gvcf
  #      valueFrom: $(self.basename)
  #  out: [gvcf_summary_metrics, gvcf_detail_metrics]
  #  run: tool_collect-variant-calling-metrics.cwl


  #------------------------------------------------------------#
  #                 Step 12 - Archive Metrics
  #------------------------------------------------------------#
  archive_metrics:
    in:
      individual_files:
        - collect_quality_yield_metrics/quality_yield_metrics
        - mark_duplicates/markduplicates_metrics
        - gather_bqsr_reports/merged_recal_report
        - collect_wgs_metrics/wgs_metrics
        - collect_raw_wgs_metrics/raw_wgs_metrics
      arrays:
        - collect_unsorted_multiple_metrics/multiple_metrics
        - collect_sorted_multiple_metrics/multiple_metrics
        - collect_aggregate_multiple_metrics/multiple_metrics
      archive_name:
        source: gather_bams/gather_recal_bam
        valueFrom: $(self.nameroot + ".metrics.tar.gz")
    out: [archive]
    run: tool_archive-files.cwl
