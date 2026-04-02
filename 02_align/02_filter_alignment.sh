#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --partition=batch
#SBATCH --job-name filter_align
#SBATCH -o filter_align.%J.out
#SBATCH -e filter_align.%J.err
#SBATCH --time=48:00:00
#SBATCH --mem=20G

# Filter aligned reads

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line
# REFERENCE is the path to the reference genome in fasta format
# JARFILE is the path and file name to the executable .jar file used by Picard's Tools
# MEM_THREADS is the number of threads
# MINQ is the read mapping quality cutoff to filter out aligned reads with low mapping quality

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
JARFILE="ENTER_JAR_PATH_AND_FILE_NAME"
MEM_THREADS=32
MINQ=30
# ----------------------------------------------------------------------- #

# Change to alignment output directory
cd ${PROJECT_FOLDER}/03_alignment

# Load modules
module purge
module load bwa/0.7.17/gnu-12.2.0
module load samtools/1.16.1
module load picard/3.0.0

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Add Read Group
rgid=`samtools view ${ID}.bam | head -n1 | cut -f1 | sed 's/:/./g' |cut -d "." -f1,2,4`;
rgpu=`samtools view ${ID}.bam | head -n1 | cut -f1 | sed 's/:/./g' |cut -d "." -f1,2,3,4`;

java -Xmx10g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} AddOrReplaceReadGroups \
I=${ID}.bam \
O=${ID}_RG.bam \
RGID=${rgid} \
RGLB=${ID}_lib \
RGPL=illumina \
RGPU=${rgpu} \
RGSM=${ID}

# Run Clean Sam
java -Xmx10g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} CleanSam \
INPUT=${ID}_RG.bam \
OUTPUT=${ID}_RG_clean.bam \
VALIDATION_STRINGENCY=STRICT \
TMP_DIR=tmp

# Filter by minimum mapping quality
samtools view -bS -q ${MINQ} -@ ${MEM_THREADS} ${ID}_RG_clean.bam > ${ID}_RG_clean_q${MINQ}.bam

# Verify mate-pair information between mates and fix it if needed
java -Xmx10g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} FixMateInformation \
INPUT=${ID}_RG_clean_q${MINQ}.bam \
OUTPUT=${ID}_RG_clean_q${MINQ}_FM.bam \
SORT_ORDER=coordinate \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=STRICT \
ADD_MATE_CIGAR=True \
TMP_DIR=tmp

# Identify duplicate reads originating from a single fragment of DNA, and remove them
java -Xmx10g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} MarkDuplicatesWithMateCigar \
INPUT=${ID}_RG_clean_q${MINQ}_FM.bam \
OUTPUT=${ID}_RG_clean_q${MINQ}_FM_markdup.bam \
REMOVE_DUPLICATES=True \
CREATE_INDEX=False \
TMP_DIR=tmp \
VALIDATION_STRINGENCY=LENIENT \
METRICS_FILE=aln_stats/${ID}_q${MINQ}_duplicates_metrics.txt \
MINIMUM_DISTANCE=500 \
BLOCK_SIZE=10000000

# Generate index for the filtered bam file
samtools index ${ID}_RG_clean_q${MINQ}_FM_markdup.bam
