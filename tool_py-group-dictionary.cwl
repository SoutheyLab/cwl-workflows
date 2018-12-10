#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

label: Runs a python script to divide contigs in the dictionary into equal groups

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
        cmd += "def process_tsv(tsv_name):\n";
        cmd += "    '''Read dictionary contents and return a sorted list of \n";
        cmd += "    tuples containing: (sequence_name, sequence_length)'''\n";
        cmd += "    def getf(l, n, i): return l.split('\t')[i].lstrip(n)\n";
        cmd += "    with open(tsv_name, 'r') as i:\n";
        cmd += "        return sorted(\n";
        cmd += "            [(getf(l, 'SN:', 1), int(getf(l, 'LN:', 2)))\n";
        cmd += "            for l in i.read().split('\\n') if l.startswith('@SQ')],\n";
        cmd += "            key=lambda x: x[1],\n";
        cmd += "            reverse=True)\n";
        cmd += "\n";
        cmd += "\n";
        cmd += "def group_tuples(seq_tuples, n_groups):\n";
        cmd += "    '''\n";
        cmd += "    Divide a sorted list of tuples into n_groups equal groups.\n";
        cmd += "    NOTE: Sorting every loop iteration isn't a great way to do it.\n";
        cmd += "          But n_groups should always be tiny (relatively) so shouldn't matter.\n";
        cmd += "    '''\n";
        cmd += "    groups = [[[t[0]], t[1]] for t in seq_tuples[:n_groups]]\n";
        cmd += "    rest = seq_tuples[n_groups:]\n";
        cmd += "    for t in rest:\n";
        cmd += "        groups[-1][0].append(t[0])\n";
        cmd += "        groups[-1][1] += t[1]\n";
        cmd += "        groups.sort(key=lambda x: x[1], reverse=True)\n";
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
        cmd += "    return '\\n'.join([ ' '.join(list(map(rlstrip, l[0]))) for l in groups ])\n";
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
