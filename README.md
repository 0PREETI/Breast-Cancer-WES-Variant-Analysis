# Breast-Cancer-WES-Variant-Analysis
A bioinformatics pipeline for identifying somatic variants associated with chemoresistance (in Indian breast cancer patients) using Whole Exome Sequencing (WES). This repository contains the complete analysis workflow from raw FASTQ to annotated somatic variants.
Note: Raw sequencing data and sample-level results are confidential and not included in this repository. Only the pipeline scripts and workflow documentation are shared.

Project Overview
Objective: Identify population-specific somatic variants linked to chemoresistance in Indian breast cancer patients using WES data.
Biological Question: Which somatic variants in Indian breast tumor samples are associated with resistance to chemotherapy, and how do they compare to known resistance mechanisms in global databases?

Annotation & population databases used:

Ensembl VEP — functional annotation (GRCh38 cache, no plugins)
gnomAD — population allele frequencies (via VEP cache)
1000 Genomes Project — global population frequencies (via VEP cache)

breast-cancer-wes/
│
├── parallel.py              # Parallel fastp QC runner with HTML summary report
├── align.sh                 # BWA-MEM alignment to hg38
├── preprocessing.sh         # BAM post-processing (sort, fixmate, markdup, RG)
├── preprocessing_2.sh       # BAM indexing using GATK BuildBamIndex
├── filtration.sh            # Mutect2 variant filtering (FilterMutectCalls)
├── vep_annotation.sh        # VEP annotation + somatic high-confidence filtering
│
└── README.md

