A bioinformatics pipeline for identifying somatic variants associated with chemoresistance in Indian breast cancer patients using Whole Exome Sequencing (WES). This repository contains the complete analysis workflow from raw FASTQ to annotated somatic variants.

Note: Raw sequencing data and sample-level results are confidential and not included in this repository. Only the pipeline scripts and workflow documentation are shared.


Project Overview
Objective: Identify population-specific somatic variants linked to chemoresistance in Indian breast cancer patients using WES data.
Biological Question: Which somatic variants in Indian breast tumor samples are associated with resistance to chemotherapy, and their hows? 
Annotation & population databases used:

Ensembl VEP - functional annotation (GRCh38 cache, no plugins)
gnomAD - population allele frequencies (via VEP cache)
1000 Genomes Project - global population frequencies (via VEP cache)


Repository Structure
breast-cancer-wes/
│
├── parallel.py              # Parallel fastp QC runner with HTML summary report
├── align.sh                 # BWA-MEM alignment to hg38
├── preprocessing.sh         # BAM post-processing (sort, fixmate, markdup, RG)
├── preprocessing_2.sh       # BAM indexing using GATK BuildBamIndex 
├── variant_calling.sh
├── filtration.sh            # Mutect2 variant filtering (FilterMutectCalls)
├── vep_annotation.sh        # VEP annotation + somatic high-confidence filtering
│
└── README.md

Note: Downstream filtering and prioritization (R-based) is not included as it operates on confidential results.


Pipeline Overview
Raw FASTQ
    │
    ▼
[Step 1] Quality Control & Preprocessing, I ran Fastqc as well on both i.e., before and after trimming sequenced read files, Normal fastqc command was used on folder containing fastq files.
    parallel.py → fastp (parallel) → clean FASTQ + QC HTML reports
    │
    ▼
[Step 2] Alignment
    align.sh → BWA-MEM (hg38) → sorted BAM
    │
    ▼
[Step 3] BAM Post-Processing
    preprocessing.sh → name sort → fixmate → coord sort → markdup → add read groups
    preprocessing_2.sh → GATK BuildBamIndex
    │
    ▼
[Step 4] Variant Calling
    GATK Mutect2 (tumor-normal mode) → raw VCF
    │
    ▼
[Step 5] Variant Filtration
    filtration.sh → GATK FilterMutectCalls → filtered VCF
    │
    ▼
[Step 6] Annotation & Somatic Filtering
    vep_annotation.sh →
        VEP annotation (GRCh38, --everything) →
        PASS filter (bcftools) →
        Split multiallelic sites →
        Somatic high-confidence filter (AF > 0.05 tumor, AF < 0.05 normal, DP > 20) →
        Final VEP TSV output
    │
    ▼
[Step 7] Downstream Analysis (R)
    Variant prioritization, population frequency filtering (gnomAD, 1000 Genomes),
    chemoresistance gene overlap and interpretation


Usage
Step 1: QC & Preprocessing (parallel fastp)
bash python parallel.py \
  -i raw_fastq/ \
  -o t2_output_fastp/ \
  -r qc_reports/ \
  -p 4
  
Step 2: Alignment
bash bash align.sh
# Input:  t2_output_fastp/*_R1/R2_001.clean.fastq.gz
# Output: t2_aligned/*.bam

Step 3: BAM Post-Processing
bash bash preprocessing.sh
bash preprocessing_2.sh
# Input:  t2_aligned/*.bam
# Output: t2_bam_dir/*_RG.bam + .bai index

Step 4: Variant Calling
Run GATK Mutect2 in tumor-normal mode on processed BAMs.
bash# Example (adjust for your sample names):
gatk Mutect2 \
  -R hg38/hg38.fa \
  -I tumor_RG.bam \
  -I normal_RG.bam \
  -normal <normal_sample_name> \
  -O mutect2_results/<sample>.vcf.gz
  
Step 5: Variant Filtration
bash bash filtration.sh
# Input:  mutect2_results/*.vcf.gz
# Output: filtered_vcfs/*.filtered.vcf.gz

Step 6: Annotation & Somatic Filtering
bash# Update paths in vep_annotation.sh before running
bash vep_annotation.sh
# Output: analysis/*.somatic_highconf.vep.tsv

Notes

VEP cache must be downloaded separately: vep_install -a cf -s homo_sapiens -y GRCh38
parallel.py automatically detects CPU count and sets parallel workers to CPU_cores / 4
The somatic high-confidence filter applies: tumor AF > 0.05, normal AF < 0.05, tumor depth > 20
Hardcoded paths in any and all of the scripts  must be updated to match your system


Author
Preeti Singh Chauhan
M.Sc. Bioinformatics, Savitribai Phule Pune University (SPPU), 2026
Pune, Maharashtra, India


License
Scripts in this repository are shared for educational and reproducibility purposes.
Raw data and results are confidential and not included.
