#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 1200

baseCommand: [picard, -Xms1000m, IntervalListTools]

arguments:
  - prefix: OUTPUT=
    separate: false
    valueFrom: .
    position: 1
  - shellQuote: false
    position: 2
    valueFrom: |
      ${
        var cmd = " && find . -type f -exec bash -c ";
        cmd += "'x={}; ";
        cmd += "name=${x%/*}.interval_list; ";
        cmd += "name=${name##*/}; ";
        cmd += "cp ${x} ./${name}' \\;";
        return cmd;
      }


inputs:
  scatter_count:
    type: int
    inputBinding:
      prefix: SCATTER_COUNT=
      separate: false
      position: 1

  subdivision_mode:
    type: string
    default: BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW
    inputBinding:
      prefix: SUBDIVISION_MODE=
      separate: false
      position: 1

  unique:
    type: string
    default: "true"
    inputBinding:
      prefix: UNIQUE=
      separate: false
      position: 1

  sort:
    type: string
    default: "true"
    inputBinding:
      prefix: SORT=
      separate: false
      position: 1

  break_bands_at_multiples_of:
    type: int
    default: 1000000
    inputBinding:
      prefix: BREAK_BANDS_AT_MULTIPLES_OF=
      separate: false
      position: 1

  input:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false
      position: 1

outputs:
  subinterval:
    type: File[]
    outputBinding:
      glob: "*.interval_list"
