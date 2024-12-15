function [bloomFilterOwned, bloomFilterRejected] = initializeFilters(allSymbols, bloomFilterOwned, bloomFilterRejected, numHashes)
    % Initialize filters for owned and rejected stocks based on user input

    disp('Enter the symbols of owned stocks (separated by commas):');
    ownedInput = input('Example: AAPL, GOOG, TSLA: ', 's');
    ownedStocks = strsplit(upper(ownedInput), ','); % Convert input to uppercase
    
    ownedStocks = strtrim(ownedStocks);

    disp('Enter the symbols of rejected stocks (separated by commas):');
    rejectedInput = input('Example: MSFT, AMZN, NFLX: ', 's');
    rejectedStocks = strsplit(upper(rejectedInput), ','); % Convert input to uppercase
    rejectedStocks = strtrim(rejectedStocks);

    % Validate symbols
    validOwnedStocks = ownedStocks(ismember(ownedStocks, allSymbols));
    validRejectedStocks = rejectedStocks(ismember(rejectedStocks, allSymbols));

    % Add valid stocks to filters
    for i = 1:length(validOwnedStocks)
        bloomFilterOwned = addElemento(bloomFilterOwned, validOwnedStocks{i}, numHashes);
    end

    for i = 1:length(validRejectedStocks)
        bloomFilterRejected = addElemento(bloomFilterRejected, validRejectedStocks{i}, numHashes);
    end

    disp("Bloom Filters initialized successfully.");
end