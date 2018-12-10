#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 3000

baseCommand: [picard, -Xms2000m, GatherBamFiles]

inputs:
  recal_bam:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
        position: 4

  create_index:
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false
      position: 1

  create_md5_file:
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_MD5_FILE=
      separate: false
      position: 2

  output_name:
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false
      position: 3

outputs:
  gather_recal_bam:
    type: File
    secondaryFiles:
      - ^.bai
      - .md5
    outputBinding:
      glob: $(inputs.output_name)
