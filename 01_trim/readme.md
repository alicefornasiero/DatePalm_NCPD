# Illumina Read Preprocessing Pipeline

01_trim contains a suite of SLURM-based Bash scripts designed for the preprocessing of paired-end Illumina reads. 
The pipeline performs adapter masking, quality trimming, and comprehensive quality control reporting.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using the **SLURM** workload manager. 
Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **Cutadapt** | 4.3 | [Official Docs](https://cutadapt.readthedocs.io/) |
| **Trimmomatic** | 0.39 | [Official Docs](http://www.usadellab.org/cms/?page=trimmomatic) |
| **FastQC** | 0.12.0 | [Official Docs](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) |
| **MultiQC** | 1.14 | [Official Docs](https://multiqc.info/) |

---

## 📂 Input Requirements

### 1. Fastq Files
The scripts expect **Paired-End (PE)** reads in `.fastq.gz` format. 
* Filename convention: `{SAMPLE_ID}_R1.fastq.gz` and `{SAMPLE_ID}_R2.fastq.gz`.

### 2. Sample List
A plain text file containing one sample prefix per line (no file extensions). 
**Example (`samples.txt`):**
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

SAMPLE_LIST: Path to your samples.txt file.
```

### 2. Execution
The scripts use SLURM Job Arrays to process samples in parallel. Launch them sequentially using sbatch.

[!IMPORTANT]
Ensure the --array range matches the number of lines in your samples.txt (starting from index 0). 
For example, if you have 10 samples:
```text
sbatch --array=0-9 /path/to/my_script.sh
```
