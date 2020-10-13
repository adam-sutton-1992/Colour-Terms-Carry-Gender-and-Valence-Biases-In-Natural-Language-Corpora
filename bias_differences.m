%% loading liwc from text file and LIWC mean vectors
load fullVectors/glove.6B.300d.mat
load liwcMeans.mat
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

%% Get test words and normalize while assigning colour values for them
colourList = {'red', 'blue', 'green', 'yellow', 'orange', 'pink', 'brown', 'white', 'black', 'purple', 'grey'};
colourListSize = length(colourList);
colourVecs = [];
for i = 1:colourListSize
    colourVecs(i,:) = vectors(find(cellfun(cellfind(colourList(i)),cellNames)),:);
    colourVecs(i,:) = colourVecs(i,:)/norm(colourVecs(i,:));
end

%Graphic values of colours
coloursVals = [[1 0 0];[0 0 1]; [0 1 0]; [1 1 0]; [1 0.647 0]; [1 0.411 0.705]; 
    [0.647 0.164 0.164]; [1 0.9 0.9]; [0 0 0];[0.501 0 0.501]; [0.501 0.501 0.501]];

%% Testing Words
emotionScore = [];
genderScore = [];
for i = 1:colourListSize
    posCos = posmean * colourVecs(i,:)';
    negCos = negmean * colourVecs(i,:)';
    emotionScore(i) = posCos - negCos;
    PosScore(i) = posCos;
    NegScore(i) = negCos;
    
    heCos = hemean * colourVecs(i,:)';
    sheCos = shemean * colourVecs(i,:)';
    genderScore(i) = heCos - sheCos;
    HeScore(i) = heCos;
    SheScore(i) = sheCos;
end

%% random word scoring (or n-most occuring)

randomWords = vectors;
randEmotionScore = [];
randPosScore = [];
randNegScore = [];
randGenderScore = [];
randHeScore = [];
randSheScore = [];
% The lower down the list of words a given word
% is the less it has occured within the 
% embedding. Using the top 100000 occuring
% words ensures for well defined words to be 
% tested. Using all words provides similar
% results
maxWords = length(cellNames);
for i = 1:100000
    randomWords(i,:) = randomWords(i,:)/norm(randomWords(i,:));
    posCos = posmean * randomWords(i,:)';
    negCos = negmean * randomWords(i,:)';
    randEmotionScore(i) = posCos - negCos;
    randPosScore(i) = posCos;
    randNegScore(i) = negCos;
    
    heCos = hemean * randomWords(i,:)';
    sheCos = shemean * randomWords(i,:)';
    randGenderScore(i) = heCos - sheCos;
    randHeScore(i) = heCos;
    randSheScore(i) = sheCos;
end

%% Random Word Pair Subtraction and Comparing Colours to Distributions

% Change this to "randEmotionScore" if you wish to look at valence
% differences
randVecs = randGenderScore;
% change this to "emotionScore" if you wisht o look at valence differences
coloursToSub = genderScore;


pairNum = 100000;
sampleIdxs = randi([1, pairNum], pairNum, 2);
vecsToSub = [randVecs(sampleIdxs(:,1)); randVecs(sampleIdxs(:,2))]';
randDiffs = [];
for i = 1:pairNum
    randDiffs(i) = (vecsToSub(i,1) - vecsToSub(i,2));
end
sortedDiffs = sort(randDiffs, 'descend');

colourDiffs = [];
for i = 1:colourListSize
    for j = 1:colourListSize
        colourDiffs(i,j) = (coloursToSub(i) - coloursToSub(j));
    end
end

posInList = [];
percentiles = [];
sig = ones(11,11)*0.5;
for i = 1:colourListSize
    for j = 1:colourListSize
        [~, index] = min(abs(sortedDiffs - colourDiffs(i,j)));
        posInList(i,j) = index;
        percentiles(i,j) = index/pairNum;
        if percentiles(i,j) > 0.975
            sig(i,j) = percentiles(i,j);
        elseif percentiles(i,j) < 0.025
            sig(i,j) = percentiles(i,j);
        end 
    end
end

%these visualisations are just for easy access to show the significant
%results
figure;
heatmap(colourList, colourList, percentiles);
figure;
heatmap(colourList,colourList,sig);
figure;
heatmap(colourList,colourList, colourDiffs);


%% Color Diff T-Test - Sanity Checking Deviations for Significance

SignificantMat = zeros(11,11);
PercentileMat = zeros(11,11);
for i = 1:colourListSize
    for j = 1:colourListSize
        [h1, p1] = ttest2(colourDiffs(i,j), randDiffs, "Tail", "left", "Alpha", 0.025);
        SignificantMat(i,j) = -h1;
        [h2, p2] = ttest2(colourDiffs(i,j), randDiffs, "Tail", "right", "Alpha", 0.025);
        SignificantMat(i,j) = -h1 + h2;
        PercentileMat(i,j) = min(p1, p2);
    end
end
%these visualisations are just for easy access to show the significant
%results
figure;
heatmap(colourList, colourList, SignificantMat);
figure;
heatmap(colourList, colourList, PercentileMat);


%% Threshold Calculations of Significance

meanThresh = mean(randDiffs);
stdDevThresh = std(randDiffs);
minThreshold = meanThresh - 2*stdDevThresh;
maxThreshold = meanThresh + 2*stdDevThresh;
threeTresholdMin = meanThresh - 3*stdDevThresh
threeTresholdMax = meanThresh + 3*stdDevThresh