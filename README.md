# NCPD *P. dactylifera* collection

This repository contains a set of BASH and R scripts to replicate the analyses and generate the figures in:
#### Fornasiero, A., Celii M., Elbasyoni I. S., Hong J., Michaux G., Blilou I., Wing R. A., Poland J. Genetic characterization of a *P. dactylifera* collection at the National Center for Palms and Dates, Saudi Arabia ####

## Overview
The workflow processes high-depth whole-genome sequencing of a date palm collection from the National Center for Palms and Dates (NCPD) in Al-Ahsa, Saudi Arabia (https://ncpd.gov.sa). This resource comprises 123 female varieties and 131 male accessions, and represents the genetic diversity of *P. dactylifera* in Saudi Arabia.

To characterize and curate this collection we addressed the following questions: 

1. What is the genetic relationship among varieties, and are there named date varieties that are genetically identical (clones)?

2. What is the genetic relationship of male trees to the varieties and among males, particularly the male haplotype of the SDR?

As palms have traditionally been moved and cultivated in different regions round the country, there is a general lack of information on the geographic origin of the varieties. Thus, an additional goal is to identify unique genetic profiles to clarify ambiguities in cultivar names and build parentage atlas of NCPD date palms.

## Usage

This repository includes:

1. The Variant Calling Workflow, consisting of BASH scripts for the [trimming](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/01_trim/) of raw Illumina paired-end reads, [alignment and filtering](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/02_align) of trimmed reads to the reference genome, joint genotyping through [SNP calling and filtering](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/03_snp_call).

2. The Analysis Workflow, consisting of BASH and R scripts for [clone](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/04_clones) detection, [population structure](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/05_structure) analysis, [heterozygosity](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/06_pop_stats) estimation, [phylogenetic analysis](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/07_phylogeny) using Neighbor-Joining clustering to measure genetic distance between NCPD date palms and publicly available *P. dactylifera* varieties.

3. The README files with detailed description of each step:
   - [01_trim](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/01_trim/readme.md)
   - [02_align](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/02_align/readme.md)
   - [03_snp_call](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/blob/main/03_snp_call/readme.md)
   - [04_clones](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/04_clones/readme.md)
   - [05_structure](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/05_structure/readme.md)
   - [06_pop_stats](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/06_pop_stats/readme.md)
   - [07_phylogeny](https://github.com/alicefornasiero/DatePalm_KSA_PopGen/tree/main/07_phylogeny/readme.md)

## Links to raw data and reference genomes

- Raw sequence data (fastq files) of 123 *P. dactylifera* female varieties and 131 *P. dactylifera* male accessions from the National Center for Palms and Dates (NCPD): [PRJNA1278712](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1278712)
- The reference genome of Ajwa: [GCA_051530095.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_051530095.1/)
- The male SDR sequence from the reference genome of Male Medina 1: [GCA_054393675.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_054393675.1/)
- Raw sequence data (fastq files) of publicly available *Phoenix* samples (Bioproject: [PRJNA495685](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA495685), [PRJNA427409](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA427409), [PRJNA308824](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA308824), [PRJNA296800](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA296800)). See publication for the complete list of samples used in this work.
  
## References

Celii M, Al-Bader N, Mohammed N,  Zhou Y, Fornasiero A, Navarrete Rodriguez M, Shuwaikan R, Toor U, Hong J, Llaca V, Fengler K, Koo D-H, Gros-Balthazard M, Battesti V, Capote T, Purugganan M, Malek JA, Blilou I, Poland J, Wing RA (2025). Foundational genomic resources for date palm: A gap-free, telomere-to-telomere phased assembly of Ajwa and 19 high-quality genome assemblies of *Phoenix dactylifera*. [*bioRxiv* 2025.12.30.696066](https://doi.org/10.64898/2025.12.30.696066)

Flowers JM, Hazzouri KM, Gros-Balthazard M, Mo Z, Koutroumpa K, Perrakis A, Ferrand S, Khierallah HSM, Fuller DQ, Aberlenc F, Fournaraki C, Purugganan MD. Cross-species hybridization and the origin of North African date palms (2019). *Proc Natl Acad Sci U S A*, 116(5):1651-1658. doi: [10.1073/pnas.1817453116](https://pubmed.ncbi.nlm.nih.gov/30642962/) 

Hazzouri KM, Flowers JM, Visser HJ, Khierallah HSM, Rosas U, Pham GM, Meyer RS, Johansen CK, Fresquez ZA, Masmoudi K, Haider N, El Kadri N, Idaghdour Y, Malek JA, Thirkhill D, Markhand GS, Krueger RR, Zaid A, Purugganan MD (2015). Whole genome re-sequencing of date palms yields insights into diversification of a fruit tree crop. *Nat Commun.*, 6:8824. doi: [10.1038/ncomms9824](https://pubmed.ncbi.nlm.nih.gov/26549859/)

Torres MF, Mathew LS, Ahmed I, Al-Azwani IK, Krueger R, Rivera-Nuñez D, Mohamoud YA, Clark AG, Suhre K, Malek JA. Genus-wide sequencing supports a two-locus model for sex-determination in *Phoenix* (2018). *Nat Commun.*, 9(1):3969. doi: [10.1038/s41467-018-06375-y](https://pubmed.ncbi.nlm.nih.gov/30266991/). Erratum in: *Nat Commun.*, 9(1):5219. doi: [10.1038/s41467-018-07742-5](https://pubmed.ncbi.nlm.nih.gov/30510154/)

## Contacts

For more details or to request materials, please contact the corresponding author:

- **Jesse Poland**: jesse.poland@kaust.edu.sa  

## Citations

If you use the BASH scripts, R code or SRA data, please cite:

```text
Fornasiero, A., Celii M., Elbasyoni I. S., Hong J., Michaux G., Blilou I., Wing R. A., Poland J.
Genetic characterization of a P. dactylifera collection at the National Center for Palms and Dates, Saudi Arabia
```
Additional files and figures related to the publication are deposited in Zenodo: [link](https://zenodo.org/uploads/19182061).
