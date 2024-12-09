clear

data = readtable('./data/company_info.csv');

% categories
data.Country = categorical(data.Country);
data.Sector = categorical(data.Sector);
data.Industry = categorical(data.Industry);
data.Move = categorical(data.Move);

marketCapWindows = zeros(height(data), 1);
for i = 1:height(data)
    if data.MarketCap(i) > 200e9
        marketCapWindows(i) = 1; % >200B
    elseif data.MarketCap(i) > 10e9
        marketCapWindows(i) = 2; % 10 - 200B
    elseif data.MarketCap(i) > 2e9
        marketCapWindows(i) = 3; % 2B - 10B
    elseif data.MarketCap(i) > 300e6
        marketCapWindows(i) = 4; % 300M - 2B
    elseif data.MarketCap(i) > 50e6
        marketCapWindows(i) = 5; % 50M - 300M
    else
        marketCapWindows(i) = 6; % <50M
    end
end

data.MarketCap = categorical(marketCapWindows);

data.Country = grp2idx(data.Country);
data.Sector = grp2idx(data.Sector);
data.Industry = grp2idx(data.Industry);
data.MarketCap = grp2idx(data.MarketCap);
data.Move = grp2idx(data.Move); % target

save mats/naiveBaseTable

%% Prepare Data for Naïve Bayes Classifier

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


%% User Input for Prediction

% input 
fprintf('Enter the following details for the stock:\n');
userCountry = input('Country index (1, 2, ...): ');
userSector = input('Sector index (1, 2, ...): ');
userIndustry = input('Industry index (1, 2, ...): ');
userMarketCap = input('Market Cap category (1-6, as per predefined windows): ');

userFeatures = [userCountry, userSector, userIndustry, userMarketCap];

%% Predict Probabilities
scores = zeros(1, numClasses);
for c = 1:numClasses
    
    scores(c) = priorProb(c);
    
    % multiply by conditional probabilities
    for f = 1:numFeatures
        value = userFeatures(f);
        condProb = conditionalProb{c, f};
        idx = condProb(:, 1) == value;
        if any(idx)
            scores(c) = scores(c) * condProb(idx, 2);
        else
            scores(c) = scores(c) * 0.0001; % mmall smoothing factor for unseen values
        end
    end
end

% normalize scores
scores = scores / sum(scores);

% display probabilities for each Move category
disp('Predicted Probabilities for Move Categories:');
disp(scores);

% Provide user-friendly recommendation based on highest probability
[~, recommendedCategory] = max(scores);
fprintf('The recommended Move category is: %d\n', uniqueMoves(recommendedCategory));
