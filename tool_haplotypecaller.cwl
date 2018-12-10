#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 9000

baseCommand: [gatk, --java-options, -Xms8000m, HaplotypeCaller]

arguments:
  - prefix: -O
    valueFrom: $(inputs.bam.nameroot + inputs.interval.nameroot + ".g.vcf.gz")

inputs:
  reference:
    type: File
    inputBinding:
      prefix: -R

  bam:
    type: File
    inputBinding:
      prefix: -I

  interval:
    type: File
    inputBinding:
      prefix: -L

  interval_padding:
    type: int
    default: 500
    inputBinding:
      prefix: --interval-padding

  erc:
    type: string
    default: GVCF
    inputBinding:
      prefix: -ERC

  max_alternate_alleles:
    type: int
    default: 3
    inputBinding:
      prefix: --max-alternate-alleles

  # # These options seem to be gone in GATK4
  # variant_index_parameter:
  #   type: int
  #   default: 128000
  #   inputBinding:
  #     prefix: -variant_index_parameter

  # variant_index_type:
  #   type: string
  #   default: LINEAR
  #   inputBinding:
  #     prefix: --variant_index_type

  read_filter:
    type: string
    default: OverclippedReadFilter
    inputBinding:
      prefix: --read-filter

outputs:
  gvcf:
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.bam.nameroot + inputs.interval.nameroot + ".g.vcf.gz")

