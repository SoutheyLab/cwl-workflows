#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

label: Main workflow to process a directory of fastqs

requirements:
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  SubworkflowFeatureRequirement: {}

#------------------------------------------------------------#
#             Workflow Level Inputs and Outputs
#------------------------------------------------------------#
inputs:
  cores:          int
  scatter_degree: int
  fastq_dir:      Directory
  reference:      File
  bwa_reference:  File
  intervals:      File
  reference_dict: File
  # dbsnp:          File
  known_indels:   File
  mills_indels:   File

outputs:
  gather_recal_bam:
    type: File[]
    outputSource: fastq_to_gvcf/gather_recal_bam
  merged_gvcf:
    type: File[]
    outputSource: fastq_to_gvcf/merged_gvcf
  metrics_archive:
    type: File[]
    outputSource: fastq_to_gvcf/metrics_archive

#------------------------------------------------------------#
#                           Steps
#------------------------------------------------------------#
steps:
  #------------------------------------------------------------#
  #           Step 1 - Pair Fastqs (Expression Tool)
  #------------------------------------------------------------#
  # Pair fastqs for passing to next stage
  # TODO: Modify to use check for compressed fastqs
  pair_fastqs:
    in:
      fastq_dir: fastq_dir
    out: [paired_fastq]
    run: tool_pair-fastqs.cwl

  #------------------------------------------------------------#
  #           Step 2 - Fastqs to gVCFs (Subworkflow)
  #------------------------------------------------------------#
  fastq_to_gvcf:
    in:
      paired_fastq: pair_fastqs/paired_fastq
      reference: reference
      bwa_reference: bwa_reference
      reference_dict: reference_dict
      intervals: intervals
      # dbsnp: dbsnp
      known_indels: known_indels
      mills_indels: mills_indels
      cores: cores
      scatter_degree: scatter_degree
    out: 
      - gather_recal_bam
      - merged_gvcf
      - metrics_archive
    scatter: paired_fastq
    scatterMethod: dotproduct
    run: workflow_fastq-to-gvcf.cwl

