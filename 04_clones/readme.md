## Genetic Relatedness & Clone Identification Pipeline

*03_clones* contains a suite of R and SLURM-based scripts for defining genetically identical individuals (clones) using Identity-by-State (IBS) metrics, performing hierarchical clustering, and generating pairwise relationship visualizations.

---

## 🛠 Prerequisites

These scripts require an **R** environment for statistical analysis and an HPC environment using **SLURM** for the heavy computational pairwise comparisons. Ensure the following tools and packages are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **SNPRelate** | 1.32.0 | [link](https://bioconductor.org/packages/release/bioc/vignettes/SNPRelate/inst/doc/SNPRelate.html) |
| **VCFtools** | 0.1.17 | [link](https://vcftools.github.io/index.html) |
| **SNPDuo** | 1.1 | [link](https://github.com/RobersonLab/snpduo) |

---

## 📂 Input Requirements

### 1. Genotype Data
The pipeline accepts data in two formats depending on the script:
* **PLINK Binary Files**: `.bed`, `.fam`, and `.bim` files obtained by converting the filtered vcf file obtained in step 3 for IBS and clustering analysis using SNPRelate.
* **VCF Files**: filtered `.vcf` or `.vcf.gz` file obtained in step 3 for SNPDuo analysis.

### 2. Sample Annotation
A plain text file used to map original sample names to prettier labels for plotting.

**Example** (`sample_order_label.txt`):
```text
orig_name    labels
Sample_001   Variety_A
Sample_002   Variety_B
```

## 🚀 Usage Instructions

### 1. Configuration
In each script, update the following variables in the Input files and variables section:

INDIR / INFILE: Path to input directory and/or input VCF file.

SAMPLE_ANNOT: Text file with sample labels in the original order.

OUTDIR: Path to save results and plots.

SNPDUOPATH: Path to the directory where the snpduo executable is located.

### 2. Execution
Run the scripts sequentially. The SNPDuo analysis is designed for SLURM submission.

```bash
# 1. IBS Clustering and Dendogram Generation (R)
Rscript 01_detect_clones.R

# 2. Pairwise IBS Calculations (SLURM)
sbatch 02_run_SNPDuo.sh

# 3. Visualization of IBS2* Plot (R)
Rscript 03_plot_IBS_stats.R
```

## 📉 Workflow Details

### 1. IBS Clustering (01_detect_clones.R)
Performs Identity-By-State (IBS) analysis to identify clusters of genetically similar individuals.

*snpgdsBED2GDS*: Converts PLINK files to GDS format.

*snpgdsIBS*: Calculate the fraction of identity by state for each pair of samples.

*snpgdsHCluster*: Performs hierarchical clustering useful to determine distinct clades and detect clones.

### 2. Pairwise Statistics (02_run_SNPduo.sh)
A SLURM script that calculates detailed pairwise IBS counts and summary statistics.

Preprocessing: Uses vcftools to convert VCF data into .tped and .tfam formats.

File Cleaning: Uses sed and awk to format chromosome names to strictly numeric values required by SNPDuo.

IBS Metrics: Runs snpduo to generate .count and .summary output files.

### 3. Visualization (03_plot_IBS_stats.R)
Generates high-quality QC plots to visually distinguish clones from unrelated pairs.

IBS2* Ratio: Plots the "Fraction of Informative SNPs" against the "IBS2* ratio".

Clone Highlighting: Highlights clones (red) vs. unknown pairs (grey) based on a IBS threshold of 0.95.

Cutoff: The IBS2* ratio value of 0.70 separates different degrees of relatedness.
