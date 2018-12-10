#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool

inputs:
  gvcf:
    type: File[]
  groupsize: int
outputs:
  gvcf_subgroup:
    type:
      type: array
      items:
        type: array
        items: string

expression: |
  ${
    var subgroups = [];
    var tempgroup = [];
    for (var i = 0; i < inputs.gvcf.length; i++) {
      if (tempgroup.length >= inputs.groupsize) {
        subgroups.push(tempgroup);
        var tempgroup = [];
      }
      tempgroup.push(inputs.gvcf[i]);
    }
    if (tempgroup.length > 0) {
      subgroups.push(tempgroup);
    }
    return {"gvcf_subgroup": subgroups};
  }

