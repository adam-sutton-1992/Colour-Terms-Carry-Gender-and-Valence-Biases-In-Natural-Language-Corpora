# Colour-Terms-Carry-Gender-and-Valence-Biases-In-Natural-Language-Corpora

Link to GloVe Pre Trained Word Embeddings: http://nlp.stanford.edu/data/glove.6B.zip

All experiements were carried out using MATLAB. A matlab license is required.

The embedding matrix file uploaded here is slightly edited from the pre-trained embeddings above. We have removed tokens that are not words such as ",", "wdqs54" and so on.

"GloVe.6B.300d.mat" is stored with Git LFS, so Git LFS must be installed to download the file from the command line. The file may also be downloaded manually and placed in the relevant directory.

LIWC word lists are owned by the LIWC project and cannot be provided here. To help with reproduceability for this work "liwcMeans.mat" contains the mean vectors used in these experiements. The four mean vectors are for positive emotions, negative emotions, male terms, and female terms.

The GloVe matrix file and liwcMeans file must be accessible in the matlab directory for the following matlab script files to work:

bias_histograms looks at the distributions of all 6 tests and highlights colours and a few select sample words (In the Paper Figure 1, S1, and S2)

bias_differences looks at the pairwise differences between all colours and compares them to random pair differences to see if the difference in bias between colours is significant (i.e. "is red significantly more positive than orange?")