#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 4000

baseCommand: [gatk, --java-options, -Xms3000m, GatherBQSRReports]

inputs:
  recal_report:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I

  output_report_filename:
    type: string
    inputBinding:
      prefix: -O

outputs:
  merged_recal_report:
    type: File
    outputBinding:
      glob: $(inputs.output_report_filename)
