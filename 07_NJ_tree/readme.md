## Genetic Distance & Phylogeny Pipeline

*04_phylogeny* contains a SLURM-based Bash script for calculating pairwise genetic distances from VCF files and constructing Neighbor-Joining (NJ) trees with bootstrap support.

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. **Conda** environment installation for EMBOSS and Embassy are required. Ensure the following modules/tools are available:

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
A multi-sample **VCF** file containing the variants for distance calculation.

### 2. Run List (`RUNLIST`)
A plain text file containing a numeric sequence (one number per line). This determines the number of bootstrap replicates (e.g., 1 to 100).

### 3. Sampling Fraction (`RAND`)
A value between 0 and 1 representing the fraction of sites to be randomly sampled with replacement for each bootstrap run.

---

## 🚀 Usage Instructions

### 1. Configuration
In the script, update the following variables in the **Required Parameters** section:

* `VCF`: Path to your input multi-sample VCF.
* `OUTDIR`: Directory where output matrices and trees will be saved.
* `VCF2DIS`: Path to the `VCF2Dis` executable.
* `RUNLIST`: Path to your list of bootstrap run IDs.
* `RAND`: The fraction of sites to sample (e.g., `0.1` for 10%).

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
