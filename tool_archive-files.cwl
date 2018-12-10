#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000

baseCommand: [tar, -cvzh]

arguments:
  - position: 1
    # Some Javascript to construct the tar command to cd to the correct directory for each file
    valueFrom: |
      ${
        var all = [];
        for (var i = 0; i < inputs.individual_files.length; i++) {
          all.push("-C")
          all.push(inputs.individual_files[i].dirname)
          all.push(inputs.individual_files[i].basename)
        }
        for (var i = 0; i < inputs.arrays.length; i++) {
          for (var j = 0; j < inputs.arrays[i].length; j++) {
            all.push("-C")
            all.push(inputs.arrays[i][j].dirname)
            all.push(inputs.arrays[i][j].basename)
          }
        }
        return all;
      }

inputs:
  archive_name:
    type: string
    inputBinding:
      prefix: -f
      position: 0

  individual_files:
    type: File[]?

  arrays:
    # Using extended type syntax and "null" to make optional
    # See https://www.biostars.org/p/196091/
    type:
      - "null"
      - type: array
        items:
          type: array
          items: File

outputs:
  archive:
    type: File
    outputBinding:
      glob: $(inputs.archive_name)
