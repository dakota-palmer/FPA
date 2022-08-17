% % fpa = FPA(time, signal, reference, configuration);

%% Define data
%---Single TDT tank
% inputFolder= 'K:\TDT Photometry tanks\DP_DSTrainingv02_TDT2-191203-124106\VP-VTA-FP round 2\VP-VTA-FP17and19-200810-122642'

%% Load 465nm and 405nm.
% signalTitle = 'Dv1A';
% referenceTitle = 'Dv2A';
% % data = loadTDT(inputFolder, {signalTitle, referenceTitle});
% 
% %instead of using loadTDT fxn use another to load everything (including
% %events)
% 
% time = data(:, 1);
% signal = data(:, 2);
% reference = data(:, 3);

%% DP define and load data

%just load from subjDataRaw struct.

load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\VP-VTA-FP-14-Dec-2020subjDataRaw.mat");

%should be able to run code in loop through struct?
subjects= fieldnames(subjData);

for subj=1:numel(subjects);
    for session= 1:numel(subjData.(subjects{subj}))
        
    % clear data between sessions?
        data= [];
        
        time=[]; signal=[]; reference=[]; fpa=[];
        
        data= subjData.(subjects{subj})(session);
        
        % ONLY RUN FOR SPECIFIC STAGES (e.g. limiting to >5 for now since
        % NS absent causes issues)
        if data.trainStage<7
           continue; 
        end
        
        time= data.cutTime'; %transpose for 1 col
        signal= data.reblue;
        reference= data.repurple;
        
%         
%     end %end session loop
% end % end subj loop




%% Epoch definitions.
% citralBaseline = [929 989];
% citral = [989 1049 1049 1109 1109 1169 1169 1229 1229 1289 1825 1885];
% citralPost = [1885 1945 1945 2005];
% bobcatBaseline = [2145 2205];
% bobcat =   [2205 2265 2265 2325 2325 2385 2385 2445 2445 2505 3028 3088];
% bobcatPost = [3088 3148 3148 3208];

% dp adding predefined time windows for events
timeBaseline= 10;
timeCue= 10;
timePost= 10;

% Define Epochs
DS = data.DS;
DSbaseline = DS-timeBaseline;
DSpost = DS+timePost
NS =   data.NS;
NSbaseline = NS-timeBaseline;
NSpost = NS+timePost;

% Note that instead of event timings, 
%Epochs should be pairs of Start:End values? 
% e.g. for DS, if cue 1 starts at 36s and cue 2 starts at 176s
% and you had these timings saved  in an array [36, 176] the epoch would be drawn between those points.


%TODO: add variables for dynamic epoch calculations (e.g. 'DS' 'NS' vs
%separate individualized code)

% Instead, you'd want 36s + cue Duration so if 10s [36,46] for the cue
% epoch. 
cueDur= 10;

%--DS epoch
eventOnset=[]; eventEnd=[]; %clear btwn epochs

eventOnset= DS;
eventEnd= DS+cueDur;


%combine into one array for epochs with alternating start & end
epochDS= nan(size(DS,1)*2,1);

epochDS(1:2:end)= eventOnset; %onsets
epochDS(2:2:end)= eventEnd; %offset

%-- NS epoch
eventOnset=[]; eventEnd=[]; %clear btwn epochs

eventOnset= NS;
eventEnd= NS+cueDur;


%combine into one array for epochs with alternating start & end
epochNS= nan(size(NS,1)*2,1);

epochNS(1:2:end)= eventOnset; %onsets
epochNS(2:2:end)= eventEnd; %offset


% Define Events
%Note distinction between Events and Epochs.

%use str corresponding to fieldnames to dynamically assign

%---**Seems that this fxn doesn't discrim between event types, simply single
%event should be used at a time...

% events= {'pox','lox'};
% events= {'lox'};

events= {'DS','NS'}; %combined cue events

eventTimes=struct; %clear between files

allEvents= [];
for event= events
   eventTimes.(event{:})= data.(event{:});
   
   %concat into single array for FPA() fxn
   allEvents= [allEvents;data.(event{:})] 
end



if isnan(NS)
    %TODO: Eliminate NS Epochs if not present in recording...
%     NS= nan(size(DS));
end



%% Define configuration -----

%- default configuration
configuration = struct();

% configuration.f0 = {@mean, citralBaseline}; %og example
% configuration.f1 = {@std, citralBaseline}; %og example

% %- Z-score mode calculated from all data
% configuration.f0 = @mean;
% configuration.f1 = @std;

% % - z-score - alternative 1 (default):
configuration.f0 = @median;
configuration.f1 = @mad;

%- Z-score calculated during specific epochs?
% configuration.f0 = {@mean, DSbaseline}; %og example
% configuration.f1 = {@std, DSbaseline}; %og example

%- df/f all data points
% configuration.f0 = @mean;
% configuration.f1 = @mean;

% configuration.lowpassFrequency = 10; %og example
% configuration.resamplingFrequency = 100; %og example

%lowpass online at 6hz I think so above this should be fine
configuration.lowpassFrequency = 10;
configuration.resamplingFrequency = nan;

% configuration.baselineEpochs = [0, 3500]; %original example

% % baselineEpochs - Time epochs (s) to include for baseline correction.
% dp assume want to apply to entire duration of recording
%- maybe should be preCue epochs?
configuration.baselineEpochs = [0, time(end)];
% configuration.baselineEpochs = [0, 20]; %looking v weird

% % conditionEpochs - Epochs for different conditions: {'epoch1', [start1, end1, start2, end2, ...], 'epoch2', ...}

%og example
% configuration.conditionEpochs = {'Citral baseline', citralBaseline,
% 'Citral', citral, 'Post citral', citralPost, 'Bobcat baseline',
% bobcatBaseline, 'Bobcat', bobcat, 'Post bobcat', bobcatPost}; 

%--TODO: make list of pairs higher up above for event epochs & labels and
%feed in here for easier adjustment
% configuration.conditionEpochs = {'DS baseline', DSbaseline,...
% 'DS', DS, 'Post DS', DSpost, 'NS baseline',...
% NSbaseline, 'NS', NS, 'Post NS', NSpost}; 

% configuration.conditionEpochs = {'DS', DS, 'NS', NS}; 

% configuration.conditionEpochs = {'DS', DS};
% configuration.conditionEpochs = {'epochDS', epochDS};

configuration.conditionEpochs = {'epochDS', epochDS, 'epochNS', epochNS};


%peakWindow= for peak-trigger avg
configuration.peakWindow = [-5, 10]; 

% configuration.events = [citral(1:2:end), bobcat(1:2:end)];%-og example
% unclear why spacing of 2 used in og example

%clearly my DS and NS epochs are overlapping in plot
% first DS epoch ~36: 176

% configuration.events= [DS, NS];

% configuration.events= [DS(1:2:end), NS(1:2:end)]; 

configuration.events= allEvents;


% configuration.eventWindow = [-1, 29]; %-og example

%eventWindow= for event-trigger avg plots
configuration.eventWindow= [-5, 10];

% Fluorescence deflections are considered peaks when they exceed a threshold calculated as k * f2 + f3 and they are provided by the user as configuration.threshold = {k, f2, f3}
configuration.threshold = {2.91, @mad, @median}; 

configuration.fitReference = true;

% use airPLS or no

configuration.airPLS= false;
% configuration.airPLS= true;



%% Call FPA with given configuration.
fpa = FPA(time, signal, reference, configuration);
cellfun(@warning, fpa.warnings);
fpa.plot();
fpa.export('exported');

        
    end %end session loop
end % end subj loop
