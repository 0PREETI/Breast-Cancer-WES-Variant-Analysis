#!/bin/bash

# Paths to reference and resources
ref="hg38/hg38.fa"
germline="af-only-gnomad.hg38.vcf.gz"

# Input directories
tumor_dir="t_bam_dir"
normal_dir="bam_dir"

# Output directories
out_dir="mutect2_results"
mkdir -p "$out_dir"

# Process each tumor–normal pair
for tumor in ${tumor_dir}/*_TS*_RG.bam; do
    tumor_base=$(basename "$tumor" _RG.bam)

    # Convert TS to S (e.g. TS1 ? S1)
    normal_base=${tumor_base/TS/S}
    normal="${normal_dir}/${normal_base}_RG.bam"

    sample=${tumor_base%_TS*}  # e.g. KBTB238

    echo "Processing tumor-normal pair: $sample"
    echo "Tumor:  $tumor"
    echo "Normal: $normal"

    # Extract SM tag from normal BAM automatically
    normal_sm=$(samtools view -H "$normal" | grep '^@RG' | sed -n 's/.*SM:\([^ \t]*\).*/\1/p')

    echo "Detected normal SM tag: $normal_sm"

    # Define output VCF
    output_vcf="${out_dir}/${sample}.vcf.gz"

    echo "Running Mutect2..."
    gatk Mutect2 \
        -R "$ref" \
        -I "$tumor" \
        -I "$normal" \
        -normal "$normal_sm" \
        --germline-resource "$germline" \
        -O "$output_vcf"

done

echo "next 16 samples processed successfully!"
