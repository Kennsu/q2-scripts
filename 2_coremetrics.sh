#/bin/bash
# Lines starting with '#' are ignored and can be used to create
# "comments" or even "comment out" entries

########## QIIME2 'Moving Pictures' Pipeline ##########

######Activate QIIME2 #####
source activate qiime2-2018.4
###### VARIABLES ##########

METADATA="/bigdata/forKen/preeclamsia/metadataPE.txt"

# Alpha & Beta Diversity #
DEPTH=4397

# Taxonomy Analysis #
REF_TAXONOMY='/bigdata/forKen/ClassifierTraining/ref-taxonomy.qza'
OTUS99='/bigdata/forKen/ClassifierTraining/99_otus.qza'
PRIMER_F="ACTCCTACGGGAGGCAGCAG"
PRIMER_R="GGACTACHVGGGTWTCTAAT"
TRUNC=275

########################################
echo "--------Generating Tree--------"
 ###### Generate Tree ######
 ###########################
 qiime alignment mafft \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza
  
 qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
 
 qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza
 
 qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
 
 ###### Alpha & Beta Diversity Analysis #######
echo "Starting Alpha $ Beta Diversity Analysis"
 ##############################################
 qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth $DEPTH \
  --m-metadata-file $METADATA \
  --output-dir core-metrics-results
 
 #alpha group significance
 #########################
 
 ###### Alpha Rarefaction Plotting ######
echo "Plotting Alpha Rarefaction"
 ########################################
 qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth $DEPTH \
  --m-metadata-file $METADATA \
  --o-visualization alpha-rarefaction.qzv

 ###### Taxonomic Analysis ######
 #trainer
 #99_otus
 #f_primer
 #r_primer
 #TRUNC_len
 #metadata
 ################################
 
### Train Classifier ### 
 echo "Beginning to train classifier"
#Extract Reads
 qiime feature-classifier extract-reads \
  --i-sequences $OTUS99 \
  --p-f-primer $PRIMER_F \
  --p-r-primer $PRIMER_R \
  --p-trunc-len $TRUNC \
  --o-reads ref-seqs.qza
 
#Train Classifier
 qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ref-seqs.qza \
  --i-reference-taxonomy $REF_TAXONOMY \
  --o-classifier classifier.qza
echo "running classifier"
#Run Classifier
 qiime feature-classifier classify-sklearn \
  --i-classifier classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
echo "Generating taxanomic bar plots"
#Create Barplot of Taxonomic Composition
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file $METADATA \
  --o-visualization taxa-bar-plots.qzv
  
