#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

label: Runs a python script to divide contigs in the dictionary into roughly equal groups

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 500

baseCommand: [python, -c]

arguments:
  - position: 2
    valueFrom: $(inputs.reference_dict.path)
  # Content of a python script to group contigs into n groups
  # Kind of can't believe this works
  # Would be easier with a js string literal but cwl doesn't support ES6
  - position: 1
    valueFrom: |
      ${
        var cmd = "import sys\n";
        cmd += "\n";
        cmd += "\n";
        cmd += "def process_tsv(tsv_name):\n";
        cmd += "    '''Read dictionary contents and return a list of \n";
        cmd += "    tuples containing: (sequence_name, sequence_length)'''\n";
        cmd += "    def getf(l, n, i): return l.split('\t')[i].lstrip(n)\n";
        cmd += "    with open(tsv_name, 'r') as i:\n";
        cmd += "        return [(getf(l, 'SN:', 1), int(getf(l, 'LN:', 2)))\n";
        cmd += "            for l in i.read().split('\\n') if l.startswith('@SQ')]\n";
        cmd += "\n";
        cmd += "\n";
        cmd += "def group_tuples(seq_tuples, n_groups):\n";
        cmd += "    '''\n";
        cmd += "    Divide a sorted list of tuples into roughly n_groups.\n";
        cmd += "    Rough way of doing it. Often more groups than specified and\n";
        cmd += "    size balancing isn't great.\n";
        cmd += "    '''\n";
        cmd += "    totalbases = sum([n[1] for n in seq_tuples])\n";
        cmd += "    group_limit = int(totalbases / n_groups)\n";
        cmd += "    groups = [[]]\n";
        cmd += "    current_total = 0\n";
        cmd += "    for t in seq_tuples:\n";
        cmd += "        if current_total + t[1] < group_limit:\n";
        cmd += "            groups[-1].append(t[0])\n";
        cmd += "            current_total += t[1]\n";
        cmd += "        else:\n";
        cmd += "            groups.append([t[0]])\n";
        cmd += "            current_total = t[1]\n";
        cmd += "    return groups\n";
        cmd += "\n";
        cmd += "\n";
        cmd += "def format_groups(groups):\n";
        cmd += "    # Closure to strip repetitive parts from names to save space\n";
        cmd += "    # TODO: Make regex (r/lstrip match substrings, can lead to extra deletion)\n";
        cmd += "    # Rules for reconstituting contig names\n";
        cmd += "    #   - If it doesn't start with HLA add chr\n";
        cmd += "    #   - if it ends with _r add andom\n";
        cmd += "    #   - if it ends with _d add ecoy\n";
        cmd += "    def rlstrip(s): return s.lstrip('chr').rstrip('andom').rstrip('ecoy')\n";
        cmd += "    return '\\n'.join([ ' '.join(list(map(rlstrip, l))) for l in groups ])\n";
        cmd += "\n";
        cmd += "\n";
        cmd += "def main():\n";
        cmd += "    tsv_name = sys.argv[1]\n";
        cmd += "    n_groups = int(sys.argv[2])\n";
        cmd += "    seq_tuples = process_tsv(tsv_name)\n";
        cmd += "    groups = group_tuples(seq_tuples, n_groups)\n";
        cmd += "    with open('grouped_dictionary.txt', 'w') as o:\n";
        cmd += "        o.write(format_groups(groups))\n";
        cmd += "\n";
        cmd += "main()\n";
        cmd += "\n";
        return cmd;
      }

inputs:
  reference_dict:
    type: File

  scatter_degree:
    type: int
    inputBinding:
      position: 3

outputs:
  grouped_dict:
    type: File
    outputBinding:
      glob: "*.txt"
