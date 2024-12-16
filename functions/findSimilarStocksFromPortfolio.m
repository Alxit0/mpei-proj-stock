function recommendedStock = findSimilarStocksFromPortfolio(allSymbols, bloomFilterOwned, bloomFilterRejected)
    % Load MinHash data
    load('./mats/stocksFeatures.mat', 'data');
    load('./mats/minhash.mat', 'D', 'dic2');

    % Get user's owned stocks
    portfolioStocks = {};
    for i = 1:length(allSymbols)
        if bloomCheckElemento(bloomFilterOwned, allSymbols{i}, 7)
            portfolioStocks{end + 1} = allSymbols{i};
        end
    end

    ignoreStocks = {};
    for i = 1:length(allSymbols)
        if bloomCheckElemento(bloomFilterOwned, allSymbols{i}, 7) ||  bloomCheckElemento(bloomFilterRejected, allSymbols{i}, 7)
            ignoreStocks{end + 1} = allSymbols{i};
        end
    end

    if isempty(portfolioStocks)
        fprintf("You don't have any owned stocks to calculate similarities.\n");
        return;
    end

    % Find indices of portfolio stocks
    portfolioIndices = find(ismember(data.Symbol, portfolioStocks));
    ignoreIndices = find(ismember(data.Symbol, ignoreStocks));

    % Compute average distances
    J = D(portfolioIndices, :);
    average_J = mean(J, 1);

    % Sort distances to find top similar stocks
    [~, sortedIndices] = sort(average_J);
    sortedIndices = setdiff(sortedIndices, ignoreIndices, 'stable'); % Remove owned stocks

    % Display top 5 similar stocks
    fprintf('\nTop 5 similar stocks based on your portfolio:\n');
    for i = 1:min(5, length(sortedIndices))
        fprintf('%s\n', data.Symbol{sortedIndices(i)});
    end

    recommendedStock = data.Symbol{sortedIndices(1)};
end
