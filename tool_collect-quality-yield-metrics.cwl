#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3000

baseCommand: [picard, -Xms2000m, CollectQualityYieldMetrics]

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  oq:
    type: string
    default: "true"
    inputBinding:
      prefix: OQ=
      separate: false

  output_name:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

outputs:
  quality_yield_metrics:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

