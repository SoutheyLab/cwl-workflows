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

expression: |
  ${
    // Split the dict file and extract groups (each line is a group)
    var lines = inputs.reference_dict.contents.split("\n");
    var groups = [];
    // For each group
    // Tag to stop GATK stripping parts off hg38 contig names
    var hg38_protection_tag = ":1+";
    for (var i = 0; i < lines.length; i++) {
      // Get list of contig names
      var names = lines[i].split(" ");
      // Create list to hold fixed names
      var fixed_names = [];

      // Then for each name
      for (var j = 0; j < names.length; j++) {
        // Fix it!
        var newname = names[j];
        if (names[j].endsWith("_r")) {
          newname += "andom";
        }
        if (names[j].endsWith("_d")) {
          newname += "ecoy";
        }
        if (!names[j].startsWith("HLA")) {
          newname = "chr" + newname;
        }
        newname += hg38_protection_tag;
        // And add to fixed_names
        fixed_names.push(newname);
      }
      // Then push this group of fixed names onto groups
      groups.push(fixed_names);
    }
    var groups_with_unmapped = groups.slice();
    groups_with_unmapped.push(["unmapped"]);
    return {
      "sequence_grouping": groups,
      "sequence_grouping_with_unmapped": groups_with_unmapped
    };
  }
