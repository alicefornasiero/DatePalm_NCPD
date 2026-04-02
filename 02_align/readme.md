## Read Alignment & Filtering Pipeline

*02_align* contains a suite of SLURM-based Bash scripts for aligning trimmed paired-end Illumina reads to a reference genome, filtering alignments, and generating mapping statistics.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **BWA** | 0.7.17 | [Official Docs](https://github.com/lh3/bwa) |
| **Samtools** | 1.16.1 | [Official Docs](http://www.htslib.org/doc/samtools.html) |
| **Picard** | 3.0.0 | [Official Docs](https://broadinstitute.github.io/picard/) |
| **deepTools** | 3.3.1 | [Official Docs](https://deeptools.readthedocs.io/) |

---

## 📂 Input Requirements

### 1. Clean Fastq Files
The pipeline expects trimmed reads from the previous preprocessing step, located in `${PROJECT_FOLDER}/01_trim/`.
* Format: `{SAMPLE_ID}_clean_1.fq.gz` and `{SAMPLE_ID}_clean_2.fq.gz`.

### 2. Reference Genome
A high-quality reference genome in **FASTA** format. 

### 3. Sample List
A plain text file containing one sample prefix per line.

**Example** (`samples.txt`):
```text
SampleA
SampleB
SampleC
```
---

## 🚀 Usage Instructions

### 1. Configuration
In each script, update the following variables in the **Required Parameters** section:

* `PROJECT_FOLDER`: Your main project directory.
* `SAMPLE_LIST`: Path to your `samples.txt`.
* `REFERENCE`: Path to your reference genome FASTA file.
* `JARFILE`: Path to your `picard.jar` executable.

### 2. Execution
Run the scripts sequentially. Ensure the `--array` index matches your sample list (e.g., `0-9` for 10 samples).

```bash
# 1. Alignment (BWA mem + Samtools sort)
sbatch --array=0-9 align_script.sh

# 2. Filtering & Deduplication (Picard + Samtools)
# Run after Step 1 completes
sbatch --array=0-9 filter_script.sh

# 3. Alignment Statistics (Picard + deepTools)
# Run after Step 2 completes
sbatch --array=0-9 stats_script.sh
```
