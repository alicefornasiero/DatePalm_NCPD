## Population Structure Analysis (PCA & sNMF)

*05_structure* contains a suite of SLURM-based Bash and R scripts for investigating genetic population structure through Principal Component Analysis (PCA) and Sparse Non-negative Matrix Factorization (sNMF).

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. Ensure the following modules/tools are available (sNMF is installed via **Conda** environment):

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
A text file containing a numeric sequence of run IDs (one per line), for parallele execution of sNMF runs as a job array.

### 4. Sample Labels (`LABEL_FILE`)
A text file containing sample names in the same order as in the VCF file, used to generate admixture barplots.

---

## 🚀 Usage Instructions

### 1. Configuration
Update the following variables in the **Required Parameters** section of the scripts:

**Bash Script (`01_Run_PCA.sh`):**
* `PROJECT_FOLDER`: Path to directory containing input gVCF files.
* `VCF`: vcf input file. It can be gzipped.

**R Script (`02_Plot_PCA.R`):**
* `INDIR`: Path to the input directory containing the eigenvalues and eigenvectors obtained with Plink.
* `INPREFIX`: Prefix name of the .eigenval and .eigenvec input files from Plink.
* `GROUP_FILE`: Tab separated file with two columns: sample name, population (header required).
* `MAX_OVERLAPS`: Numeric value. Exclude text labels when they overlap more than max_overlap text labels or data points. No label printed: 0.

**Bash Script (`03_Run_sNMF.sh`):**
* `VCF`: vcf input file. It can be gzipped.
* `PROJECT_FOLDER`: Path to the project folder.
* `RUNFILE`: Text file containing a numeric sequence (one number per line) corresponding to the runs.
* `NUMK`: Maximum number of Ks.
* `OUTPUT_PREFIX`: Prefix for the output files.

**Bash Script (`04_sNMF_popstprocessing.sh`):**
* `PROJECT_FOLDER`: Path to directory containing input gVCF files.

**R Script (`05_plot_structure.R`):**
* `INDIR`: Path to the input directory containing the Q matrices obtained with sNMF analysis.
* `OUTPREFIX`: Prefix name of the output files.
* `LABEL_FILE`: File containing the sample names used in sNMF (one per line), in the same order.
* `TOT_RUN`: The total number of runs to be plotted.
* `TOT_K`: The total number of Ks to be plotted.

### 2. Execution
Submit the Bash script to the SLURM scheduler:

#### 1. Principal Component Analysis (PCA)
```bash
# 1. Compute PCA with Plink
sbatch 01_run_PCA.sh

# 2. Plot results (Scree plot & PC plots)
Rscript 02_plot_PCA.R
```

#### 2. Ancestry Estimation (sNMF)
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
- *createDataSet*: Masks 5% (default) of genotypes for cross-entropy evaluation at each run;
- *sNMF*: Estimates ancestry coefficients for a range of $K$s (ancestral populations) across multiple independent runs;
- *crossEntropy*: Calculates cross-entropy criterion to evaluate the quality of ancestry estimation. This criterion will help to choose the number of ancestral populations (K) or the best run among a set of runs. A smaller value of the cross-entropy criterion means a better run. The value useful to compare runs is the cross-entropy for the **masked data**.

### 3. Selection & Visualization (04_sNMF_postprocessing.sh & 05_plot_structure.R)
- Cross-entropy evaluation: Parses log files to identify the run and $K$ value with the lowest cross-entropy;
- Cross-Entropy Plot: Visualizes the decay of cross-entropy to determine the optimal $K$;
- Admixture Barplots: Uses *pophelper* to generate barplots with ancestry proportions calculated with sNMF:
    - By K: Compares runs for a specific $K$ value;
    - By Run: Shows transition of structure from $K=2$ to $K_{max}$ for a single run;
    - Summary: Large-scale visualization of all runs and all $K$ values.
