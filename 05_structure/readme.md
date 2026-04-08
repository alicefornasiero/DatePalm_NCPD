## Population Structure Analysis (PCA & sNMF)

*06_structure* contains a suite of SLURM-based Bash and R scripts for investigating genetic population structure through Principal Component Analysis (PCA) and Sparse Non-negative Matrix Factorization (sNMF).

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. **Conda** environment installation for sNMF is required. Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **PLINK2** | 2.0 | [link](https://www.cog-genomics.org/plink/2.0/) |
| **sNMF** | 1.2.0 | [link](http://membres-timc.imag.fr/Olivier.Francois/snmf/index.htm) |
| **sNMF** Installation using Conda | 1.2.0 | [link](https://anaconda.org/channels/bioconda/packages/snmf/overview)
| **pophelper** | 2.3.1 | [link](http://royfrancis.github.io/pophelper/) |
---

## 📂 Input Requirements

### 1. Genotype Data
A filtered **VCF** file obtained in step 3.

### 2. Population Metadata (`GROUP_FILE`)
A tab-separated file used for coloring PCA plots.
* Columns: `sample`, `population` (header required).

### 3. Run Configuration (`RUNFILE`)
For sNMF job arrays, a text file containing a numeric sequence of run IDs (one per line).

### 4. Sample Labels (`LABEL_FILE`)
A text file containing sample names in the same order as in the VCF, used for admixture barplots.

---

## 🚀 Usage Instructions

### 1. Principal Component Analysis (PCA)
```bash
# 1. Compute PCA with Plink
sbatch 01_run_PCA.sh

# 2. Plot results (Scree plot & PC plots)
Rscript 02_plot_PCA.R
```

### 2. Ancestry Estimation (sNMF)
```bash
# 1. Run sNMF iterations (Array index per run)
sbatch --array=0-9 03_run_sNMF.sh

# 2. Extract best K (Lowest Cross-Entropy)
sbatch 04_sNMF_postprocessing.sh

# 3. Plot Admixture & Cross-Entropy
Rscript 05_plot_structure.R
```

## 📉 Workflow Details

### 1. PCA (01_run_PCA.sh & 02_plot_PCA.R)

- *pca biallelic-var-wts*: Computes eigenvectors and eigenvalues;
- Scree Plot: Visualizes the percentage of variance explained (PVE) by the first 10 PCs.
- PC Projections: Generates scatter plots for PC1 vs PC2, PC1 vs PC3, and PC2 vs PC3, colored by population.

### 2. sNMF Population Structure (03_run_sNMF.sh)

- *recode A-transpose*: Converts the vcf file to a .geno format required by sNMF;
- *createDataSet*: Masks 5% of genotypes for cross-entropy evaluation at each run;
- *sNMF*: Estimates ancestry coefficients for a range of $K$ (ancestral populations) across multiple independent runs;
- *crossEntropy*: Calculates cross-entropy criterion to evaluate the quality of ancestry estimation. This criterion will help to choose the number of ancestral populations (K) or the best run
among a set of runs. A smaller value of the cross-entropy criterion means a better run. The value useful to compare runs is the cross-entropy for the **masked data**.

### 3. Selection & Visualization (04_sNMF_postprocessing.sh & 05_plot_structure.R)
- Cross-entropy evaluation: Parses log files to identify the run and $K$ value with the lowest cross-entropy.
- Cross-Entropy Plot: Visualizes the decay of cross-entropy to determine the optimal $K$.
- Admixture Barplots: Uses *pophelper* to generate barplots with ancestry proportions calculated with sNMF:
    - By K: Compares runs for a specific $K$ value;
    - By Run: Shows transition of structure from $K=2$ to $K_{max}$ for a single run;
    - Summary: Large-scale visualization of all runs and all $K$ values.
