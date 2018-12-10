#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool

inputs:
  fastq_dir:
    type: Directory

outputs:
  paired_fastq:
    type:
      type: array
      items:
        type: record
        fields:
          - name: forward
            type: File
          - name: reverse
            type: File

expression: |
  ${
    // Get fastqs from directory listing
    var fastqs = inputs.fastq_dir.listing.filter(function(f) { return f.basename.endsWith(".fastq.gz"); });

    // Sort fastqs by basename to interleave forward and reverse reads
    fastqs.sort(function(a, b) { return (a.basename > b.basename) ? 1 : ((b.basename > a.basename) ? -1 : 0); });

    var r = {"paired_fastq": []};
    for (var i = 0; i < fastqs.length - 1; i += 2) {
      // Checking forward and reverse fastqs match
      var checking = String(fastqs[i+1].basename).replace(/_R2_/, "_R1_")
      if (String(fastqs[i].basename) != checking) { return "NONSENSE"; }
      r["paired_fastq"].push({
        "forward": fastqs[i],
        "reverse": fastqs[i+1]});
    }
    return r;
  }

