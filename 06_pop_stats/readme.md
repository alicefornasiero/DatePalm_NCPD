## Heterozygosity Analysis

This directory contains a SLURM-based Bash script and an R visualization script for calculating genome-wide heterozygosity using **clam**.

---

## 🛠 Prerequisites

The pipeline is designed for HPC environments using **SLURM**. Clam installation is managed via **Conda**.

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **clam** | 1.1.3 | [link](https://github.com/cademirch/clam) |

---

## 📂 Input Requirements

### 1. Per-sample gVCF files
Per-sample `.g.vcf.gz` files used by `clam collect` to build a Zarr store of depth values across the genome.

### 2. Multi-sample VCF file
A filtered multi-sample **VCF** file containing high-quality SNPs used by `clam stat` for the calculation of heterozygosity.

### 3. Chromosome file
A text file containing a comma-separated list of chromosomes or scaffolds to be **excluded** from the analysis (`ChrM`, `ChrC`, `SDR`).

### 4. Population file
A tab-separated file with two columns (`sample`, `population`). This is required by the R script to color-code and group the heterozygosity boxplots.

---

## 🚀 Usage Instructions

### 1. Configuration
Update the following variables in the **Required Parameters** section of the scripts:

**Bash Script (`01_run_clam_per_sample_stats.sh`):**
* `PROJECT_FOLDER`: Path to directory containing input gVCF files.
* `MIN_MEAN_DP` / `MAX_MEAN_DP`: Mean read depth thresholds for site-level filtering.
* `VCF_FILE`: Path to filtered multi-sample VCF file used as input to calculate heterozygosity.
* `OUTPREFIX`: Prefix name for the output Zarr database.

**R Script (`02_plot_per_sample_het.R`):**
* `INDIR`: Path to the `clam` output directory.
* `POP_FILE`: Path to your sample-to-population metadata file.
* `WIN_SIZE`: The window size used in the `clam` analysis.

### 2. Execution
Submit the Bash script to the SLURM scheduler:

```bash
# Execute the clam pipeline
sbatch 01_run_clam_per_sample_stats.sh

# Once complete, generate the plots
Rscript 02_plot_per_sample_het.R
```

## 📉 Workflow Details

### 1. Depth Collection (`clam collect`)
The pipeline first scans all individual gVCF files to aggregate depth information and genotype quality (GQ) into a high-performance Zarr data store. 
This allows for rapid querying of "callable" regions.

### 2. Loci Filtering (`clam loci`)
Using the depth Zarr store generated in the previous step, `clam loci` identifies callable sites for each sample based on the specified per-site mean depth range and GQ filters. 
This ensures that heterozygosity estimates are not biased by regions with poor sequencing coverage.

### 3. Statistical Calculation (`clam stat`)
The pipeline integrates the callable sites with the genotyped loci in the filtered VCF to calculate Heterozygosity: The proportion of heterozygous sites over total callable sites in the defined window size.

### 4. Visualization (R)
The R script processes the `heterozygosity_sorted.tsv` file to generate a boxplot showing the distribution of heterozygosity for each individual.
