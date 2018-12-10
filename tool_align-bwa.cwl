#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: $(inputs.cores)
    ramMin: 9000

arguments:
  - shellQuote: False
    position: 0
    valueFrom: $("set -o pipefail && bwa mem ")
  - shellQuote: False
    position: 5
    valueFrom: $(" |  samtools view -b -h -o " + inputs.output_name + " - ")

inputs:
  bases_per_batch:
    label: Number of bases to process per batch, regardless of n threads (from Broad)
    type: int
    default: 100000000
    inputBinding:
      position: 1
      prefix: -K

  verbosity:
    label: Verbosity level
    type: int
    default: 3
    inputBinding:
      position: 1
      prefix: -v

  soft_clip_supplementary:
    label: Use soft clipping for supplementary alignments (from Broad)
    type: boolean
    default: true
    inputBinding:
      position: 1
      prefix: -Y

  read_group:
    type: string
    inputBinding:
      position: 1
      prefix: -R

  cores:
    label: Global threadedness setting, used by ResourceRequirements
    type: int
    inputBinding:
      position: 1
      prefix: -t

  reference:
    type: File
    inputBinding:
      position: 2

  forward:
    type: File
    inputBinding:
      position: 3

  reverse:
    type: File
    inputBinding:
      position: 4

  output_name:
    type: string

outputs:
  aligned_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_name)


