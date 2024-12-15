clear;

load mats/stcoksFeatures.mat
load mats/minhash.mat

%% gen user hashes

user_stocks = {'CTGO', 'AAPL'}; % Example of multiple stocks
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

% calc distances
J = D(portfolioIndices, :);

%% Aggregate results for multiple stocks
average_J = mean(J, 1); % Average distance across all user stocks

[a, b] = sort(average_J);
a = a(1:5);
b = b(1:5);

data.Symbol(b)
dic2(b)
