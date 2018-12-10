#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 5000


# Main command (conda installation has a shell wrapper to pull in java arguments)
baseCommand: [picard, -Xms4000m, SortSam]

arguments:
  - valueFrom: $(inputs.input_bam.nameroot + ".sorted.bam")
    prefix: OUTPUT=
    separate: false

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  sort_order:
    type: string
    default: coordinate
    inputBinding:
      prefix: SORT_ORDER=
      separate: false

  create_index:
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  create_md5_file:
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_MD5_FILE=
      separate: false

  max_records_in_ram:
    type: int
    default: 300000
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      separate: false


outputs:
  sorted_bam:
    type: File
    secondaryFiles:
      - ^.bai
      - .md5
    outputBinding:
      glob: $(inputs.input_bam.nameroot + ".sorted.bam")
