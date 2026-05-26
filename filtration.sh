mkdir -p filtered_vcfs

for vcf in mutect2_results/*.vcf.gz; do
  base=$(basename "$vcf" .vcf.gz)

  gatk FilterMutectCalls \
    -R hg38/hg38.fa \
    -V "$vcf" \
    --stats "$vcf.stats" \
    -O filtered_vcfs/${base}.filtered.vcf.gz
done
