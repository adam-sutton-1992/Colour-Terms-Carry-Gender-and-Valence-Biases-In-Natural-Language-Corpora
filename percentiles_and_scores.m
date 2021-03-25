%% loading liwc from text file and LIWC mean vectors
load fullVectors/glove.6B.300d.mat
load liwcMeans.mat
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

%% Get words of interest, colour and anchor words
colourList = {'red', 'blue', 'green', 'yellow', 'orange', 'pink', 'brown', 'white', 'black', 'purple', 'grey'};
colourListSize = length(colourList);
otherWords = {'nun', 'priest', 'happy', 'sad'};
otherListSize = length(otherWords);
wordList = horzcat(colourList, otherWords);
wordListSize = length(wordList);
testVecs = [];
for i = 1:wordListSize
    testVecs(i,:) = vectors(find(cellfun(cellfind(wordList(i)),cellNames)),:);
    testVecs(i,:) = testVecs(i,:)/norm(testVecs(i,:));
end

%% Computing similarities and biases for n-most occuring words for valence and gender

maxWords = length(cellNames);
sampleSize = 100000;
sampleWords = vectors;

allEmotionScore = zeros(1, sampleSize);
allPosScore = zeros(1, sampleSize);
allNegScore = zeros(1, sampleSize);
allGenderScore = zeros(1, sampleSize);
allHeScore = zeros(1, sampleSize);
allSheScore = zeros(1, sampleSize);
% The lower down the list of words a given word
% is the less it has occured within the 
% embedding. Using the top 100000 occuring
% words ensures for well defined words to be 
% tested. Using all words provides similar
% results

for i = 1:sampleSize
    sampleWords(i,:) = sampleWords(i,:)/norm(sampleWords(i,:));
    posCos = posmean * sampleWords(i,:)';
    negCos = negmean * sampleWords(i,:)';
    allEmotionScore(i) = posCos - negCos;
    allPosScore(i) = posCos;
    allNegScore(i) = negCos;
    
    heCos = hemean * sampleWords(i,:)';
    sheCos = shemean * sampleWords(i,:)';
    allGenderScore(i) = heCos - sheCos;
    allHeScore(i) = heCos;
    allSheScore(i) = sheCos;
end

%% Testing Words for all associations and biases
emotionScore = zeros(1, wordListSize);
genderScore = zeros(1, wordListSize);
for i = 1:wordListSize
    posCos = posmean * testVecs(i,:)';
    negCos = negmean * testVecs(i,:)';
    emotionScore(i) = posCos - negCos;
    PosScore(i) = posCos;
    NegScore(i) = negCos;
    
    heCos = hemean * testVecs(i,:)';
    sheCos = shemean * testVecs(i,:)';
    genderScore(i) = heCos - sheCos;
    HeScore(i) = heCos;
    SheScore(i) = sheCos;
end

%% Calculate Percentiles and Store in Table
PERCENTRANK = @(score, probes) reshape( mean( bsxfun(@le, score(:), probes(:).') ) * 100, size(probes));

genderPercentiles = PERCENTRANK(allGenderScore, genderScore);
emotionPercentiles = PERCENTRANK(allEmotionScore, emotionScore);
hePercentiles = PERCENTRANK(allHeScore, HeScore);
shePercentiles = PERCENTRANK(allSheScore, SheScore);
posPercentiles = PERCENTRANK(allPosScore, PosScore);
negPercentiles = PERCENTRANK(allNegScore, NegScore);

scoreTable = table(wordList', HeScore', SheScore', genderScore', PosScore', NegScore', emotionScore');
scoreTable.Properties.VariableNames = {'Words', 'HeSimilarity', 'SheSimilarity', 'GenderBias', 'PositiveSimilarity', 'NegativeSimilarity', 'ValenceBias'};
percentileTable = table(wordList', hePercentiles', shePercentiles', genderPercentiles', posPercentiles', negPercentiles', emotionPercentiles');
percentileTable.Properties.VariableNames = {'Words', 'HePercentile', 'ShePercentile', 'GenderPercentile', 'PositivePercentile', 'NegativePercentile', 'ValencePercentile'};