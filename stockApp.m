function stockApp()
    % Main application to manage stock recommendations

    % Load stock information
    companyInfo = readtable('./data/company_info.csv');
    allSymbols = companyInfo.Symbol;

    % Add path to mat_scripts for auxiliary functions
    addpath('./mat_scripts');

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
        disp("\n --- Stock Recommendation System ---");
        disp("1. Get a recommendation");
        disp("2. View my stocks (owned and rejected)");
        disp("3. Exit");
        option = input("Choose an option: ", 's');
    
        if strcmp(option, "1")
            % Get stock recommendation
             recommendedStock = getRecommendation(companyInfo, bloomFilterOwned, bloomFilterRejected, numHashes);

            if isempty(recommendedStock)
                disp("No stocks available for recommendation.");
            else
                fprintf("Recommended stock: %s\n", recommendedStock);
    
                % Ask user for action on the recommendation
                decision = input("Do you want to accept (a) or reject (r) this stock? (a/r): ", 's');
    
                if strcmp(decision, 'a')
                    bloomFilterOwned = addElemento(bloomFilterOwned, recommendedStock, numHashes);
                elseif strcmp(decision, 'r')
                    bloomFilterRejected = addElemento(bloomFilterRejected, recommendedStock, numHashes);
                else
                    disp("Invalid decision. No updates made.");
                end
            end
    
        elseif strcmp(option, "2")
            % View owned and rejected stocks
            viewMyStocks(allSymbols, bloomFilterOwned, bloomFilterRejected, numHashes);
    
        elseif strcmp(option, "3")
            % Exit application
            disp("Exiting application...");
            break;
        else
            disp("Invalid option. Please try again.");
        end
    end

    % Save Bloom Filters
    save('./mat_scripts/bloomFilterOwned.mat', 'bloomFilterOwned');
    save('./mat_scripts/bloomFilterRejected.mat', 'bloomFilterRejected');
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


