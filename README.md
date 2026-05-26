# Breast Cancer WES Pipeline — Chemoresistance Variant Analysis in Indian Tumors

A bioinformatics pipeline for identifying somatic variants associated with chemoresistance in Indian breast cancer patients using Whole Exome Sequencing (WES). This repository contains the complete analysis workflow from raw FASTQ to annotated somatic variants.

> **Note:** Raw sequencing data and sample-level results are confidential and not included in this repository. Only the pipeline scripts and workflow documentation are shared.

---

## Project Overview

**Objective:** Identify population-specific somatic variants linked to chemoresistance in Indian breast cancer patients using WES data.

**Biological Question:** Which somatic variants in Indian breast tumor samples are associated with resistance to chemotherapy, and what are the underlying mechanisms?

**Annotation & population databases used:**
- [Ensembl VEP](https://www.ensembl.org/vep) — functional annotation (GRCh38 cache, no plugins)
- [gnomAD](https://gnomad.broadinstitute.org/) — population allele frequencies (via VEP cache)
- [1000 Genomes Project](https://www.internationalgenome.org/) — global population frequencies (via VEP cache)

---

## Repository Structure

```
Breast-Cancer-WES-Variant-Analysis/
│
├── parallel.py              # Parallel fastp QC runner with HTML summary report
├── align.sh                 # BWA-MEM alignment to hg38
├── preprocessing.sh         # BAM post-processing (sort, fixmate, markdup, read groups)
├── preprocessing_2.sh       # BAM indexing using GATK BuildBamIndex
├── variant_calling.sh       # Somatic variant calling with GATK Mutect2 (tumor-normal mode)
├── filtration.sh            # Mutect2 variant filtering (FilterMutectCalls)
├── vep_annotation.sh        # VEP annotation + somatic high-confidence filtering
│
└── README.md
```

> **Note:** Downstream filtering and prioritization (R-based) is not included as it operates on confidential results.

---

## Pipeline Overview

```
Raw FASTQ
    │
    ▼
[Step 1] Quality Control
    FastQC (before & after trimming) → QC reports
    parallel.py → fastp (parallel trimming) → clean FASTQ + HTML reports
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
    variant_calling.sh → GATK Mutect2 (tumor-normal mode) → raw VCF
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
```

---

## Tools & Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| FastQC | v0.11.3 | Raw read quality assessment |
| fastp |  0.23.4 | Read trimming and QC |
| BWA-MEM | 0.7.17-r1188 | Reference alignment |
| SAMtools | 1.7 | BAM manipulation |
| Picard | 2.27.5 | Read group addition |
| GATK | 4.3.0.0 | Variant calling & filtering |
| Ensembl VEP | >115 | Variant annotation |


**Reference genome:** GRCh38 / hg38

---

## Usage

### Step 1: Quality Control
```bash
# FastQC on raw reads
fastqc raw_fastq/*.fastq.gz -o fastqc_raw/

# Parallel fastp trimming
python parallel.py \
  -i raw_fastq/ \
  -o t2_output_fastp/ \
  -r qc_reports/ \
  -p 4

# FastQC on trimmed reads
fastqc t2_output_fastp/*.fastq.gz -o fastqc_trimmed/
```

### Step 2: Alignment
```bash
bash align.sh
# Input:  t2_output_fastp/*_R1/R2_001.clean.fastq.gz
# Output: t2_aligned/*.bam
```

### Step 3: BAM Post-Processing
```bash
bash preprocessing.sh
bash preprocessing_2.sh
# Input:  t2_aligned/*.bam
# Output: t2_bam_dir/*_RG.bam + .bai index
```

### Step 4: Variant Calling
```bash
bash variant_calling.sh
# Input:  t2_bam_dir/*_RG.bam
# Output: mutect2_results/*.vcf.gz
```

### Step 5: Variant Filtration
```bash
bash filtration.sh
# Input:  mutect2_results/*.vcf.gz
# Output: filtered_vcfs/*.filtered.vcf.gz
```

### Step 6: Annotation & Somatic Filtering
```bash
# Update paths in vep_annotation.sh before running
bash vep_annotation.sh
# Output: analysis/*.somatic_highconf.vep.tsv
```

---

## Notes

- VEP cache must be downloaded separately: `for homo_sapiens GRCh38`
- `parallel.py` automatically detects CPU count and sets parallel workers to `CPU_cores / 4`
- The somatic high-confidence filter applies: tumor AF > 0.05, normal AF < 0.05, tumor depth > 20
- Hardcoded paths in all scripts must be updated to match your system before running

---

## Author

**Preeti Singh Chauhan**  
M.Sc. Bioinformatics, Savitribai Phule Pune University (SPPU), 2026  
Pune, Maharashtra, India  
[LinkedIn](www.linkedin.com/in/preeti18)

---

## License

Scripts in this repository are shared for educational and reproducibility purposes.  
Raw data and results are confidential and not included.
