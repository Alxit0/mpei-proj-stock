function prepareRawData(dataDir)
    % Prepare stock feature data and save it

    % Load data
    dataPath = fullfile(dataDir, 'company_info.csv');
    data = readtable(dataPath);

    % Convert columns to categorical
    data.Country = categorical(data.Country);
    data.Sector = categorical(data.Sector);
    data.Industry = categorical(data.Industry);
    data.Move = categorical(data.Move);

    % Define Market Cap categories
    marketCapTags = [">200B", "10 - 200B", "2B - 10B", "300M - 2B", "50M - 300M", "<50M"];
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

    % Assign Market Cap categories
    data.MarketCap = categorical(marketCapWindows);

    % Save to file in the current script directory
    save('./mat_scripts/stocksFeatures.mat', 'data', 'marketCapTags');
    disp('Stock features prepared and saved in the current directory.');
end
