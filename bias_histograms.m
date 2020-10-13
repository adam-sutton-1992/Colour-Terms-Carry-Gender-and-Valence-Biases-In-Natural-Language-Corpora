%% loading liwc from text file and LIWC mean vectors
load fullVectors/glove.6B.300d.mat
load liwcMeans.mat
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
%% Get test words and normalize while assigning colour values for them
colourList = {'red', 'blue', 'green', 'yellow', 'orange', 'pink', 'brown', 'white', 'black', 'purple', 'grey'};
colourListSize = length(colourList);
otherWords = {'nun', 'priest', 'life', 'death', 'happy', 'sad', 'night', 'day'};
otherListSize = length(otherWords);
wordList = horzcat(colourList, otherWords);
wordListSize = length(wordList);
testVecs = [];
for i = 1:wordListSize
    testVecs(i,:) = vectors(find(cellfun(cellfind(wordList(i)),cellNames)),:);
    testVecs(i,:) = testVecs(i,:)/norm(testVecs(i,:));
end

%Graphic values of colours
coloursVals = [[1 0 0];[0 0 1]; [0 1 0]; [1 1 0]; [1 0.647 0]; [1 0.411 0.705]; 
    [0.647 0.164 0.164]; [1 0.9 0.9]; [0 0 0];[0.501 0 0.501]; [0.501 0.501 0.501]];
%% Finding distributions of n-most occuring words

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

posMu = mean(randPosScore);
negMu = mean(randNegScore);
heMu = mean(randHeScore);
sheMu = mean(randSheScore);
emotionMu = mean(randEmotionScore);
genderMu = mean(randGenderScore);

posStd = std(randPosScore);
negStd = std(randNegScore);
heStd = std(randHeScore);
sheStd = std(randSheScore);
emotionStd = std(randEmotionScore);
genderStd = std(randGenderScore);

%% Testing Words for all associations and biases
emotionScore = [];
genderScore = [];
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

%% Visualising results - Gender
% chosing data set
mu = genderMu;
sigma = genderStd;
score = genderScore;
histData = randGenderScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Gender Score of Embedded Words")
xlabel("Score");
box on;

%% Visualising results - Gender
% chosing data set
mu = emotionMu;
sigma = emotionStd;
score = emotionScore;
histData = randEmotionScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Female Score of Embedded Words")
xlabel("Score");
box on;
%% Visualising results - He
% chosing data set
mu = heMu;
sigma = heStd;
score = HeScore;
histData = randHeScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Affective Score of Embedded Words")
xlabel("Score");
box on;
%% Visualising results - She
% chosing data set
mu = sheMu;
sigma = sheStd;
score = SheScore;
histData = randSheScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Male Score of Embedded Words")
xlabel("Score");
box on;

%% Visualising results - Pos
% chosing data set
mu = posMu;
sigma = posStd;
score = PosScore;
histData = randPosScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Positive Score of Embedded Words")
xlabel("Score");
box on;

%% Visualising results - Neg
% chosing data set
mu = negMu;
sigma = negStd;
score = NegScore;
histData = randNegScore;

% calculating pdf
bins = round(sqrt(length(histData)));
[f, x] = hist(histData, bins);
pd = fitdist(histData', "normal");
y = pdf(pd, x);

dx = diff(x(1:2));
figure;
bar(x, f/sum(f*dx), 'FaceAlpha', 0.15, 'FaceColor', [0.5, 0.5, 0.5]);
hold on;
y = y/sum(y*dx);
plot(x,y, 'LineWidth', 2.0, 'Color', [0.85 0.325 0.0980]);
xlim([pd.mu - pd.std *5 pd.mu + pd.std *5])

stds = [pd.mu - 3*pd.sigma, pd.mu - 2*pd.sigma, pd.mu + 2*pd.sigma, pd.mu + 3*pd.sigma];
hold on;
impulse = max(y);
for i = 1:4
    plot([stds(i),stds(i)], [0,impulse], 'LineWidth', 1.5, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility','off');
end
for i = colourListSize+1:otherListSize+colourListSize
    plot(score(i), 0, 'Marker', 'diamond', 'MarkerSize', 8, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
for i = 1:colourListSize
    plot(score(i), 0, 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
    text(score(i), 0.25, wordList(i), "FontSize", 12, "Rotation", 90);
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)*5;
ax_width = outerpos(3) - ti(1) - ti(3)-0.01;
ax_height = outerpos(4) - ti(2)*6 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'units', 'centimeters', 'position',[0,0,20.88,9.05]);
title("Negative Score of Embedded Words")
xlabel("Score");
box on;
%% Visualising results - 2D Histogram
% The visualisation here if of two independant 
% 1D histograms, no thought should be given 
% to the relationship between the two variables

figure;
plot([genderMu, genderMu], [-1,1], "black");
hold on;
plot([-1,1], [emotionMu, emotionMu], "black");
plot([genderMu - genderStd*2, genderMu - genderStd*2], [emotionMu - emotionStd*2,emotionMu + emotionStd*2], "--b");
plot([genderMu - genderStd*3, genderMu - genderStd*3], [emotionMu - emotionStd*3,emotionMu + emotionStd*3], "--r");
plot([genderMu + genderStd*2, genderMu + genderStd*2], [emotionMu - emotionStd*2,emotionMu + emotionStd*2], "--b");
plot([genderMu + genderStd*3, genderMu + genderStd*3], [emotionMu - emotionStd*3,emotionMu + emotionStd*3], "--r");
plot([genderMu - genderStd*2, genderMu + genderStd*2], [emotionMu - emotionStd*2, emotionMu - emotionStd*2], "--b");
plot([genderMu - genderStd*3, genderMu + genderStd*3], [emotionMu - emotionStd*3, emotionMu - emotionStd*3], "--r");
plot([genderMu - genderStd*2, genderMu + genderStd*2], [emotionMu + emotionStd*2, emotionMu + emotionStd*2], "--b");
plot([genderMu - genderStd*3, genderMu + genderStd*3], [emotionMu + emotionStd*3, emotionMu + emotionStd*3], "--r");
for i = colourListSize+1:otherListSize+colourListSize
    plot(genderScore(i), emotionScore(i), 'Marker', 'diamond', 'MarkerSize', 14, 'MarkerFaceColor',  'none', 'MarkerEdgeColor',  'k', 'DisplayName', char(wordList(i)));
    text(genderScore(i)+0.012, emotionScore(i), wordList(i), "FontSize", 12);
end
for i = 1:colourListSize
    plot(genderScore(i), emotionScore(i), 'Marker', 'o', 'MarkerSize', 14, 'MarkerFaceColor',  coloursVals(i,:), 'MarkerEdgeColor', coloursVals(i,:), 'DisplayName', char(wordList(i)));
%     text(genderScore(i), emotionScore(i), wordList(i), "FontSize", 12);
end
xlabel("Gender Bias");
ylabel("Valence Bias");
xlim([genderMu - genderStd*4, genderMu + genderStd * 4])
ylim([emotionMu - emotionStd*4, emotionMu + emotionStd * 4])
%% Squareform Pdist Colours
scores = emotionScore(1:colourListSize);
square = squareform(pdist(scores', @distfun));
words = zeros(colourListSize, colourListSize);
for i = 1:colourListSize
    for j = 1:colourListSize
        words(i,j) = scores(i) - scores(j);
    end
end
