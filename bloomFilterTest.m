
% Test Bloom Filter using stock symbols from the dataset
dataPath = './data/company_info.csv';

% Tamanho do Bloom Filter
n = 8000;

% Número de funções hash
k = 3;

% Número de chaves a inserir no filtro
numKeys = 1000;
% Load stock symbols
data = readtable(dataPath);
symbols = upper(string(data.Symbol)); % Convert to uppercase
N = length(symbols); % Total number of stocks

if numKeys > N
    error('Number of keys to insert (numKeys) exceeds available stock symbols.');
end

% Split symbols into keys to insert (keys1) and keys to test (keys2)
keys1 = symbols(1:numKeys);
keys2 = symbols(numKeys+1:end);

% Initialize Bloom Filter
filtro = inicFiltro(n);

% Insert keys into Bloom Filter
for i = 1:length(keys1)
    filtro = addElemento(filtro, keys1{i}, k);
end

% Test false negatives
falsoneg = 0;
for i = 1:length(keys1)
    if ~checkElemento(filtro, keys1{i}, k)
        falsoneg = falsoneg + 1;
    end
end
fprintf('False Negatives: %d\n', falsoneg);

% Test false positives
falsopos = 0;
for i = 1:length(keys2)
    if checkElemento(filtro, keys2{i}, k)
        falsopos = falsopos + 1;
    end
end
falsopos_rate = (falsopos / length(keys2)) * 100;
fprintf('False Positive Rate: %.2f%%\n', falsopos_rate);

% Theoretical false positive rate
pfp_teorico = (1 - (1 - 1/n)^(k*numKeys))^k * 100;
fprintf('Theoretical False Positive Rate: %.2f%%\n', pfp_teorico);

% Plot false positive rates for varying k
ks = 4:10;
falsopos_lst = zeros(1, length(ks));
falsopos_teorico_lst = zeros(1, length(ks));

for i = 1:length(ks)
    filtro = inicFiltro(n);
    for j = 1:length(keys1)
        filtro = addElemento(filtro, keys1{j}, ks(i));
    end
    falsopos = 0;
    for j = 1:length(keys2)
        if checkElemento(filtro, keys2{j}, ks(i))
            falsopos = falsopos + 1;
        end
    end
    falsopos_teorico_lst(i) = ((1 - (1 - 1/n)^(ks(i)*numKeys))^ks(i)) * 100;
    falsopos_lst(i) = (falsopos / length(keys2)) * 100;
end

% Plot results
figure;
plot(ks, falsopos_lst, 'y', 'DisplayName', 'Practical False Positives');
hold on;
plot(ks, falsopos_teorico_lst, 'b', 'DisplayName', 'Theoretical False Positives');
xlabel('Number of Hash Functions (k)');
ylabel('False Positive Rate (%)');
legend('show');
hold off;
