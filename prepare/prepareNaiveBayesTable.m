clear
load mats/stocksFeatures.mat

[data.Country, mapCountry] = grp2idx(data.Country);
[data.Sector, mapSector] = grp2idx(data.Sector);
[data.Industry, mapIndustry] = grp2idx(data.Industry);
data.MarketCap = grp2idx(data.MarketCap);
[data.Move, S] = grp2idx(data.Move); % target

mapMarketCap = {'>200B', '10 - 200B', '2B - 10B', '300M - 2B', '50M - 300M', '<50M'};
% Prepare Data for Naïve Bayes Classifier

features = table2array(data(:, {'Country', 'Sector', 'Industry', 'MarketCap'}));
target = data.Move;

% Get unique categories for the target variable (Move)
uniqueMoves = unique(target);
numClasses = numel(uniqueMoves);

% Calculate prior probabilities P(Move)
priorProb = zeros(numClasses, 1);
for i = 1:numClasses
    priorProb(i) = sum(target == uniqueMoves(i)) / numel(target);
end

% Calculate conditional probabilities P(Feature | Move)
numFeatures = size(features, 2);
conditionalProb = cell(numClasses, numFeatures);

for c = 1:numClasses
    for f = 1:numFeatures
        uniqueFeatureValues = unique(features(:, f));
        conditionalProb{c, f} = zeros(numel(uniqueFeatureValues), 2); % [FeatureValue, Probability]
        for v = 1:numel(uniqueFeatureValues)
            value = uniqueFeatureValues(v);
            conditionalProb{c, f}(v, 1) = value; % Feature value
            conditionalProb{c, f}(v, 2) = sum(features(target == uniqueMoves(c), f) == value) ...
                                           / sum(target == uniqueMoves(c));
        end
    end
end
save mats/naiveBaseTable
