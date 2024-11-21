#!/bin/sh
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=24
#SBATCH --mail-type=ALL
#SBATCH --mail-user=patricia.vail@colostate.edu
#SBATCH --error=stderr_filename.txt
#SBATCH --output=test.stdout_filename.txt

DATASET_BASE=M1_1_F7
ADAPT1=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
ADAPT2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
DATA_PATH=~/At_MA_lines
REF_FILE=${DATA_PATH}/ref_genomes/refs_cp28673mod.fas

cutadapt -a $ADAPT1 -A $ADAPT2 -q 20 --minimum-length 50 -e 0.15 -j 24 -o ${DATASET_BASE}_1.trim.fq -p ${DATASET_BASE}_2.trim.fq ${DATA_PATH}/fastqs/${DATASET_BASE}_1.fq.gz ${DATA_PATH}/fastqs/${DATASET_BASE}_2.fq.gz > ${DATASET_BASE}.cutadapt.log.txt
bowtie2-build ${REF_FILE} ${REF_FILE}
bowtie2 --no-unal -p 24 -x ${REF_FILE} -1 ${DATASET_BASE}_1.trim.fq -2 ${DATASET_BASE}_2.trim.fq -S ${DATASET_BASE}.sam > ${DATASET_BASE}.bowtie2.log.txt 2>&1
samtools sort ${DATASET_BASE}.sam > ${DATASET_BASE}.bam
samtools index ${DATASET_BASE}.bam
perbase base-depth --max-depth 1000000 --threads 24 ${DATASET_BASE}.bam > ${DATASET_BASE}.depth.txt

