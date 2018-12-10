#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3000

baseCommand: [picard, -Xms2000m, CollectVariantCallingMetrics]

inputs:
  input_gvcf:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  output_prefix:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

  reference_dict:
    type: File
    inputBinding:
      prefix: SEQUENCE_DICTIONARY=
      separate: false

  intervals:
    type: File
    inputBinding:
      prefix: TARGET_INTERVALS=
      separate: false

  dbsnp:
    type: File
    inputBinding:
      prefix: DBSNP=
      separate: false

  gvcf_input:
    type: string
    default: "true"
    inputBinding:
      prefix: GVCF_INPUT=
      separate: false

outputs:
  gvcf_summary_metrics:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".variant_calling_summary_metrics")

  gvcf_detail_metrics:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".variant_calling_detail_metrics")
