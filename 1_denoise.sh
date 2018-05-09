#/bin/bash
# Lines starting with '#' are ignored and can be used to create
# "comments" or even "comment out" entries

########## QIIME2 'Moving Pictures' Pipeline ##########

######Activate QIIME2 #####
source activate qiime2-2018.4
###### VARIABLES ######

METADATA="/bigdata/forKen/preeclampsia/metadataPE.txt"
MANIFEST="/bigdata/forKen/preeclampsia/manifest32_56.txt"

# Denoise #
TRIM_F=6
TRIM_R=6
TRUNC_F=275
TRUNC_R=275

#######################


###### Import ######
#manifest_path
#metadata.tsv
########### manifest format (remove '#') ###############
#sample-id,absolute-filepath,direction
#sample-1,$PWD/some/filepath/sample1_R1.fastq.gz,forward
#sample-2,$PWD/some/filepath/sample2_R1.fastq.gz,forward
#sample-1,$PWD/some/filepath/sample1_R2.fastq.gz,reverse
#sample-2,$PWD/some/filepath/sample2_R2.fastq.gz,reverse
########################################################

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $MANIFEST \
  --output-path demux.qza \
  --source-format PairedEndFastqManifestPhred33 \

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv
  
###### DADA2 ######
#trim-left-f
#trim-left-r
#trunc-len-f
#threads
#trunc-len-r
###################
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f $TRIM_F \
  --p-trim-left-r $TRIM_R \
  --p-trunc-len-f $TRUNC_F \
  --p-trunc-len-r $TRUNC_R \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --p-n-threads 4 \
  --verbose
  
 ###### Summarize FeatureTable & FeatureData ######
 #metadata (optional)                             #
 ##################################################
 qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file $METADATA
  
qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv
