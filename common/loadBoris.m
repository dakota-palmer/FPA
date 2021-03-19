% [labels, start, stop] = loadBoris(filename)
% epochs = loadBoris(filename)
% Returns a list of event epochs generated by BORIS:
% https://github.com/olivierfriard/BORIS

% 2021-02-26. Leonardo Molina.
% 2021-03-19. Last modified.
function varargout = loadBoris(filename)
    % Search for the header line.
    fid = fopen(filename, 'r');
    nHeaderLines = 0;
    searching = true;
    while searching
        line = fgetl(fid);
        if line == -1
            found = false;
            searching = false;
        else
            nHeaderLines = nHeaderLines + 1;
            if ~isempty(regexp(line, "\<Time\>.*\<Media file path\>.*\<Subject\>.*\<Behavior\>.*\<Status\>", 'match', 'once'))
                % Header must contain all the following: "Time" "Media file path" "Subject" "Behavior" and "Status".
                found = true;
                searching = false;
            end
        end
    end
    if found
        % Header is separated by tabs.
        header = strsplit(line, '\t');
        % Read all columns as text.
        format = repmat({'%s'}, size(header));
        % Some columns are expected to be numeric.
        [format{ismember(header, {'Time', 'Total length', 'FPS'})}] = deal('%f');
        format = [format{:}];
        % Target columns.
        [~, columns] = intersect(header, {'Behavior', 'Status', 'Time'});
        % Reset cursor.
        fseek(fid, 0, 'bof');
        % Read, sort columns, and assign.
        data = textscan(fid, format, 'Delimiter', '\t', 'HeaderLines', nHeaderLines);
        data = data(columns);
        time = cat(1, data{3});
        labels = data{1};
        status = (data{2} == "STOP") + 1;
        
        % Sort data so that every behavior starts and stops in consecutive rows.
        fseek(fid, 0, 'bof');
        format = repmat('%s', size(header));
        % Read time as text to find the largest decimal count.
        data = textscan(fid, format, 'Delimiter', '\t', 'HeaderLines', nHeaderLines);
        timeText = data{columns(3)};
        decimalsText = regexp(timeText, '\.(\d+)', 'tokens', 'once');
        decimalsText = [decimalsText{:}];
        decimalsCount = cellfun(@numel, decimalsText);
        % Define function for padding with zeros.
        padLeft = @(s, n) sprintf('%0*s', n, s);
        fixRight = @(x, n) sprintf('%.*f', n, x);
        pad = @(x, l, r) padLeft(fixRight(x, r), l + r + 1);
        % Pad left according to largest integer.
        nLeft = numel(num2str(ceil(max(time))));
        % Pad right accorting to largest decimal count.
        nRight = max(decimalsCount);
        % Create a time string that can be sorted alphabetically.
        timeUID = arrayfun(@(x) pad(x, nLeft, nRight), time, 'UniformOutput', false);
        % Create a row string that can be sorted alphabetically by label > time > status.
        uid = [labels, timeUID, num2cell(num2str(status))]';
        uid = strcat(uid(1, :), uid(2, :), uid(3, :));
        [~, order] = sort(uid);
        start = time(order(1:2:end));
        stop = time(order(2:2:end));
        stop(end + 1:numel(start)) = Inf;
        labels = labels(order(1:2:end));
        
        if nargout == 1
            uLabels = unique(labels);
            nLabels = numel(uLabels);
            epochs = cell(1, 2 * nLabels);
            epochs(1:2:end) = uLabels;
            for u = 1:nLabels
                label = uLabels{u};
                k = ismember(labels, label);
                epochs{2 * u} = [start(k), stop(k)]';
            end
            varargout = {epochs};
        else
            varargout = {labels, start, stop};
        end
    else
        varargout = {{}, zeros(0, 1), zeros(0, 1)};
    end
end