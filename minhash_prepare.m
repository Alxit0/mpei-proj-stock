
load mats/stcoksFeatures.mat

stockData = data;

stockData.Sector = cellstr(stockData.Sector);
stockData.Industry = cellstr(stockData.Industry);
stockData.Country = cellstr(stockData.Country);
stockData.MarketCap = cellstr(stockData.MarketCap);

dic2 = strcat(stockData.Sector, '_', stockData.Industry, '_', stockData.Country, '_', stockData.MarketCap);
dic = dic2(:,1);
nStocks = length(dic);

shingle_sz = 3;
k = 200;
M = inf(nStocks, k);
h = waitbar(0,'Calculating MinHash Table');

tic
for n1= 1:nStocks
    waitbar(n1/nStocks, h);
    cur = dic{n1};
    for s = 1:length(cur) - shingle_sz + 1
        chave = cur(s:s+shingle_sz - 1);
        temp = string2hash_aux(chave, k);

        M(n1, :) = min(M(n1, :), temp);
    end
end
deltatime_hash = toc;
delete (h)

nStocks = length(dic); % Number of stocks
D = zeros(nStocks, nStocks); % Initialize distance matrix
h = waitbar(0, 'Calculating Pairwise Distances'); % Progress bar
tic

% Iterate over all stock pairs
for i = 1:nStocks
    waitbar(i/nStocks, h);
    for j = i:nStocks % Only calculate upper triangular part
        % Calculate Jaccard distance based on MinHash
        D(i, j) = 1 - sum(M(i, :) == M(j, :)) / k;
        D(j, i) = D(i, j); % Symmetric distance matrix
    end
end

deltatime_dist = toc;
delete(h);

% Save the distance matrix for future use
save('mats/stock_distances.mat', 'D', 'deltatime_dist');


save mats/minhash M k shingle_sz dic2 D