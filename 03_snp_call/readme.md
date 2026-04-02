## SNP Calling & Variant Filtering Pipeline

This repository a suite of SLURM-based Bash scripts for variant discovery and filtering. 

---

## 🛠 Prerequisites

These scripts are designed to run on an HPC environment using **SLURM** workload manager. Ensure the following modules/tools are available:

| Tool | Version | Documentation |
| :--- | :--- | :--- |
| **GATK** | 4.3.0.0 | [link](https://gatk.broadinstitute.org/) |
| **BCFtools** | 1.16 | [link](https://samtools.github.io/bcftools/) |
| **Tabix** | 1.16 | [link](http://www.htslib.org/doc/tabix.html) |
| **PLINK** | 2.0 | [link](https://www.cog-genomics.org/plink/2.0/) |

---

## 📂 Input Requirements

### 1. BAM Files
Processed, deduplicated BAM files from the alignment pipeline (located in `03_alignment/`).

### 2. Reference Genome
A FASTA reference. The pipeline will automatically generate a `.dict` file via `CreateSequenceDictionary` if one is not present.

The genome reference used in this work can be found here: [GCA_051530095.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_051530095.1/) 

### 3. Auxiliary Files
* **Sample List**:
A plain text file containing one sample prefix per line.

**Example** (`samples.txt`):
```text
SampleA
SampleB
SampleC
```
* **Sample Map**:
A tab-delimited file for `GenomicsDBImport`.

**Example** (`cohort_sample_map.txt`):
```text
sample_A\t/path/to/sample_A.g.vcf.gz
sample_B\t/path/to/sample_B.g.vcf.gz
sample_C\t/path/to/sample_C.g.vcf.gz
```
* **Chromosome List:** A text file listing chromosomes (one per line) for parallelizing the database import.
* **Exclude List:** A `.args` file listing sample names to be excluded (for the clone removal step).

---

## 🚀 Usage Instructions

### 1. Configuration
In each script, update the following variables in the **Required Parameters** section:

* `PROJECT_FOLDER`: Your main project directory.
* `REFERENCE`: Path to your reference FASTA.
* `VCF_PREFIX`: The prefix name for the output files.
* `MINDP` / `MAXDP`: Site-level depth thresholds for SNP filtering.

### 2. Execution
Run the scripts sequentially. Ensure the `--array` index matches your sample list (e.g., `0-9` for 10 samples).

```bash
# 1. HaplotypeCaller (Single-sample calling)
sbatch --array=0-9 01_haplotype_caller.sh

# 2. GenomicsDBImport (Consolidate by Chromosome)
sbatch --array=0-9 02_genomicsDBImport.sh

# 3. Joint Genotyping (From here onwards, run only once)
sbatch 03_genotype_GVCF.sh

# 4. Hard Filtering & SDR Handling
sbatch 04_baseline_snp_filter.sh

# 5. Post-Processing (Clones, Private Alleles, Subsetting)
sbatch exclude_clones.sh
sbatch remove_private_alleles.sh
sbatch subset_snps.sh
```

## 📉 Workflow Details

### 1. Variant Discovery

*HaplotypeCaller*: Call germline SNPs and indels via local re-assembly of haplotypes.

*GenomicsDBImport*: Aggregates single-sample GVCFs into a GenomicsDB workspace, parallelized by chromosome to save time.

*GenotypeGVCFs*: Performs the final joint genotyping across the entire cohort.

### 2. Quality Filtering

The pipeline applies GATK Hard-Filtering for SNPs using the following criteria:

  - Quality by Depth (QD): < 2.0
  - Strand Odds Ratio (SOR): > 3.0
  - Fisher Strand (FS): > 60.0
  - Mapping Quality (MQ): < 40.0
  - RankSum Tests: MQRankSum < -12.5
  - ReadPosRankSum < -8.0
  - Depth (DP): Minimum and Maximum thresholds defined by user.

### 3. Biological Refinement

SDR Handling: Specific logic to include/exclude the Sex-Determining-Region.

Clone and private allele removal: Removes clones (genetically identical individuals) and private alleles in form of singletons/doubletons to ensure the dataset is suitable for population genetics analysis.

Random Subsetting: Downsamples the VCF to a specific FRACTION and converts it to PLINK 2.0 (pgen) format for downstream analysis.
