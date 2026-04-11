## Genetic Distance & Phylogeny Pipeline

*07_phylogeny* contains a SLURM-based Bash script for calculating pairwise genetic distance from a VCF file and constructing a consensus Neighbor-Joining (NJ) tree with bootstrap support, and R script for visualization.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. Ensure the following modules/tools are available (EMBOSS and Embassy toolsuites are installed using **Conda**):

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **VCF2Dis** | 1.50 | [link](https://github.com/BGI-shenzhen/VCF2Dis) |
| **EMBOSS** Conda installation | 6.6.0 | [link](https://anaconda.org/channels/bioconda/packages/emboss/overview) |
| **Embassy** Conda installation | 3.69.650 | [link](https://anaconda.org/channels/bioconda/packages/embassy-phylip/overview) |
| *fneighbor* (Embassy) | 3.69.650 | [link](https://emboss.sourceforge.net/apps/cvs/embassy/phylipnew/fneighbor.html) |
| *fconsense* (Embassy) | 3.69.650 | [link](https://emboss.sourceforge.net/apps/cvs/embassy/phylipnew/fconsense.html) |

---

## 📂 Input Requirements

### 1. Multi-Sample VCF
A filtered **VCF** file obtained via joint genotyping and SNP filtering of the NCPD collection and publicly available *Phoenix* samples (Bioproject: PRJNA495685, PRJNA427409, PRJNA308824, PRJNA495685 - see manuscript for the full list of samples). This file is used for pairwise genetic distance calculation.

### 2. Run List (`RUNLIST`)
A text file containing a numeric sequence (one number per line) for parallel execution of bootstrap replicates as a job array.

---

## 🚀 Usage Instructions

### 1. Configuration
In the script, update the following variables in the **Required Parameters** section:

**Bash Script (`01_build_NJ_tree.sh`):**
* `VCF`: Path to your input multi-sample VCF.
* `OUTDIR`: Directory where output matrices and trees will be saved.
* `VCF2DIS`: Path to the `VCF2Dis` executable.
* `RUNLIST`: Path to your list of bootstrap run IDs.
* `RAND`: The fraction of sites to be randomly sampled for each bootstrap run (e.g., `0.2` for 20%).

**R Script (`02_visualize_tree.R`):**
* `INDIR`: Path to the directory containing the Newick tree.
* `TREE_FILE`: Name of the consensus tree file.
* `GROUP_FILE`: Path to your metadata/group information file.

### 2. Execution
Run the script as a SLURM job array. The array index must correspond to the number of lines in your `RUNLIST`.

```bash
# Example: Run 100 bootstrap replicates (array 0-99)
sbatch --array=0-99 01_build_NJ_tree.sh
```

Then run the R script for visualization.

```bash
Rscript 02_plot_NJ_tree.R
```

## 📉 Workflow Details

### 1. Distance & Tree Construction (Bash/SLURM)

- VCF2Dis: Performs random sampling (-Rand) to generate a pairwise distance matrix (.mat) for each bootstrap replicate.
- *fneighbor*: Constructs individual Neighbor-Joining (NJ) trees from the matrices using randomly generated seeds.
- *fconsense*: Concatenates all replicate trees and determines the Majority Rule Extended (MRE) consensus tree with bootstrap support values. The resulting consensus tree includes bootstrap values representing the frequency of specific clades appearing across the replicates.

### 2. Tree Processing & Rooting (R)

- The tree is rooted using *P. canariensis* as the outgroup.
- Information of species, sample type (female/male) and geographic origin is added to the tree for visualization.
