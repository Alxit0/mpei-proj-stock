
load mats/stcoksFeatures.mat

stockData = data;

stockData.Sector = cellstr(stockData.Sector);
stockData.Industry = cellstr(stockData.Industry);
stockData.Country = cellstr(stockData.Country);
stockData.MarketCap = cellstr(stockData.MarketCap);

dic2 = strcat(stockData.Sector, '_', stockData.Industry, '_', stockData.Country, '_', stockData.MarketCap);
dic = dic2(:,1);
% dic = unique(dic);
nMovies = length(dic);

shingle_sz = 3;
k = 200;
M = inf(nMovies, k);
h = waitbar(0,'Calculating MinHash Table');

tic
for n1= 1:nMovies
    waitbar(n1/nMovies, h);
    cur = dic{n1};
    for s = 1:length(cur) - shingle_sz + 1
        chave = cur(s:s+shingle_sz - 1);
        temp = string2hash_aux(chave, k);

        M(n1, :) = min(M(n1, :), temp);
    end
end
deltatime_hash = toc;
delete (h)

%%

user_stock = 'CTGO';
portfolioIndices = find(ismember(stockData.Symbol, user_stock));
cur = dic2{portfolioIndices};

min_hash = inf(1, k);
for s = 1:length(cur) - shingle_sz + 1
    chave = cur(s:s+shingle_sz - 1);
    
    temp = string2hash_aux(chave, k);

    min_hash = min(min_hash, temp);
end

min_hash

%%

J = zeros(1, nMovies);
h = waitbar(0,'Calculating Distances');
tic
for n1= 1:nMovies
    waitbar(n1/nMovies, h);
    J(n1) = 1 - sum(M(n1,:) == min_hash) / k;
end
deltatime_j = toc;
delete (h)


[a, b] = sort(J);
a = a(1:5);
b = b(1:5);
stockData.Symbol(b)
dic2(b)

