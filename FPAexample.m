inputFile = 'data/tf_CP_m307_d2_2.csv';
configuration.timeTitle = 'Time(s)';
configuration.signalTitle = 'AIn-2 - Demodulated(Lock-In)';
configuration.referenceTitle = 'AIn-1 - Demodulated(Lock-In)';
configuration.resamplingFrequency = 20;
configuration.bleachingCorrectionEpochs = [-Inf, 600, 960, Inf];
configuration.conditionEpochs = {'Condition A', [-Inf, 600], 'Condition B', [650, Inf]};
configuration.triggeredWindow = 10;
configuration.f0Function = @movmean;
configuration.f0Window = 10;
configuration.f1Function = @movmean;
configuration.f1Window = 10;
configuration.peaksLowpassFrequency = 0.2;
configuration.thresholdingFunction = @mad;
configuration.thresholdFactor = 0.10;
FPA(inputFile, configuration);