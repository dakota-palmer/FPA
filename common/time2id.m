% id = time2id(time, epochs)
% Returns the index in time where time is enclosed by the given epochs
% (from1, to1, from2, to2, ...).

% 2019-02-01. Leonardo Molina.
% 2021-02-26. Last modified.
function [ids, limits] = time2id(time, epochs)
    epochs = epochs(:);
    % timeLimits = zeros(2, nEpochs);
    a = arrayfun(@(k) find(time >= k, 1, 'first'), epochs(1:2:end), 'UniformOutput', false);
    b = arrayfun(@(k) find(time <= k, 1, 'last'), epochs(2:2:end), 'UniformOutput', false);
    k = cellfun(@isempty, a) | cellfun(@isempty, b);
    a(k) = [];
    b(k) = [];
    nEpochs = numel(a);
    limits = zeros(2, nEpochs);
    limits(1:2:end) = [a{:}];
    limits(2:2:end) = [b{:}];
    ids = arrayfun(@(e) colon(limits(1, e), limits(2, e))', 1:nEpochs, 'UniformOutput', false);
    ids = cat(1, ids{:});
end