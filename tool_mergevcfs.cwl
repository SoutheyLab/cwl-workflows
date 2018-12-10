#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3000

baseCommand: [picard, -Xms2000m, MergeVcfs]

inputs:
  gvcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false

  output_name:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

outputs:
  merged_gvcf:
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.output_name)
