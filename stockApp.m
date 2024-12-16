function stockApp()
    dataDir = './data';

    % Load stock information
    companyInfo = readtable(fullfile(dataDir, 'company_info.csv'));
    allSymbols = upper(companyInfo.Symbol); % Convert to uppercase

    % Add path to mat_scripts for auxiliary functions
    addpath('./bloom');
    addpath('./functions');

    % Bloom Filter Parameters
    filterSize = 1000; % Bloom Filter size
    numHashes = 7; % Number of hash functions

    % Initialize Bloom Filters
    bloomFilterOwned = inicFiltro(filterSize);
    bloomFilterRejected = inicFiltro(filterSize);

    % Step 1: Initialize filters with user input
    [bloomFilterOwned, bloomFilterRejected] = initializeFilters(allSymbols, bloomFilterOwned, bloomFilterRejected, numHashes);

    % Main loop for interaction
    while true
        fprintf("\n--- Stock Recommendation System ---\n");
        fprintf("1. Get a recommendation\n");
        fprintf("2. View my stocks (owned and rejected)\n");
        fprintf("3. Find similar stocks (MinHash)\n");
        fprintf("4. Find similar stocks based on portfolio\n");
        fprintf("5. Exit\n");

        option = input("Choose an option: ", 's');

        if strcmp(option, "1")
            % Get stock recommendation
            recommendedStock = getRecommendation(companyInfo, bloomFilterOwned, bloomFilterRejected, numHashes);

            if isempty(recommendedStock)
                fprintf("No stocks available for recommendation.\n");
            else
                fprintf("Recommended stock: %s\n", recommendedStock);

                % Ask user for action on the recommendation
                decision = input("Do you want to accept (a) or reject (r) this stock? (a/r): ", 's');

                if strcmp(decision, 'a')
                    bloomFilterOwned = addElemento(bloomFilterOwned, recommendedStock, numHashes);
                elseif strcmp(decision, 'r')
                    bloomFilterRejected = addElemento(bloomFilterRejected, recommendedStock, numHashes);
                else
                    fprintf("Invalid decision. No updates made.\n");
                end
            end

        elseif strcmp(option, "2")
            % View owned and rejected stocks
            viewMyStocks(allSymbols, bloomFilterOwned, bloomFilterRejected, numHashes);

        elseif strcmp(option, "3")
            % Prompt user for portfolio stocks
            userStocksInput = input('Enter your portfolio stocks (comma-separated): ', 's');
            userStocks = strsplit(userStocksInput, ',');
            userStocks = strtrim(upper(userStocks)); % Remove spaces and convert to uppercase
            findSimilarStocks(userStocks);

        elseif strcmp(option, "4")
            % Find similar stocks based on portfolio
            findSimilarStocksFromPortfolio(allSymbols, bloomFilterOwned);

        elseif strcmp(option, "5")
            fprintf("Exiting application...\n");
            break;
        else
            fprintf("Invalid option. Please try again.\n");
        end
    end

    % Save Bloom Filters in mat_scripts
    save('./mats/bloomFilterOwned.mat', 'bloomFilterOwned');
    save('./mats/bloomFilterRejected.mat', 'bloomFilterRejected');
end


function viewMyStocks(allSymbols, bloomFilterOwned, bloomFilterRejected, numHashes)
    % List owned and rejected stocks based on Bloom Filters

    disp("\n --- Your Stocks ---");

    % Check owned stocks
    disp("Owned stocks:");
    ownedStocks = {};
    for i = 1:length(allSymbols)
        if checkElemento(bloomFilterOwned, allSymbols{i}, numHashes)
            ownedStocks{end + 1} = allSymbols{i}; %#ok<AGROW>
        end
    end
    if isempty(ownedStocks)
        disp("No owned stocks.");
    else
        disp(strjoin(ownedStocks, ', '));
    end

    % Check rejected stocks
    disp("\n Rejected stocks:");
    rejectedStocks = {};
    for i = 1:length(allSymbols)
        if checkElemento(bloomFilterRejected, allSymbols{i}, numHashes)
            rejectedStocks{end + 1} = allSymbols{i}; %#ok<AGROW>
        end
    end
    if isempty(rejectedStocks)
        disp("No rejected stocks.");
    else
        disp(strjoin(rejectedStocks, ', '));
    end
end
