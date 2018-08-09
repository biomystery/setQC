#!/usr/bin/env python2
# correct reads_after_dup because of different picard dedup logs

import argparse

def parseArgs():
    '''
    parse arguments 
    '''
    parser = argparse.ArgumentParser(description='correctDup.py: correct number of reads after dedup in libQC')
    parser.add_argument('--libQC_file', help='libQC file')
    parser.add_argument('--prefix', help='Sample prefix name')
    parser.add_argument('--outDir', help='Output dir')    
    args = parser.parse_args()

    return args.taggedFastq, args.prefix, args.outDir


def get_picard_dup_stats(picard_dup_file, paired_status):
    '''
    Parse Picard's MarkDuplicates metrics file
    '''

    mark = 0
    dup_stats = {}

    with open(picard_dup_file) as fp:
        for line in fp:
            if '##' in line:
                if 'METRICS CLASS' in line:
                    mark = 1
                continue

            if mark == 2:
                line_elems = line.strip().split('\t')
                dup_stats['PERCENT_DUPLICATION'] = line_elems[7]
                dup_stats['READ_PAIR_DUPLICATES'] = line_elems[5]
                dup_stats['READ_PAIRS_EXAMINED'] = line_elems[2]
                if paired_status == 'Paired-ended':
                    return 2*int(line_elems[5]), float(line_elems[7])
                else:
                    return int(line_elems[4]), float(line_elems[7])

            if mark > 0:
                mark += 1
    return None
