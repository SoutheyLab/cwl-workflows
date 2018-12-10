#!/bin/bash

# Script to generate a number of fastqs from one via subsampling.
# Uses seqtk and advice from this thread https://www.biostars.org/p/6544/

# Input source fastqs
FASTQ_R1=${1}
FASTQ_R2=${2}
# Number of fastqs to generate
N_FASTQS=20
N_READS=2000

# Chunks for valid name generation
# NOTE: Names vary by sample only, not ideal
NAMECHUNK1="GEN_FASTQ_1234-12_S"
NAMECHUNK2_R1="_L001_R1_001.fastq"
NAMECHUNK2_R2="_L001_R2_001.fastq"

# NOTE: C-style for loop aren't POSIX. Supported by bash and a few other shells
for ((i=0; i<${N_FASTQS}; i++))
{
    seqtk sample -s${i} ${FASTQ_R1} ${N_READS} > "${NAMECHUNK1}${i}${NAMECHUNK2_R1}"
    seqtk sample -s${i} ${FASTQ_R2} ${N_READS} > "${NAMECHUNK1}${i}${NAMECHUNK2_R2}"
}

