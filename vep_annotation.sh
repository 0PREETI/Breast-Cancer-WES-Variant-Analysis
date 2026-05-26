#!/bin/bash

# ==============================
# Paths
# ==============================

INPUT_DIR="/media/preeti-singh-chauhan/Expansion/results/filtered_vcfs/filtered_vcfs"
ANALYSIS_DIR="/media/preeti-singh-chauhan/Expansion/results/analysis"
CACHE_DIR="/media/preeti-singh-chauhan/Expansion/vep_cache"

mkdir -p ${ANALYSIS_DIR}

# ==============================
# Loop through all filtered VCFs
# ==============================

for VCF in ${INPUT_DIR}/*.filtered.vcf.gz
do
    SAMPLE=$(basename ${VCF} .filtered.vcf.gz)

    echo "Processing ${SAMPLE}..."

    # ----------------------------------
    # Step 1: VEP annotation (VCF output)
    # ----------------------------------

    vep \
      -i ${VCF} \
      -o ${ANALYSIS_DIR}/${SAMPLE}.vep_filtered.vcf.gz \
      --cache \
      --offline \
      --assembly GRCh38 \
      --dir_cache ${CACHE_DIR} \
      --everything \
      --vcf \
      --compress_output bgzip \
      --force_overwrite

    tabix -p vcf ${ANALYSIS_DIR}/${SAMPLE}.vep_filtered.vcf.gz

    # ----------------------------------
    # Step 2: Extract PASS variants
    # ----------------------------------

    bcftools view -f PASS \
      ${ANALYSIS_DIR}/${SAMPLE}.vep_filtered.vcf.gz \
      -Oz -o ${ANALYSIS_DIR}/${SAMPLE}.pass.vcf.gz

    tabix -p vcf ${ANALYSIS_DIR}/${SAMPLE}.pass.vcf.gz

    # ----------------------------------
    # Step 3: Split multiallelic variants
    # ----------------------------------

    bcftools norm -m -both \
      -Oz -o ${ANALYSIS_DIR}/${SAMPLE}.split.vcf.gz \
      ${ANALYSIS_DIR}/${SAMPLE}.pass.vcf.gz

    tabix -p vcf ${ANALYSIS_DIR}/${SAMPLE}.split.vcf.gz

    # ----------------------------------
    # Step 4: Somatic high-confidence filtering
    # ----------------------------------

    bcftools view \
      -i 'FORMAT/AF[1:0] > 0.05 && FORMAT/AF[0:0] < 0.05 && FORMAT/DP[1] > 20' \
      -Oz -o ${ANALYSIS_DIR}/${SAMPLE}.somatic_highconf.vcf.gz \
      ${ANALYSIS_DIR}/${SAMPLE}.split.vcf.gz

    tabix -p vcf ${ANALYSIS_DIR}/${SAMPLE}.somatic_highconf.vcf.gz

    # ----------------------------------
    # Step 5: Final VEP (TSV output)
    # ----------------------------------

    vep \
      -i ${ANALYSIS_DIR}/${SAMPLE}.somatic_highconf.vcf.gz \
      -o ${ANALYSIS_DIR}/${SAMPLE}.somatic_highconf.vep.tsv \
      --cache \
      --offline \
      --assembly GRCh38 \
      --dir_cache ${CACHE_DIR} \
      --everything \
      --tab \
      --force_overwrite

    echo "${SAMPLE} completed."
    echo "----------------------------------"

done

echo "All samples processed successfully!"

