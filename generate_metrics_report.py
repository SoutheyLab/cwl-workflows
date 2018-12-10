#!/usr/bin/env python

'''

Takes a list of individual metrics archives as input

Unpacks archives and stores each metrics file by type (using file extenstions as a guide)

Each metrics objects has a series of methods to process and return data from each
type of metrics file

The summary metrics object contains all metrics objects and has similar methods
that instead return aggregate metrics for each file type

Then finally this object is used by... something to generate a viewable, flexible html report

'''


import sys
import os
import tarfile
import pandas as pd
import numpy as np


class SummaryMetrics(object):
    '''
    Contains metrics for all files and has methods to calculate aggregate
    metrics.
    '''
    def __init__(self, individual_metrics):
        self.individual_metrics = metrics


class Metrics(object):
    '''
    Contains metrics for a single file / run
    '''
    def __init__(self, metrics_files):
        self.wgs_metrics = metrics_files[".wgs_metrics"]

    def extract_wgs_metrics(self):
        lines = [l.split('\t') for l in self.wgs_metrics.split('\n')]
        table_hdr_idx = lines.index(["## METRICS CLASS", "picard.analysis.CollectWgsMetrics$WgsMetrics"]) + 1
        histogram_hdr_idx = lines.index(["## HISTOGRAM", "java.lang.Integer"]) + 1

        table = pd.DataFrame(lines[table_hdr_idx + 1:histogram_hdr_idx - 1],
                             columns = lines[table_hdr_idx])
        histogram = pd.DataFrame([l for l in lines[histogram_hdr_idx + 1:] if len(l) != 1],
                                 columns = lines[histogram_hdr_idx])
        return (table, histogram)




def unpack_metrics_archive(archive_path):
    '''
    Unpacks a single metrics archive, storing each file in a dictionary
    keyed by file extension.
    Probably make it a constructor method for the metrics object later.
    '''
    metrics_data = {}
    with tarfile.open(archive_path, 'r') as archive:
        for m in [m for m in archive.getnames() if not m.endswith(".pdf")]:
            with archive.extractfile(m) as f:
                metrics_data[os.path.splitext(m)[1]] = f.read().decode("utf-8")
    return metrics_data



def main():
    metrics_archives = sys.argv[1:]

    if len(metrics_archives) == 0:
        quit("No input files supplied")

    first_metrics = Metrics(unpack_metrics_archive(metrics_archives[0]))
    first_metrics.extract_wgs_metrics()





if __name__ == "__main__":
    main()
