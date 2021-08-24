

###############################################################################################################################
# The index is created using teh reference genome provided by Kuntal.
STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/STAR_index \
--genomeFastaFiles /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
--sjdbGTFfile /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/gtf/GRCh37_latest_genomicK.gtf




STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/ucsc/STAR_index \
--genomeFastaFiles /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/ucsc/ref/hg19.fa \
--sjdbGTFfile /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/ucsc/gtf/hg19.knownGene.gtf


#Index the reference genome
# cd /home/
mkdir genomeIndex
genomeIndex=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/STAR/STAR_index
#gunzip AtChromosome1.fa.gz
STAR --runMode genomeGenerate --genomeDir $genomeIndex --genomeFastaFiles hg19.fna --runThreadN 25
###############################################################################################################################


r1=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/AmitRay_RAW/EX013/EX013_HyperPrep_H75MMDRXY_L1_R1.fastq.gz
r2=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/AmitRay_RAW/EX013/EX013_HyperPrep_H75MMDRXY_L1_R2.fastq.gz

##### align ###########
## rna align##
STAR --genomeDir /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/STAR_index \
--readFilesIn $r1 $r2 \
--readFilesCommand zcat \
--outSAMtype BAM SortedByCoordinate \
--quantMode GeneCounts \
--outFileNamePrefix /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/processed/EX013_kuntal/EX013 \
--runThreadN 4

### convert fastq to bam ###

picard FastqToSam \
       F1=$r1 \
       F2=$r2 \
       O=EX013_unaligned.bam \
       SM=EX013 \
       RG=EX013



#######################################################################################################################

#Creating the index file
picard BuildBamIndex \
    I=EX013_unaligned.bam


#Creating the index file
picard BuildBamIndex \
    I=EX013Aligned.sortedByCoord.out.bam



picard CreateSequenceDictionary \
      R=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
      O=GRCh37_latest_genomic.dict



##merge alin and unalign ##
picard MergeBamAlignment \
      ALIGNED=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/processed/EX013_kuntal/mapped/EX013Aligned.sortedByCoord.out.bam \
      UNMAPPED=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/processed/EX013_kuntal/unmapped/EX013_unaligned.bam \
      O=EX013_merge_alignments.bam \
      R=/data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa


####################################################################################################################

### mark duplicate
gatk=/data/sata_data/workshop/wsu28/packages/gatk/gatk
$gatk MarkDuplicates I=EX013_merge_alignments.bam O=marked_EX013Aligned.bam M=marked_dup_metrics.txt


picard MarkDuplicates \
      I=EX013_merge_alignments.bam \
      O=EX013_merge_alignments_marked_duplicates.bam \
      M=marked_dup_metrics.txt


##N CIGAR SplitNCigarReads
gatk=/data/sata_data/workshop/wsu28/packages/gatk/gatk
$gatk SplitNCigarReads \
    -R /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
    -I EX013_merge_alignments_marked_duplicates.bam \
    -O EX013_filt.bam


## group addition
picard AddOrReplaceReadGroups \
    I=EX013_filt.bam \
    O=EX013_RG.bam \
    RGID=4 \
    RGLB=lib1 \
    RGPL=ILLUMINA \
    RGPU=unit1 \
    RGSM=20


# **Base Quality Recalibration table generate
#Indexing the vcf file.
$gatk IndexFeatureFile \
     --input GCF_000001405.25.vcf


$gatk BaseRecalibrator \
    -I EX013_RG.bam \
    -R /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
    --known-sites /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/dbSNP/GCF_000001405.25.vcf \
    -O EX013_filt_recal.table


## calibrate
$gatk ApplyBQSR \
    -R /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
    -I EX013_RG.bam \
    --bqsr-recal-file EX013_filt_recal.table \
    -O EX013_calib.bam


# call variant
$gatk --java-options "-Xmx4g" HaplotypeCaller \
     -R /data/sata_data/workshop/wsu28/NGC/Gi_02_2021/reference/kuntal_ref/ref/GRCh37_latest_genomic.fa \
     -I EX013_calib.bam \
     -O EX013_output.vcf.gz \
     -bamout EX013_bamout.bam \
     --native-pair-hmm-threads 45
