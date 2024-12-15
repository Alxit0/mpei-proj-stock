clear

data = readtable('./data/company_info.csv');

% categories
data.Country = categorical(data.Country);
data.Sector = categorical(data.Sector);
data.Industry = categorical(data.Industry);
data.Move = categorical(data.Move);

marketCapTags = [">200B", "10 - 200B", "2B - 10B", "300M - 2B", "50M - 300M", "50M - 300M"];
marketCapWindows = zeros(height(data), 1);
for i = 1:height(data)
    if data.MarketCap(i) > 200e9
        marketCapWindows(i) = 1; % >200B
    elseif data.MarketCap(i) > 10e9
        marketCapWindows(i) = 2; % 10 - 200B
    elseif data.MarketCap(i) > 2e9
        marketCapWindows(i) = 3; % 2B - 10B
    elseif data.MarketCap(i) > 300e6
        marketCapWindows(i) = 4; % 300M - 2B
    elseif data.MarketCap(i) > 50e6
        marketCapWindows(i) = 5; % 50M - 300M
    else
        marketCapWindows(i) = 6; % <50M
    end
end

data.MarketCap = categorical(marketCapWindows);

save 'mats/stcoksFeatures' data marketCapTags