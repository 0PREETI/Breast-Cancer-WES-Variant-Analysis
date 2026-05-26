#!/bin/bash

# Directory containing BAM files
bam_dir="t2_bam_dir"

output_dir="$bam_dir"

# Loop through each BAM file
for bam in "$bam_dir"/*.bam; do
    echo "Indexing file: $bam"
    gatk BuildBamIndex -I "$bam" -O "$output_dir"/$(basename "$bam" .bam).bai
done
