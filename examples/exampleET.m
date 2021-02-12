% Add dependencies.
addpath('..');
addpath(genpath('../common'));

% Fiber-photometry data recorded with Doric DAQ.
inputDataFile = '../data/Doric.csv';
% Columns corresponding to 465nm and 405nm.
signalColumn = 5;
referenceColumn = 3;
data = loadData(inputDataFile);
time = data(:, 1);
signal = data(:, signalColumn);
reference = data(:, referenceColumn);

configuration = struct();
configuration.conditionEpochs = {'Pre', [0, 300], 'During', [300, 550], 'Post', [1010, 1310]};
configuration.baselineEpochs = [0, 300, 1010, Inf];
configuration.thresholdingFunction = @mad;
configuration.thresholdFactor = 2.91;

% Call FPA with given configuration.
results = FPA(time, signal, reference, configuration);
cellfun(@warning, results.warnings);