#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH -J genomicsdb
#SBATCH -o genomicsdb.%J.out
#SBATCH -e genomicsdb.%J.err
#SBATCH --time=72:00:00
#SBATCH --mem=50G

# Import single-sample GVCFs into GenomicsDB before joint genotyping.

# ----------------------------------------------------------------------- #
# PROJECT_FOLDER is the path to the project folder
# CHRFILE is the path and file name to the list of chromosomes to include in the database, one per line
# COHORT_SAMPLE_MAP is the path to a file containing the list of sample names and gVCF files in tab delimited format
# Example of sample map file:
# sample_1\t/path/to/sample_1.g.vcf.gz
# sample_2\t/path/to/sample_2.g.vcf.gz

PROJECT_FOLDER="ENTER_OUTPUT_DIRECTORY_PATH"
CHRFILE="ENTER_CHR_LIST_FILE_NAME_AND_PATH"
COHORT_SAMPLE_MAP="ENTER_COHORT_MAP_FILE_NAME_AND_PATH"
# ----------------------------------------------------------------------- #

# Load modules
module purge
module load gatk/4.3.0.0

# Create tmp subdirectory and change directory to snp call output directory
mkdir -p ${PROJECT_FOLDER}/04_snpcall/tmp_genomicsdb
cd ${PROJECT_FOLDER}/04_snpcall

# Job array: each job corresponds to a chromosome
IFS=$'\n' read -d '' -r -a lines < ${CHRFILE}
CHR=${lines[${SLURM_ARRAY_TASK_ID}]}

# Run GenomicsDBImport
gatk --java-options "-Xmx32g" GenomicsDBImport \
    --genomicsdb-update-workspace-path my_database_${CHR} \
    --sample-name-map ${COHORT_SAMPLE_MAP} \
    --tmp-dir tmp_genomicsdb \
    --batch-size 50 \
    --reader-threads 8
