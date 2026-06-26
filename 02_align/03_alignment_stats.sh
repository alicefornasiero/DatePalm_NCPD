#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH --job-name stats
#SBATCH -o align_stats.%J.out
#SBATCH -e align_stats.%J.err
#SBATCH --time=20:00:00
#SBATCH --mem=10G

# Generate alignement statistics

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# SAMPLE_LIST is a text file with the list of sample prefix, one per line
# REFERENCE is the path to the reference genome in fasta format
# JARFILE is the path and file name to the executable .jar file used by Picard's Tools
# MEM_THREADS is the number of threads
# MINQ is the read mapping quality cutoff to filter out aligned reads with low mapping quality
# MAXIS is the maximum library insert size in bp
# HISTOGRAM_WIDTH is the maximum histogram width. When calculating mean and standard deviation, only bins <= HISTOGRAM_WIDTH will be included.

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
SAMPLE_LIST="ENTER_FILE_NAME_AND_PATH"
REFERENCE="ENTER_REFERENCE_PATH_AND_FILE_NAME"
JARFILE="ENTER_JAR_PATH_AND_FILE_NAME"
MEM_THREADS=8
MINQ=30
HISTOGRAM_WIDTH=1000
MAXIS=1000
# ----------------------------------------------------------------------- #

# Change to alignment output directory
cd ${PROJECT_FOLDER}/03_alignment

# Load modules
module purge
module load samtools/1.16.1
module load picard/3.0.0
module load deeptools/python2.7/3.3.1

# Generate the array of slurms
IFS=$'\n' read -d '' -r -a lines < ${SAMPLE_LIST}
ID=${lines[${SLURM_ARRAY_TASK_ID}]}

# Flagstat
samtools flagstat ${ID}_RG_clean_q${MINQ}_FM_markdup.bam > aln_stats/${ID}.q${MINQ}.flagsts.txt

# Insert Size
java -Xmx8g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} CollectInsertSizeMetrics \
--INPUT ${ID}_RG_clean_q${MINQ}_FM_markdup.bam \
--OUTPUT aln_stats/${ID}.q${MINQ}.insert_size.txt \
--Histogram_FILE aln_stats/${ID}.q${MINQ}.insert_size.pdf \
--METRIC_ACCUMULATION_LEVEL ALL_READS \
--MINIMUM_PCT 0.5 \
--REFERENCE_SEQUENCE ${REFERENCE} \
--VALIDATION_STRINGENCY STRICT \
--TMP_DIR tmp \
--HISTOGRAM_WIDTH ${HISTOGRAM_WIDTH}

# Alignment Summary Metrics
java -Xmx8g -Djava.io.tmpdir=tmp \
-jar ${JARFILE} CollectAlignmentSummaryMetrics \
INPUT=${ID}_RG_clean_q${MINQ}_FM_markdup.bam \
OUTPUT=aln_stats/${ID}.q${MINQ}.aln_summary.txt \
MAX_INSERT_SIZE=${MAXIS} \
ADAPTER_SEQUENCE=null \
METRIC_ACCUMULATION_LEVEL=ALL_READS \
REFERENCE_SEQUENCE=${REFERENCE} \
VALIDATION_STRINGENCY=STRICT \
TMP_DIR=tmp

# Plot Coverage
plotCoverage --bamfiles ${ID}_RG_clean_q${MINQ}_FM_markdup.bam \
--plotHeight 10.0 \
--labels ${ID} \
--plotFileFormat pdf \
--plotFile aln_stats/${ID}_q${MINQ}_plotCoverage.pdf \
--numberOfProcessors ${MEM_THREADS} \
--outRawCounts aln_stats/${ID}_q${MINQ}_plotCoverageOutRawCounts.txt >> aln_stats/${ID}_q${MINQ}_plotCoverage_stdout.txt
