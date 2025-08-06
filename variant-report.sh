# Commands completed on linux for windows
bcftools mpileup -Ou -f references/combined_refs.fasta barcode11/barcode11.sorted.aligned.bam | bcftools call -Ov -m > variants/barcode11_variants.vcf
ls -la variants/
wc -l variants/barcode11_variants.vcf
head -20 variants/barcode11_variants.vcf
# Look for deletion variants (negative INDEL lengths)
grep -v "^#" variants/barcode11_variants.vcf | head -10

# Count total variants
grep -v "^#" variants/barcode11_variants.vcf | wc -l
# Run on all barcodes
for barcode in barcode11 barcode12 barcode13 barcode14; do
    echo "Processing $barcode..."
    bcftools mpileup -Ou -f references/combined_refs.fasta $barcode/$barcode.sorted.aligned.bam | bcftools call -Ov -m > variants/${barcode}_variants.vcf
done
# Look for actual variants (not reference calls)
grep -v "^#" variants/barcode11_variants.vcf | grep -v "0/0" | head -10

# Count real variants
grep -v "^#" variants/barcode11_variants.vcf | grep -v "0/0" | wc -l

# Look specifically for insertions/deletions (INDELs)
grep -v "^#" variants/barcode11_variants.vcf | grep "INDEL" | head -10
# Filter for higher quality variants only
bcftools filter -i 'QUAL>30' variants/barcode11_variants.vcf > variants/barcode11_filtered.vcf

# Count filtered variants
grep -v "^#" variants/barcode11_filtered.vcf | wc -l
# Run variant calling on all your other barcodes
for barcode in barcode12 barcode13 barcode14; do
    echo "Processing $barcode..."
    bcftools mpileup -Ou -f references/combined_refs.fasta $barcode/$barcode.sorted.aligned.bam | bcftools call -Ov -m > variants/${barcode}_variants.vcf
done

# Check variant counts for all samples
echo "Variant counts for all samples:"
for barcode in barcode11 barcode12 barcode13 barcode14; do
    count=$(grep -v "^#" variants/${barcode}_variants.vcf | grep -v "0/0" | wc -l)
    echo "$barcode: $count variants"
done
# Check barcode12 variants
echo "=== Barcode12 Variants ==="
grep -v "^#" variants/barcode12_variants.vcf | grep -v "0/0" | head -10

# Check barcode13 variants  
echo "=== Barcode13 Variants ==="
grep -v "^#" variants/barcode13_variants.vcf | grep -v "0/0" | head -10

# Check barcode14 variants
echo "=== Barcode14 Variants ==="
grep -v "^#" variants/barcode14_variants.vcf | grep -v "0/0" | head -10
# Check for indels 
echo "INDEL counts for all samples:"
for barcode in barcode11 barcode12 barcode13 barcode14; do
    indel_count=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | wc -l)
    echo "$barcode: $indel_count INDELs"
done
# Create a summary of all variants
echo "Creating variant summary..."
for barcode in barcode11 barcode12 barcode13 barcode14; do
    echo "=== $barcode ===" 
    grep -v "^#" variants/${barcode}_variants.vcf | grep -v "0/0" | wc -l
done
# Process other bar codes
for barcode in barcode12 barcode13 barcode14; do
    echo "Processing $barcode..."
    bcftools mpileup -Ou -f references/combined_refs.fasta $barcode/$barcode.sorted.aligned.bam | bcftools call -Ov -m > variants/${barcode}_variants.vcf
done
# Check if all files were created
ls -la variants/

# Count variants in all samples
echo "Variant counts for all samples:"
for barcode in barcode11 barcode12 barcode13 barcode14; do
    count=$(grep -v "^#" variants/${barcode}_variants.vcf | grep -v "0/0" | wc -l)
    echo "$barcode: $count variants"
done
# See the actual variants in each sample
echo "=== Barcode11 Variants (11 total) ==="
grep -v "^#" variants/barcode11_variants.vcf | grep -v "0/0"

echo "=== Barcode12 Variants (10 total) ==="
grep -v "^#" variants/barcode12_variants.vcf | grep -v "0/0"

echo "=== Barcode13 Variants (14 total) ==="
grep -v "^#" variants/barcode13_variants.vcf | grep -v "0/0"

echo "=== Barcode14 Variants (23 total) ==="
grep -v "^#" variants/barcode14_variants.vcf | grep -v "0/0"
# Check for deletins/insertions
echo "INDEL counts for all samples:"
for barcode in barcode11 barcode12 barcode13 barcode14; do
    indel_count=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | wc -l)
    echo "$barcode: $indel_count INDELs (deletions/insertions)"
done
# Extract just the position and change info for comparison
echo "Creating position lists for comparison..."
for barcode in barcode11 barcode12 barcode13 barcode14; do
    grep -v "^#" variants/${barcode}_variants.vcf | grep -v "0/0" | awk '{print $2":"$4">"$5}' > variants/${barcode}_positions.txt
done

# See what's in the position files
echo "Positions in barcode11:"
head -5 variants/barcode11_positions.txt
# See the INDELs in barcode13 (first 10)
echo "=== Barcode13 INDELs (111 total) ==="
grep -v "^#" variants/barcode13_variants.vcf | grep "INDEL" | head -10

# See the INDELs in barcode14 (first 10)
echo "=== Barcode14 INDELs (258 total) ==="
grep -v "^#" variants/barcode14_variants.vcf | grep "INDEL" | head -10
# Look for deletions (reference longer than alternative)
echo "=== Barcode13 Deletions ==="
grep -v "^#" variants/barcode13_variants.vcf | grep "INDEL" | awk 'length($4) > length($5)' | head -5

echo "=== Barcode14 Deletions ==="
grep -v "^#" variants/barcode14_variants.vcf | grep "INDEL" | awk 'length($4) > length($5)' | head -5

# Look for insertions (alternative longer than reference)
echo "=== Barcode13 Insertions ==="
grep -v "^#" variants/barcode13_variants.vcf | grep "INDEL" | awk 'length($4) < length($5)' | head -5

echo "=== Barcode14 Insertions ==="
grep -v "^#" variants/barcode14_variants.vcf | grep "INDEL" | awk 'length($4) < length($5)' | head -5
echo "INDEL breakdown:"
for barcode in barcode13 barcode14; do
    deletions=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | awk 'length($4) > length($5)' | wc -l)
    insertions=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | awk 'length($4) < length($5)' | wc -l)
    echo "$barcode: $deletions deletions, $insertions insertions"
done
# Calculate deletion sizes for barcode13
echo "=== Barcode13 Deletion Sizes ==="
grep -v "^#" variants/barcode13_variants.vcf | grep "INDEL" | awk 'length($4) > length($5) {print $2, length($4)-length($5), $4">"$5}' | head -10
# Create a printable report
#!/bin/bash
REPORT_FILE="variant_analysis_report.txt"

echo "==============================================================================" > $REPORT_FILE
echo "                    NANOPORE VARIANT ANALYSIS REPORT" >> $REPORT_FILE
echo "                          $(date)" >> $REPORT_FILE
echo "==============================================================================" >> $REPORT_FILE

echo "SUMMARY:" >> $REPORT_FILE
for barcode in barcode11 barcode12 barcode13 barcode14; do
    total=$(grep -v "^#" variants/${barcode}_variants.vcf | grep -v "0/0" | wc -l)
    indels=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | wc -l)
    deletions=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | awk 'length($4) > length($5)' | wc -l)
    insertions=$(grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | awk 'length($4) < length($5)' | wc -l)
    echo "$barcode: Total=$total, INDELs=$indels (Del=$deletions, Ins=$insertions)" >> $REPORT_FILE
done

echo "" >> $REPORT_FILE
echo "DETAILED DELETIONS:" >> $REPORT_FILE
for barcode in barcode13 barcode14; do
    echo "=== $barcode ===" >> $REPORT_FILE
    grep -v "^#" variants/${barcode}_variants.vcf | grep "INDEL" | awk 'length($4) > length($5) {print $2, length($4)-length($5), $4">"$5, $6}' >> $REPORT_FILE
done

echo "Report created: $REPORT_FILE"
cat $REPORT_FILE
# Save the report
# All done for now!
