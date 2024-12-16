function recommendedStock = findSimilarStocks(userStocks)
    % Load MinHash data
    load('./mats/stocksFeatures.mat', 'data');
    load('./mats/minhash.mat', 'D', 'dic2');

    % Find indices of user's stocks
    portfolioIndices = find(ismember(data.Symbol, userStocks));

    if isempty(portfolioIndices)
        fprintf('No valid stocks found in your portfolio.\n');
        return;
    end

    % Compute distances for user's stocks
    J = D(portfolioIndices, :);

    % Average distances across all user's stocks
    average_J = mean(J, 1);

    % Sort distances to find top similar stocks
    [sortedDistances, sortedIndices] = sort(average_J);
    
    % Remove user's own stocks from the results
    sortedIndices = setdiff(sortedIndices, portfolioIndices, 'stable');
    topIndices = sortedIndices(1:min(5, length(sortedIndices))); % Get top 5 similar stocks

    % Display top similar stocks
    fprintf('\nTop 5 similar stocks:\n');
    for i = 1:length(topIndices)
        fprintf('%s\n', data.Symbol{topIndices(i)});
    end

    recommendedStock = data.Symbol{topIndices(1)};
end
