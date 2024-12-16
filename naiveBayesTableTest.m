clear
load mats/stocksFeatures.mat

[data.Country, mapCountry] = grp2idx(data.Country);
[data.Sector, mapSector] = grp2idx(data.Sector);
[data.Industry, mapIndustry] = grp2idx(data.Industry);
[data.MarketCap, mapMarketCap] = grp2idx(data.MarketCap);
[data.Move, S] = grp2idx(data.Move); % target

%% divede data
n = size(data, 1);
a = randperm(n);

sep = n*0.7 - mod(n*0.7, 1);
treino_data = data(a(1:sep), :);
teste_data = data(a(sep:end), :);

%% treino

% Prepare Data for Naïve Bayes Classifier
features = table2array(treino_data(:, {'Country', 'Sector', 'Industry', 'MarketCap'}));
target = treino_data.Move;

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

%% Teste
hits = 0;
for i=1:size(teste_data, 1)
    userCountry = teste_data(i, :).Country;
    userSector = teste_data(i, :).Sector;
    userIndustry = teste_data(i, :).Industry;
    userMarketCap = teste_data(i, :).MarketCap;

    userFeatures = [userCountry, userSector, userIndustry, userMarketCap];

    % Predict probabilities for the user's specified stock features
    scores = zeros(1, numel(uniqueMoves));
    for c = 1:numel(uniqueMoves)
        scores(c) = priorProb(c); % Start with prior probability

        % Multiply by conditional probabilities
        for f = 1:numel(userFeatures)
            value = userFeatures(f);
            condProb = conditionalProb{c, f};
            idx = condProb(:, 1) == value;

            if any(idx)
                scores(c) = scores(c) * condProb(idx, 2);
            else
                scores(c) = scores(c) * 0.0001; % Small smoothing for unseen values
            end
        end
    end

    % Normalize scores to get probabilities
    scores = scores / sum(scores);

    % Determine the most probable "Move" category
    [~, bestMoveIdx] = max(scores);
    recommendedMove = uniqueMoves(bestMoveIdx);

    if recommendedMove == teste_data(i, :).Move
        hits = hits + 1;
    end
end

perc = hits*100/size(teste_data, 1);
fprintf("Correct guesses: %d / %d (%.2f percent)\n", hits, size(teste_data, 1), perc);