% Load the stock information table
company_info = readtable('./data/company_info.csv');
allSymbols = company_info.Symbol;

% Bloom Filter Parameters
filterSize = 1000; % Bloom Filter size
numHashes = 7; % Number of hash functions

% Initialize the Bloom Filters
bloomFilterOwned = inicFiltro(filterSize);
bloomFilterRejected = inicFiltro(filterSize);

% Prompt the user to enter owned and rejected stocks
disp('Enter the symbols of owned stocks (separated by commas):');
ownedInput = input('Example: AAPL, GOOG, TSLA: ', 's');
ownedStocks = strsplit(ownedInput, ',');
ownedStocks = strtrim(ownedStocks); % Remove whitespace

disp('Enter the symbols of rejected stocks (separated by commas):');
rejectedInput = input('Example: MSFT, AMZN, NFLX: ', 's');
rejectedStocks = strsplit(rejectedInput, ',');
rejectedStocks = strtrim(rejectedStocks); % Remove whitespace

% Validate symbols against the list of valid symbols
validOwnedStocks = ownedStocks(ismember(ownedStocks, allSymbols));
validRejectedStocks = rejectedStocks(ismember(rejectedStocks, allSymbols));

if isempty(validOwnedStocks) && isempty(validRejectedStocks)
    disp('No valid stocks were entered.');
else
    % Add valid owned stocks to the owned Bloom Filter
    for i = 1:length(validOwnedStocks)
        bloomFilterOwned = addElemento(bloomFilterOwned, validOwnedStocks{i}, numHashes);
    end

    % Add valid rejected stocks to the rejected Bloom Filter
    for i = 1:length(validRejectedStocks)
        bloomFilterRejected = addElemento(bloomFilterRejected, validRejectedStocks{i}, numHashes);
    end

    % Save the filters to .mat files
    save('mats/bloomFilterOwned.mat', 'bloomFilterOwned');
    save('mats/bloomFilterRejected.mat', 'bloomFilterRejected');

    disp('Bloom Filters updated successfully.');
end

% Test if a stock is in the filters
disp('Enter the symbols of stocks to test (separated by commas):');
testStocksInput = input('Example: AAPL, MSFT, META: ', 's');
testStocks = strsplit(testStocksInput, ',');
testStocks = strtrim(testStocks);

for i = 1:length(testStocks)
    isOwned = checkElemento(bloomFilterOwned, testStocks{i}, numHashes);
    isRejected = checkElemento(bloomFilterRejected, testStocks{i}, numHashes);

    if isOwned
        fprintf('The stock %s is owned by the user.\n', testStocks{i});
    elseif isRejected
        fprintf('The stock %s was rejected by the user.\n', testStocks{i});
    else
        fprintf('The stock %s is available for recommendation.\n', testStocks{i});
    end
end
