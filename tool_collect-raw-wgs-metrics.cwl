#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3000

baseCommand: [picard, -Xms2000m, CollectRawWgsMetrics]

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  output_name:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

  reference_sequence:
    type: File
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      separate: false

  intervals:
    type: File
    inputBinding:
      prefix: INTERVALS=
      separate: false

  include_bq_histogram:
    type: string
    default: "true"
    inputBinding:
      prefix: INCLUDE_BQ_HISTOGRAM=
      separate: false

  validation_stringency:
    type: string
    default: "SILENT"
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

  use_fast_algorithm:
    type: string
    default: "true"
    inputBinding:
      prefix: USE_FAST_ALGORITHM=
      separate: false

  read_length:
    type: int
    default: 250
    inputBinding:
      prefix: READ_LENGTH=
      separate: false

outputs:
  raw_wgs_metrics:
    type: File
    outputBinding:
      glob: $(inputs.output_name)
