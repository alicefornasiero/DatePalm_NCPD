## Read Alignment & Filtering Pipeline

*02_align* contains a suite of SLURM-based Bash scripts for aligning trimmed paired-end Illumina reads to a reference genome, filtering alignments, and generating mapping statistics.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **BWA** | 0.7.17 | [link](https://github.com/lh3/bwa) |
| **Samtools** | 1.16.1 | [link](http://www.htslib.org/doc/samtools.html) |
| **Picard** | 3.0.0 | [link](https://broadinstitute.github.io/picard/) |
| **deepTools** | 3.3.1 | [link](https://deeptools.readthedocs.io/) |

---

## 📂 Input Requirements

### 1. Clean Fastq Files
The pipeline expects trimmed reads from the previous preprocessing step, located in `${PROJECT_FOLDER}/01_trim/`.
* Format: `{SAMPLE_ID}_clean_1.fq.gz` and `{SAMPLE_ID}_clean_2.fq.gz`.

### 2. Reference Genome
A high-quality reference genome in **FASTA** format.

The genome reference used in this work can be found here: [GCA_051530095.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_051530095.1/) 

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

## 📉 Workflow Details

### 1. Alignment (01_align_reads.sh)
Aligns reads using bwa mem. Outputs are automatically piped into samtools sort to produce coordinate-sorted BAM files.

### 2. Filtering (02_filter_alignment.sh)

A multi-step cleanup process to ensure data integrity:

*AddOrReplaceReadGroups*: Assigns all the reads in a file to a single new read-group.

*CleanSam*: Repairs soft-clipping beyond end-of-reference and sets MAPQ to 0 for unmapped reads.

MAPQ Filter: Removes alignments with a mapping quality score lower than 30 (default).

*FixMateInformation*: Synchronizes mate-pair data.

*MarkDuplicatesWithMateCigar*: Identifies and removes PCR/optical duplicates to prevent biased variant calling.

### 3. Statistics & QC (03_alignment_stats.sh)

Generates metrics to evaluate alignment success:

*samtools flagstat*: Quick summary of mapping statistics.

*CollectInsertSizeMetrics*: Distribution of library fragment lengths.

*CollectAlignmentSummaryMetrics*: Standard alignment metrics.

*plotCoverage*: Assessment of sequencing depth and visualization.
