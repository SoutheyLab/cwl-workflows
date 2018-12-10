#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 5000


# Main command (conda installation has a shell wrapper to pull in java arguments)
baseCommand: [picard, -Xms4000m, MarkDuplicates]

arguments:
  # Defining and adding output names
  - valueFrom: $(inputs.aligned_bam.nameroot + ".marked.bam")
    prefix: OUTPUT=
    separate: false
  - valueFrom: $(inputs.aligned_bam.nameroot + ".markduplicates.metrics")
    prefix: METRICS_FILE=
    separate: false

inputs:
  aligned_bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  validation_stringency:
    type: string
    default: SILENT
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

  optical_duplicate_pixel_distance:
    type: int
    default: 2500
    inputBinding:
      prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
      separate: false

  assume_sort_order:
    type: string
    default: queryname
    inputBinding:
      prefix: ASSUME_SORT_ORDER=
      separate: false

  clear_dt:
    type: string
    default: "false"
    inputBinding:
      prefix: CLEAR_DT=
      separate: false

  add_pg_tag_to_reads:
    type: string
    default: "false"
    inputBinding:
      prefix: ADD_PG_TAG_TO_READS=
      separate: false

outputs:
  marked_bam:
    type: File
    outputBinding:
      glob: $(inputs.aligned_bam.nameroot + ".marked.bam")
  markduplicates_metrics:
    type: File
    outputBinding:
      glob: $(inputs.aligned_bam.nameroot + ".markduplicates.metrics")
