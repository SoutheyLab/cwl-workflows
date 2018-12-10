#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000

baseCommand: [picard, -Xms5000m, CollectMultipleMetrics]

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  output_prefix:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

  assume_sorted:
    type: string
    inputBinding:
      prefix: ASSUME_SORTED=
      separate: false

  program:
    type:
      type: array
      items: string
      inputBinding:
        prefix: PROGRAM=
        separate: false

  metric_accumulation_level:
    type:
      type: array
      items: string
      inputBinding:
        prefix: METRIC_ACCUMULATION_LEVEL=
        separate: false

  reference_sequence:
    type: File?
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      separate: false

outputs:
  multiple_metrics:
    type: File[]
    outputBinding:
      glob: $(inputs.output_prefix + "*")
