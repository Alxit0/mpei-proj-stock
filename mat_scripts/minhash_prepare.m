function minhash_prepare(dataDir)
    % Prepare MinHash signatures and distance matrix for stocks

    % Load stock features
    load('stocksFeatures.mat', 'data');

    % Convert features to strings for MinHash
    stockData = data;
    stockData.Sector = cellstr(stockData.Sector);
    stockData.Industry = cellstr(stockData.Industry);
    stockData.Country = cellstr(stockData.Country);
    stockData.MarketCap = cellstr(stockData.MarketCap);

    dic2 = strcat(stockData.Sector, '_', stockData.Industry, '_', stockData.Country, '_', stockData.MarketCap);
    dic = dic2(:, 1);
    nStocks = length(dic);

    % MinHash parameters
    shingle_sz = 3;
    k = 200;
    M = inf(nStocks, k);

    % Generate MinHash signatures
    h = waitbar(0, 'Calculating MinHash Table');
    for n1 = 1:nStocks
        waitbar(n1 / nStocks, h);
        cur = dic{n1};
        for s = 1:length(cur) - shingle_sz + 1
            chave = cur(s:s + shingle_sz - 1);
            temp = string2hash_aux(chave, k);

            M(n1, :) = min(M(n1, :), temp);
        end
    end
    delete(h);

    % Calculate distances between stocks
    D = zeros(nStocks, nStocks);
    h = waitbar(0, 'Calculating Pairwise Distances');
    for i = 1:nStocks
        waitbar(i / nStocks, h);
        for j = i:nStocks
            D(i, j) = 1 - sum(M(i, :) == M(j, :)) / k;
            D(j, i) = D(i, j); % Symmetric matrix
        end
    end
    delete(h);

    % Save results in the current script directory
    save('./mat_scripts/minhash.mat', 'M', 'k', 'shingle_sz', 'dic2', 'D');
    disp('MinHash data saved in the current directory.');
end
