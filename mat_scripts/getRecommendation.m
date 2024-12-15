function recommendedStock = getRecommendation(companyInfo, bloomFilterOwned, bloomFilterRejected, numHashes)
    % Prompt user for desired stock features
    fprintf('Enter the details of the stock you are looking for:\n');
    userCountry = input('Country index (1, 2, ...): ');
    userSector = input('Sector index (1, 2, ...): ');
    userIndustry = input('Industry index (1, 2, ...): ');
    userMarketCap = input('Market Cap category (1-6, as per predefined windows): ');

    userFeatures = [userCountry, userSector, userIndustry, userMarketCap];

    % Load Naïve Bayes data
    data = load('naiveBaseTable.mat');
    features = data.features;
    target = data.target;
    priorProb = data.priorProb;
    conditionalProb = data.conditionalProb;
    uniqueMoves = data.uniqueMoves;

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

    % Filter stocks with the recommended "Move"
    stockIndices = find(target == recommendedMove);
    candidateStocks = companyInfo(stockIndices, :);

    % Select a stock that is neither owned nor rejected
    availableStocks = {};
    for i = 1:height(candidateStocks)
        stockSymbol = candidateStocks.Symbol{i};
        isOwned = checkElemento(bloomFilterOwned, stockSymbol, numHashes);
        isRejected = checkElemento(bloomFilterRejected, stockSymbol, numHashes);

        if ~isOwned && ~isRejected
            availableStocks{end + 1} = stockSymbol; %#ok<AGROW>
        end
    end

    % Return a recommendation or an empty string if none available
    if isempty(availableStocks)
        recommendedStock = '';
    else
        recommendedStock = availableStocks{randi(length(availableStocks))};
    end
end