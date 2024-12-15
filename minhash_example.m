clear;

load mats/stcoksFeatures.mat
load mats/minhash.mat

%% gen user hashes

user_stocks = {'CTGO', 'AAPL', 'CSGP'}; % Example of multiple stocks
portfolioIndices = find(ismember(data.Symbol, user_stocks));

min_hashes = inf(length(portfolioIndices), k);
for idx = 1:length(portfolioIndices)
    cur = dic2{portfolioIndices(idx)};
    
    min_hash = inf(1, k);
    for s = 1:length(cur) - shingle_sz + 1
        chave = cur(s:s+shingle_sz - 1);
        temp = string2hash_aux(chave, k);

        min_hash = min(min_hash, temp);
    end
    min_hashes(idx, :) = min_hash;
end

%% calc distances

nStocks = length(data.Symbol);
J = zeros(length(portfolioIndices), nStocks);
h = waitbar(0,'Calculating Distances');
tic
for pIdx = 1:length(portfolioIndices)
    for n1 = 1:nStocks
        waitbar(((pIdx - 1) * nStocks + n1) / (length(portfolioIndices) * nStocks), h);
        J(pIdx, n1) = 1 - sum(M(n1,:) == min_hashes(pIdx, :)) / k;
    end
end
deltatime_j = toc;
delete (h)

%% Aggregate results for multiple stocks
average_J = mean(J, 1); % Average distance across all user stocks

[a, b] = sort(average_J);
a = a(1:5);
b = b(1:5);

data.Symbol(b)
dic2(b)
