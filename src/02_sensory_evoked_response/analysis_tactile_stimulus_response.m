%%%%% This script provides a guided outline for analyzing your experimental data collected for Experiment 2 (quantifying sensory response to tactile stimulation)
%%%%% Written by A.L. Orsborn, v201219
%%%%%
%%%%%
%%%%% All lines where you have to fill in information is tagged with a comment including "FILLIN". Use this flag to find everything you need to modify.


% we will first load a data file and test our pre-processing and calculations on one file. Once that is complete, we can extend our analysis to all data to examine trends.

%% testing pre-processing and calculations

% Define some basic things to make it easy to find your data files.
% We will want to take advantage of systematic naming structure in our data files.
% Your files should have names like [prefix][date][id #].
% Note that the SpikeRecorder program automatically saves files with date and time in the name.
% We recommend re-naming your files to convert time into a simpler id# e.g. 1, 2, 3...

dataDir = 'C:\Users\metal\Downloads\lab_ee_466\Lab_2_ee_466\Data'; %FILLIN in with the path to where your data is stored

file_prefix = 'BYB_Recording_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '2026-01-20'; %FILLIN with the date string used in your file
file_idnum  = 1; %FILLIN with the numeric value of the file id

full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) file_type];


% load your data file and the sampling rate into matlab into the variables 'data' and FS, respectively.
[data, FS] = audioread(full_file_name);

% check the basic properties of your loaded variables
whos data FS

%note that if you are recording 2 channels instead of 1, your data will have 2 columns (#time points x #channels). Let's create a variable to keep track of how many channels we have so our code is flexible:
num_channels = size(data,2);%FILLIN

% plot 1 second of your data (channels 1 and 2) to assure the loaded file looks correct
figure
plot( data(1:FS,: ) ) %fill in the portion in the brackets to only plot 1 second (hint: you need to take the sampling rate into account)
xlabel('Time, in samples') %fill in the units of the time axis on this plot
ylabel('Voltage (mV)')

%%
% Now let's find spikes and their waveforms in the data.
% use the code you developed in lab 1 for this task (detectSpikes.m)
%note that you may need to modify this function or how you call it if you have two channels of data in your file.
%create a variable spike_times - cell {# channels x 1} with the detected spike times for each channel.
%note: if you recorded multiple channels, you might need a for loop to create the spike_times cell.
%FILLIN with relevant code
threshold = 0.04; %FILLIN (tune if needed)

spike_times = cell(num_channels,1);
spike_waveforms = cell(num_channels,1);

for iCh = 1:num_channels
    [spike_times{iCh}, spike_waveforms{iCh}] = detectSpikes(data(:,iCh), threshold, FS);
end

%inspect your data to convince yourself the function is working as you expect
%Some of the plots we generated in lab 1 may be helpful here (e.g. raw
%traces + detected spike times)

%%

%%%%%
%now we need to learn how to load the 'events' files and analyze our spike data with respect to these events.

%1. load an 'events' file.
%We have provided a shell function for this operation called 'readEventsFile.m' Open it and fill it in.
events_file_type = '-events.txt';
events_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) events_file_type];

[EVENTS, EVENT_TIMES] = readEventsFile(events_file_name);
unique(EVENTS)
whos EVENTS EVENT_TIMES
disp(EVENTS(1:min(20,end)))
disp(EVENT_TIMES(1:min(20,end)))
length(EVENTS), length(EVENT_TIMES)

%%

%2. We now need to write code to "align" our spike times with stimulation trials and make raster plots.
%we've provided a shell function for this operation called
%'trialAlignSpikes.m'. Open this function, fill it in, and then use it here.
align_time = EVENT_TIMES;
time_before = 1;
time_after  = 1;
[aligned_spike_times, aligned_spike_labels] = ...
    trialAlignSpikes(spike_times, align_time, time_before, time_after); %FILLIN based on the function


%now we need to visualize this data by making a raster plot
%In lab0, you wrote a function plotRaster for making these plots. Use it
%here.

%loop through channels to make a figure + subplot with a raster for each
%channel. Save handles of figures so we can add subplot with the PSTH.
fig_handle = figure;
ax_handle(1) = subplot(2,1,1);
plotRaster(aligned_spike_times{1}, aligned_spike_labels{1}, fig_handle, ax_handle(1));
title('Channel 1 Stimulus response');

%3. Next, we need to write code to calculate and plot a PSTH
% To do this, we will convert our spike-times into spike rates ('binning')
% Then, we can compute the average rate across trials (the PSTH).
%
%TECHNICAL NOTE: We could also 'bin' our spikes across all trials together
%(That is, we could do trial-averaging and binning simultaneously in a single calculation).
%These two ways of computing a PSTH are equivalent and equally useful for this dataset.
%In future data analysis (e.g. lab 4), we will explore data with more complex trial structures.
%In that case, binning first and then grouping trials for a PSTH gives a more compact data
%representation (spike rate matrix)that can be mined/explored more flexibly.
%
%We've provided a shell function binTrialAlignedSpikes.m for the binning
%step. Open it and fill it in, then use it here to calculate and plot a
%PSTH

bin_width = 0.01;
[trial_spike_rate, time_bins] = binTrialAlignedSpikes(aligned_spike_times, aligned_spike_labels, time_before, time_after, bin_width);

% Average across trials (works for either shape by checking)
sz = size(trial_spike_rate);
binDim = find(sz == length(time_bins), 1);

if isempty(binDim)
    % time_bins is probably EDGES (N+1), while PSTH bins are N
    % We'll compute centers from edges later, but first find the bins dim as the one close to length(time_bins)-1
    binDim = find(sz == (length(time_bins)-1), 1);
end

% trials dim is the other non-channel dim (since single channel, we can just squeeze and inspect)
trialAvg = squeeze(mean(trial_spike_rate, setdiff(1:ndims(trial_spike_rate), binDim)));

% Ensure column vector
trialAvg = trialAvg(:);

%plot the PSHT along with the raster plots
% ---- SUPPLEMENT: define x to match trialAvg and plot PSTH ----
x = time_bins(:);

if length(x) == length(trialAvg) + 1
    % time_bins are edges, trialAvg is per-bin rate -> use bin centers
    x = x(1:end-1) + diff(x)/2;
elseif length(x) ~= length(trialAvg)
    error('X/Y mismatch: length(time_bins)=%d, length(trialAvg)=%d', length(time_bins), length(trialAvg));
end

psth_time = x;   % save for response calculations later

figure(fig_handle);
ax_handle(2) = subplot(2,1,2);
stairs(psth_time(:), trialAvg(:));
xlabel('Time (s)');
ylabel('Average Firing Rate');
% ------------------------------------------------------------

%I recommend playing around with the bin size to understand how it
%influences our estimate of firing rate and the temporal dynamics.



%4. Finally, let's estimate our stimulus response and look at our
%trial-to-trial variability in response

%Compute the stimulus response by getting the firing rate change
%post-stimulus. Do this both for the trial-averaged response and on a
%single trial basis
baseline_window = [-1 0]; %FILLIN - pick a timewindow for estimating the baseline firing rate
baseline_idx = psth_time>=baseline_window(1) & psth_time<=baseline_window(2);

response_window = [0 0.2]; %FILLIN - pick a time window for estimating the response to tactile stimulus
response_idx = psth_time>=response_window(1) & psth_time<=response_window(2);

trAvg_response = mean(trialAvg(response_idx)) - mean(trialAvg(baseline_idx));

singleTr_response = squeeze(mean(trial_spike_rate(:,response_idx,:),2) - mean(trial_spike_rate(:,baseline_idx,:),2)); %FILLIN

%plot a histogram of single trial responses to look at variability
figure
hist(singleTr_response, 10)
hold on
plot([trAvg_response trAvg_response], [0 10], 'r--', 'lineWidth',2)
xlabel('Stimulus response')
ylabel('# trials')

%is your distribution reasonably gaussian?
%What are the main sources of variability from trial-to-trial?
%Why would we expect this variability to be gaussian if we have enough trials?




%%  Now we can proceed to look at trends in our data across our recordings

%start with a fresh workspace
clear all

%again, we want to point to where our data files are. Except now, we want to specify a list of all files we want to analyze.
dataDir = 'C:\Users\metal\Downloads\lab_ee_466\Lab_2_ee_466\Data'; %FILLIN with the path to where your data is stored

file_prefix = 'BYB_Recording_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '2026-01-20'; %FILLIN with the date string used in your file
file_idnums  = [1 2 3 4 5] ; %FILLIN with the LIST of numeric values of the file ids.


%we also want to define the meta-data associated with each file we listed so we can analyze trends.
stimulus_position = [1 2 3 4 5]; %FILLIN


num_files = length(file_idnums);

% loop through your files to generate PSTH, rasters, and stimulus response for each stimulus
% you presented.
% Preallocate trend outputs
trAvg_response_all = nan(num_files,1);
nEvents_all        = nan(num_files,1);

for iF=1:num_files

    %FILLIN with relevant code (i.e. the same calculations we performed on the test file)
    % --- Build filenames ---
    file_idnum = file_idnums(iF);
    
    full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) file_type];
    events_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) '-events.txt'];
    
    % --- Load data ---
    [data, FS] = audioread(full_file_name);
    num_channels = size(data,2);
    
    % --- Spike detection (single channel or multi-channel-safe) ---
    threshold = 0.04;  % keep same as above (tune if needed)
    spike_times = cell(num_channels,1);
    spike_waveforms = cell(num_channels,1);
    
    for iCh = 1:num_channels
        [spike_times{iCh}, spike_waveforms{iCh}] = detectSpikes(data(:,iCh), threshold, FS);
    end
    
    % --- Load events ---
    [EVENTS, EVENT_TIMES] = readEventsFile(events_file_name);
    
    % For your current data, EVENTS is just [1;1], so align to all event times:
    align_time  = EVENT_TIMES;
    time_before = 1;
    time_after  = 1;
    
    nEvents_all(iF) = length(align_time);
    
    % --- Align spikes to trials ---
    [aligned_spike_times, aligned_spike_labels] = trialAlignSpikes(spike_times, align_time, time_before, time_after);
    
    % --- Bin spikes to get PSTH ---
    bin_width = 0.01;
    [trial_spike_rate, time_bins] = binTrialAlignedSpikes(aligned_spike_times, aligned_spike_labels, time_before, time_after, bin_width);
    
    % --- Trial-average PSTH robustly (handles common dim orderings) ---
    sz = size(trial_spike_rate);
    binDim = find(sz == length(time_bins), 1);
    if isempty(binDim)
        binDim = find(sz == (length(time_bins)-1), 1);
    end
    trialAvg = squeeze(mean(trial_spike_rate, setdiff(1:ndims(trial_spike_rate), binDim)));
    trialAvg = trialAvg(:);
    
    % --- Build PSTH time axis to match trialAvg (edges -> centers if needed) ---
    x = time_bins(:);
    if length(x) == length(trialAvg) + 1
        x = x(1:end-1) + diff(x)/2;   % bin centers
    elseif length(x) ~= length(trialAvg)
        error('File %d: X/Y mismatch: length(time_bins)=%d, length(trialAvg)=%d', file_idnum, length(time_bins), length(trialAvg));
    end
    psth_time = x;
    
    % --- Compute stimulus response (same windows as earlier) ---
    baseline_window = [-1 0];
    response_window = [0 0.2];
    
    baseline_idx = psth_time>=baseline_window(1) & psth_time<=baseline_window(2);
    response_idx = psth_time>=response_window(1) & psth_time<=response_window(2);
    
    trAvg_response = mean(trialAvg(response_idx)) - mean(trialAvg(baseline_idx));
    
    % --- Store trend result for this file ---
    trAvg_response_all(iF) = trAvg_response;

end %end loop through files.

figure;
plot(stimulus_position, trAvg_response_all, 'o-');
xlabel('Stimulus position');
ylabel('Trial-avg response (Hz)');
title('Stimulus response vs position');

figure;
plot(stimulus_position, nEvents_all, 'o-');
xlabel('Stimulus position');
ylabel('# events (trials)');
title('Trials per file (sanity check)');


% For your comprehension questions, attach figures of:
% Pick one example file and show the following raw data plots:
% - spike waveforms for channel 1
%  - spike waveforms for channel 2 (if you recorded 2 channels)
%  - trial-aligned raster and PSTH for channel 1
%  - trial-aligned raster and PSTH for channel 2 (if you recorded 2 channels)



%%
%for saving the figure 
%exportgraphics(gcf, [figpath, 'load_data_']
