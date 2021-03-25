# Colour-Terms-Carry-Gender-and-Valence-Biases-In-Natural-Language-Corpora

Link to GloVe Pre Trained Word Embeddings: http://nlp.stanford.edu/data/glove.6B.zip

All experiements were carried out using MATLAB. A matlab license is required.

The embedding matrix file uploaded here is slightly edited from the pre-trained embeddings above. We have removed tokens that are not words such as ",", "wdqs54" and so on.

"GloVe.6B.300d.mat" is stored with Git LFS, so Git LFS must be installed to download the file from the command line. The file may also be downloaded manually and placed in the relevant directory.

LIWC word lists are owned by the LIWC project and cannot be provided here. To help with reproduceability for this work "liwcMeans.mat" contains the mean vectors used in these experiements. The four mean vectors are for positive emotions, negative emotions, male terms, and female terms.

The GloVe matrix file and liwcMeans file must be  in the matlab directory for the following matlab script files to work:

bias_histograms looks at all six distributions, highlighting colours and some anchor words

percentiles_and_scores calculates all similarities and biases of interest, and provides tables with the raw scores and their percentiles