
#!/bin/bash

################################################################################
# This experiment is carried out in order to filter the variants contained within
# the VCF file.



################################################################################
#Dragen Hastable code given below.

dragen --build-hash-table true --ht-reference /data1/ngc/dragen1/AMIT_ROY/reference/ref/GRCh37_latest_genomic.fa \
--output-dir /data1/ngc/dragen1/AMIT_ROY/reference/hash_table
--ht-alt-liftover /opt/edico/liftover/hg19_alt_liftover.sam

#Number of SNPs
bcftools view -v snps EX013_output.vcf | grep -v "^#" | wc -l
422514

#Number of Indels
awk '! /\#/' EX013_output.vcf | awk '{if(length($4) > 1 || length($5) > 1) print}' | wc -l
103207

path=/data/sata_data/workshop/wsu28/packages/snpEff
cat EX013_output.vcf | java -jar $path/SnpSift.jar filter "(QUAL > 30)" > filtered.vcf
bcftools view -v snps filtered.vcf | grep -v "^#" | wc -l


cat EX013_output.vcf | java -jar $path/SnpSift.jar filter "(DP > 20)" > filt7.vcf
bcftools stats filt7.vcf | head -31


################################################################################
#Kuntal used those filter parameter.
Parameter 	Total Variant	SNP
RAW VCF	539387	425115
QUAL > 60	379625	293876
QD > 20	289239	217994
AF > 0.5	233702	185238
DP >= 10	42754	21049
FS <= 0	36895	20201

Filter 2
Parameter	Total Variant	SNP
RAW VCF	539387	425115
DP > 20	55174	26394
AF > 0.1	54214	26096
QUAL > 40	53759	25844
FS <= 0	29705	14035

#################################################################################
Command:
bcftools stats EX013_output.vcf | head -31
number of records:	525189
number of SNPs:	422514

#Filter 1 is used.
path=/data/sata_data/workshop/wsu28/packages/snpEff
cat EX013_output.vcf | java -jar $path/SnpSift.jar filter "(DP > 20)" > filt1.vcf
bcftools stats filt1.vcf | head -31
#Output
number of records:	45414
number of SNPs:	23886

#Filter 2 is used.
path=/data/sata_data/workshop/wsu28/packages/snpEff
cat filt1.vcf | java -jar $path/SnpSift.jar filter "(AF > 0.1)" > filt2.vcf
bcftools stats filt2.vcf | head -31
#Output
number of records:	44742
number of SNPs:	23667


#Filter 3 is used.
path=/data/sata_data/workshop/wsu28/packages/snpEff
cat filt2.vcf | java -jar $path/SnpSift.jar filter "(QUAL > 40)" > filt3.vcf
bcftools stats filt3.vcf | head -31
#Output
number of records:	44360
number of SNPs:	23459


#Filter 4 is used.
path=/data/sata_data/workshop/wsu28/packages/snpEff
cat filt3.vcf | java -jar $path/SnpSift.jar filter "(FS <= 0)" > filt4.vcf
bcftools stats filt4.vcf | head -31
#Output
number of records:	24715
number of SNPs:	12723




path1=/home/pijush/Desktop/NGC/'Dr Amit Roy 16.08.21'/FilterVCF/vcfs/filt4.vcf
path2=/home/pijush/Desktop/NGC/'Dr Amit Roy 16.08.21'/FilterVCF/AnnotateVCF/filt4.ann.vcf

java -jar search_dbNSFP41a.jar -i $path1 -o $path2 -v hg19 -s -p



































....
