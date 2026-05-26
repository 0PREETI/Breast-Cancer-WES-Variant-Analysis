#!/bin/bash

# Set number of threads
threads=8

# Input and output directories
input_dir="t2_aligned"
tmp_dir="tmp"
RG_dir='t2_bam_dir'

# Create directories if missing
mkdir -p "$tmp_dir" "$RG_dir" 

# Loop through all BAM files in the input directory
for f in ${input_dir}/*.bam; do
  sample=$(basename "$f" .bam)
  echo "Processing sample: $sample"

  # Step 1: Name sort the BAM file
  samtools sort -n -@ $threads -o ${tmp_dir}/${sample}_namesorted.bam "$f"

  # Step 2: Add mate information
  samtools fixmate -m -@ $threads ${tmp_dir}/${sample}_namesorted.bam ${tmp_dir}/${sample}_fixmate.bam

  # Step 3: Coordinate sort
  samtools sort -@ $threads -o ${tmp_dir}/${sample}_coordsorted.bam ${tmp_dir}/${sample}_fixmate.bam

  # Step 4: Mark duplicates
  samtools markdup -@ $threads ${tmp_dir}/${sample}_coordsorted.bam ${tmp_dir}/${sample}_marked.bam

  # Step 5: Index the marked BAM
  #samtools index -@ $threads ${tmp_dir}/${sample}_marked.bam

  # Step 6: Add or replace read groups using Picard
  java -jar /apps/picard/picard.jar AddOrReplaceReadGroups \
    I=${tmp_dir}/${sample}_marked.bam \
    O=${RG_dir}/${sample}_RG.bam \
    RGID=${sample} \
    RGLB=lib1 \
    RGPL=ILLUMINA \
    RGPU=unit1 \
    RGSM=${sample}

#gatk index builder was used, named preprocessing_2.sh
#wherein gatk buildbamindex tool was used 

  # Step 7: Clean up temporary files
  rm -f ${tmp_dir}/${sample}_namesorted.bam ${tmp_dir}/${sample}_fixmate.bam ${tmp_dir}/${sample}_coordsorted.bam ${tmp_dir}/${sample}_marked.bam

  echo "Finished processing: $sample"
done

echo "All samples processed duplicates marked, indexed, and read groups added."
