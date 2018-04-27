#!/bin/bash
# Lines starting with '#' are ignored and can be used to create
# "comments" or even "comment out" entries

source activate qiime2-2018.2

########### VARIABLES ##################
COLUMN='XXXXXXXXXX'
VAR1='XXXXXXXXXX'
VAR2='XXXXXXXXXX'
METADATA='metadata.txt'

LEVEL=2
########################################
mkdir -p ANCOM

while [ $LEVEL -lt 8 ]; do 
    qiime feature-table filter-samples \
      --i-table table.qza \
      --m-metadata-file $METADATA \
      --p-where "${COLUMN}='$VAR1' OR ${COLUMN}='$VAR2'" \
      --o-filtered-table ANCOM/${VAR1}_${VAR2}_table.qza

    qiime taxa collapse \
      --i-table ANCOM/${VAR1}_${VAR2}_table.qza \
      --i-taxonomy taxonomy.qza \
      --p-level $LEVEL \
      --o-collapsed-table ANCOM/${VAR1}_${VAR2}_level${LEVEL}_table.qza

    qiime composition add-pseudocount \
      --i-table ANCOM/${VAR1}_${VAR2}_level${LEVEL}_table.qza \
      --o-composition-table ANCOM/${VAR1}_${VAR2}_level${LEVEL}_comp_table.qza

    qiime composition ancom \
      --i-table ANCOM/${VAR1}_${VAR2}_level${LEVEL}_comp_table.qza \
      --m-metadata-file $METADATA \
      --m-metadata-column ${COLUMN} \
      --o-visualization ANCOM/${VAR1}_${VAR2}_level${LEVEL}_ancom_${COLUMN}.qzv
    
    let "LEVEL++"
done 
