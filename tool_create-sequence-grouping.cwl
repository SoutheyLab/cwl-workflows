#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool

inputs:
  reference_dict:
    type: File
    inputBinding:
      loadContents: true

outputs:
  sequence_grouping:
    type:
      type: array
      items:
        type: array
        items: string
  sequence_grouping_with_unmapped:
    type:
      type: array
      items:
        type: array
        items: string

# Javascript version of a python script in the identically named step
# in the following GATK wdl workflow:
# - https://github.com/gatk-workflows/broad-prod-wgs-germline-snps-indels/blob/master/PairedEndSingleSampleWf.gatk4.0.wdl#L713
# NOTE:
#   - The loadContents method used to load the dictionary file will only read a maximum of 64KiB (should be plenty in most cases)
expression: |
  ${
    // Split the dict file and extract contig names and lengths
    var lines = inputs.reference_dict.contents.split("\n");
    var sequence_array_list = [];
    var longest_sequence = 0;
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (line.startsWith("@SQ")) {
        var splitline = line.split("\t");
        // [sequence_name, sequence_length]
        sequence_array_list.push([splitline[1].split("SN:")[1], parseInt(splitline[2].split("LN:")[1])]);
      }
    }

    // Sort the sequence pairs by length (reverse) and store the length of the longest
    var sorted = sequence_array_list.slice().sort(function(a, b) { return (a[1] < b[1]) ? 1 : ((b[1] < a[1]) ? -1 : 0); });
    longest_sequence = sorted[0][1];

    // From original:
    // "We are adding this to the grouping because hg38 has contigs named with embedded colons and a bug in GATK strips off
    // the last element after a :, so we add this as a sacrificial element."
    var hg38_protection_tag = ":1+";

    // Create an array (sequence_grouping) containing a number of sub-arrays each of which is a group of contigs.
    var temp_size = sequence_array_list[0][1];
    var sequence_grouping = [];
    sequence_grouping.push([sequence_array_list[0][0] + hg38_protection_tag])
    for (var i = 1; i < sequence_array_list.length; i++) {
      if (temp_size + sequence_array_list[i][1] <= longest_sequence) {
        temp_size += sequence_array_list[i][1];
        sequence_grouping[sequence_grouping.length - 1].push(sequence_array_list[i][0] + hg38_protection_tag);
      } else {
        sequence_grouping.push([sequence_array_list[i][0] + hg38_protection_tag]);
        temp_size = sequence_array_list[i][1]
      }
    }
    // Note using slice to deep copy the array, unsure if this is the best way but it works
    var sequence_grouping_with_unmapped = sequence_grouping.slice();
    sequence_grouping_with_unmapped.push(["unmapped"]);

    return {
      "sequence_grouping": sequence_grouping,
      "sequence_grouping_with_unmapped": sequence_grouping_with_unmapped
    };
  }

