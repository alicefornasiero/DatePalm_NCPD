## Illumina Read Preprocessing Pipeline

*01_trim* contains a suite of SLURM-based Bash scripts for the preprocessing of paired-end Illumina reads. 
The pipeline performs adapter masking, trimming of masked adapters and low-quality bases, and quality control reporting.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using the **SLURM** workload manager. 
Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **Cutadapt** | 4.3 | [link](https://cutadapt.readthedocs.io/) |
| **Trimmomatic** | 0.39 | [link](http://www.usadellab.org/cms/?page=trimmomatic) |
| **FastQC** | 0.12.0 | [link](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) |
| **MultiQC** | 1.14 | [link](https://github.com/MultiQC/MultiQC) |

---

## 📂 Input Requirements

### 1. Fastq Files
The scripts expect **Paired-End** reads in `.fastq.gz` format. 
* Filename convention: `{SAMPLE_ID}_R1.fastq.gz` and `{SAMPLE_ID}_R2.fastq.gz`.

### 2. Sample List
A plain text file containing one sample prefix per line (no file extensions).

**Example** (`samples.txt`):
```text
SampleA
SampleB
SampleC
```

## 🚀 Usage Instructions

### 1. Configuration
Before launching, you must edit the Required Parameters section inside each .sh script:
```text
FASTQ_FOLDER: Path to your raw input data.

PROJECT_FOLDER: Path where results and subdirectories will be created.

SAMPLE_LIST: Path to your `samples.txt` file.
```

### 2. Execution
The scripts use SLURM Job Arrays to process samples in parallel. Launch them sequentially using sbatch.

#### IMPORTANT!
Ensure the --array range matches the number of lines in your `samples.txt` (starting from index 0).

For example, if you have 10 samples:
```bash
# 1. Adapter Masking (Cutadapt)
sbatch --array=0-9 01_adapter_masking.sh

# 2. Quality Trimming (Trimmomatic)
sbatch --array=0-9 02_read_trimming.sh

# 3. Quality Control (FastQC)
sbatch --array=0-9 03_fastqc_trimmed.sh

# 4. Summary Report (MultiQC) - Run once at the end
sbatch 04_multiqc.sh
```

## 📉 Workflow Details

### 1. Cutadapt (01_adapter_masking.sh)

Masks Illumina TruSeq adapters and filters reads shorter than 50bp. It uses the --action=mask approach to maintain read length while masking adapter sequences.

### 2. Trimmomatic (02_read_trimming.sh)

Performs quality filtering using a sliding window (4bp, average quality > 20) and removes trailing bases below quality 3.

### 3. FastQC (03_fastqc_trimmed.sh)

Generates individual quality reports for each clean sample in the 02_trimming_qc folder.

### 4. MultiQC (04_multiqc.sh)

Aggregates all FastQC results into a single, interactive HTML report found in the project root.
