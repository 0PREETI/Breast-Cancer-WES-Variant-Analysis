#!/bin/bash

fastq_dir="t2_output_fastp"
out_dir="t2_aligned"

samples=$(ls $fastq_dir/*_R1_001.clean.fastq.gz | xargs -n1 basename | sed 's/_R1_001.clean.fastq.gz//' | sort | uniq)

for sample in $samples;do
	R1="${fastq_dir}/${sample}_R1_001.clean.fastq.gz"
	R2="${fastq_dir}/${sample}_R2_001.clean.fastq.gz"
	
	out="${out_dir}/${sample}.bam"
	
	echo "processing $sample..."
	
	#command
	
	bwa mem -t 4 hg38/hg38.fa "$R1" "$R2" | samtools sort -o "$out"
	
done
	
echo "alignment completed"
	
	
