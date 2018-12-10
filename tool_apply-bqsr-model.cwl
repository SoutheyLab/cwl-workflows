#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 4000

baseCommand: [gatk, --java-options, -Xms3000m, ApplyBQSR]

arguments:
  - prefix: --create-output-bam-md5
  - prefix: --add-output-sam-program-record
  - prefix: --use-original-qualities
  - prefix: --static-quantized-quals
    valueFrom: "10"
  - prefix: --static-quantized-quals
    valueFrom: "20"
  - prefix: --static-quantized-quals
    valueFrom: "30"
  - prefix: -O
    valueFrom: $(inputs.sorted_bam.nameroot + String(inputs.sequence_grouping[0]).replace(/[:\+]/g, "X") + ".recal.bam")

inputs:
  reference:
    type: File
    inputBinding:
      prefix: -R

  sorted_bam:
    type: File
    inputBinding:
      prefix: -I

  recal_report:
    type: File
    inputBinding:
      prefix: -bqsr

  sequence_grouping:
    type:
      type: array
      items: string
      inputBinding:
        position: 1
        prefix: -L

outputs:
  recal_bam:
    type: File
    secondaryFiles:
      - ^.bai
      - .md5
    outputBinding:
      glob: $(inputs.sorted_bam.nameroot + String(inputs.sequence_grouping[0]).replace(/[:\+]/g, "X") + ".recal.bam")
