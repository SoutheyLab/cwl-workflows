#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 5000

baseCommand: [gatk, --java-options, -Xms4000m, BaseRecalibrator]

arguments:
  - prefix: --use-original-qualities
  - prefix: -O
    valueFrom: $(inputs.sorted_bam.nameroot + String(inputs.sequence_grouping[0]).replace(/[:\+]/g, "-") + ".recalreport")

inputs:
  reference:
    type: File
    inputBinding:
      prefix: -R

  sorted_bam:
    type: File
    inputBinding:
      prefix: -I

  sequence_grouping:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -L

  known_sites:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --known-sites

outputs:
  recal_report:
    type: File
    outputBinding:
      glob: $(inputs.sorted_bam.nameroot + String(inputs.sequence_grouping[0]).replace(/[:\+]/g, "-") + ".recalreport")

