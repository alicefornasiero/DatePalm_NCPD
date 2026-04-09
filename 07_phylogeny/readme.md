## Genetic Distance & Phylogeny Pipeline

*07_phylogeny* contains a SLURM-based Bash script for calculating pairwise genetic distance from a VCF file and constructing a consensus Neighbor-Joining (NJ) tree with bootstrap support.

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

* `VCF`: Path to your input multi-sample VCF.
* `OUTDIR`: Directory where output matrices and trees will be saved.
* `VCF2DIS`: Path to the `VCF2Dis` executable.
* `RUNLIST`: Path to your list of bootstrap run IDs.
* `RAND`: The fraction of sites to be randomly sampled for each bootstrap run (e.g., `0.1` for 10%).

### 2. Execution
Run the script as a SLURM job array. The array index must correspond to the number of lines in your `RUNLIST`.

```bash
# Example: Run 100 bootstrap replicates (array 0-99)
sbatch --array=0-99 01_build_NJ_tree.sh
```

## 📉 Workflow Details

### 1. Distance Calculation (VCF2Dis)

- For each job in the array, the VCF2Dis calculates a pairwise genetic distance matrix;
- Sampling: Through the *-Rand* parameter, VCF2Dis performs random sampling, enabling bootstrap analysis across multiple runs;
- Matrices: Outputs a .mat distance matrix for each replicate run.

### 2. Tree Construction (fneighbor)

- *fneighbor*: Builds individual Neighbor-Joining (NJ) trees from the distance matrices;
- Randomization: Uses an automatically generated odd seed to ensure stochasticity across runs.

### 3. Consensus & Bootstrapping (fconsense)

- Individual trees are concatenated;
- *fconsense*: Combines all individual .treefile outputs into a single file and determines the Majority Rule Extended (MRE) consensus tree;
- Support Values: The resulting consensus tree includes bootstrap values representing the frequency of specific clades appearing across the replicates.
