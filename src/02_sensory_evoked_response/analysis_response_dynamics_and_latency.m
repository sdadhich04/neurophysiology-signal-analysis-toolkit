%%%%% This script provides a guided outline for analyzing your experimental data collected for Experiment 3 (quantifying sensory response dynamics)
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

dataDir = 'C:\Users\metal\Downloads\lab_ee_466\Lab_2_ee_466\Data'; %FILLIN with the path to where your data is stored

file_prefix = 'BYB_Recording_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '2026-01-20'; %FILLIN  with the date string used in your file
file_idnum  = 1; %FILLIN with the numeric value of the file id

full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) file_type];

% load your data file and the sampling rate into matlab into the variables 'data' and FS, respectively.
% hint: look at the Matlab function 'audioread'
[data, FS] = audioread(full_file_name);

% check the basic properties of your loaded variables
whos data FS

%note that if you are recording 2 channels instead of 1, your data will have 2 columns (#time points x #channels). Let's create a variable to keep track of how many channels we have so our code is flexible:
num_channels = size(data,2);%FILLIN

% plot 1 second of your data (channels 1 and 2) to assure the loaded file looks correct
figure
plot( data(1:FS,: ) ) %FILLIN the portion in the brackets to only plot 1 second (hint: you need to take the sampling rate into account)
xlabel('Time, in samples') %fill in the units of the time axis on this plot
ylabel('Voltage (mV)')

% Now let's find spikes and their waveforms in the data.
% use the code you developed in lab 1 for this task (detectSpikes.m)
%note that you may need to modify this function or how you call it if you have two channels of data in your file.
%create a variable spike_times - cell {# channels x 1} with the detected spike times for each channel.
%
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
%1. load an 'events' file.
events_file_type = '-events.txt';
events_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) events_file_type];

[EVENTS, EVENT_TIMES] = readEventsFile(events_file_name);
disp('unique(EVENTS) ='); disp(unique(EVENTS))
disp('# events ='); disp(length(EVENTS))

%IMPORTANT: double-check that you see two different types of events, one indicating
%stimulation start, and one indicating stimulation end.


%2. trial-align your spikes to the event corresponding to stimulation
%starting
align_event = 1 ;%which code to look for in EVENTS
align_time = EVENT_TIMES(EVENTS == align_event); %use logical indexing to sub-select the EVENT_TIMES to use
time_before = 1; %FILLIN
time_after  = 2; %FILLIN

[aligned_spike_times, aligned_spike_labels] = ...
    trialAlignSpikes(spike_times, align_time, time_before, time_after); %FILLIN

%3. Compute the estimated rates
bin_width = 0.01;
[trial_spike_rate, time_bins] = binTrialAlignedSpikes(aligned_spike_times, aligned_spike_labels, time_before, time_after, bin_width); %FILLIN

%get average across trials
trialAvg_spike_rate = squeeze(mean(trial_spike_rate,1)); %FILLIN  -> [time x channels]

%loop through channels to make a figure + subplot with a raster for each
%channel and a PSTH.
for iCh=1:num_channels
    fig_handle = figure;
    ax_handle = subplot(2,1,1);

    plotRaster(aligned_spike_times{iCh}, aligned_spike_labels{iCh}, fig_handle, ax_handle) %FILLIN
    title(['Channel ', num2str(iCh) ' Stimulus response'])



    subplot(2,1,2);
    stairs(time_bins, trialAvg_spike_rate(:,:,iCh))
    xlabel('Time (s)') %FILLIN
    ylabel('Firing rate (Hz)') %FILLIN
end


%Now try repeating this procedure, but align to the time when you release
%the stimulation.

% -------- Align to stim OFF (release) and plot --------
% Pick the OFF code (commonly 2). Confirm with unique(EVENTS).
align_event_off = 1;  % FILLIN if different
align_time_off = EVENT_TIMES(EVENTS == align_event_off);

[aligned_spike_times_off, aligned_spike_labels_off] = ...
    trialAlignSpikes(spike_times, align_time_off, time_before, time_after);

bin_width = 0.01;
[trial_spike_rate_off, time_bins_off] = ...
    binTrialAlignedSpikes(aligned_spike_times_off, aligned_spike_labels_off, time_before, time_after, bin_width);

trialAvg_spike_rate_off = squeeze(mean(trial_spike_rate_off,1));

for iCh = 1:num_channels
    fig_handle = figure;
    ax_handle = subplot(2,1,1);

    plotRaster(aligned_spike_times_off{iCh}, aligned_spike_labels_off{iCh}, fig_handle, ax_handle)
    title(['Channel ', num2str(iCh), ' Stimulus OFF aligned'])

    subplot(2,1,2);

    y = squeeze(trialAvg_spike_rate_off(:,:,iCh)); y = y(:);
    x = time_bins_off(:);
    if length(x) == length(y) + 1
        x = x(1:end-1) + diff(x)/2;
    end

    stairs(x, y)
    xlabel('Time (s)')
    ylabel('Firing rate (Hz)')
end
% ------------------------------------------------------



%%  Now we can proceed to look at trends in our data across our recordings

%start with a fresh workspace
clear all

%again, we want to point to where our data files are. Except now, we want to specify a list of all files we want to analyze.
dataDir = 'C:\Users\metal\Downloads\lab_ee_466\Lab_2_ee_466\Data'; %FILLIN  with the path to where your data is stored

file_prefix = 'BYB_Recording_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '2026-01-20'; %FILLIN  with the date string used in your file
file_idnums  = [1 2 3 4 5] ; %FILLIN with the LIST of numeric values of the file ids.


%we also want to define the meta-data associated with each file we listed so we can analyze trends.
stimulus_position = [1 2 3 4 5]; %FILLIN


num_files = length(file_idnums);

% loop through your files to generate PSTH, rasters, and stimulus response for each stimulus
% you presented.
for iF=1:num_files

  %FILLIN with relevant code (i.e. the same calculations we performed on the test file)
    file_idnum = file_idnums(iF);

    full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) file_type];
    events_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) '-events.txt'];
    
    [data, FS] = audioread(full_file_name);
    num_channels = size(data,2);
    
    threshold = 0.04;
    spike_times = cell(num_channels,1);
    for iCh = 1:num_channels
        [spike_times{iCh}, ~] = detectSpikes(data(:,iCh), threshold, FS);
    end
    
    [EVENTS, EVENT_TIMES] = readEventsFile(events_file_name);
    
    align_event = 1;
    align_time = EVENT_TIMES(EVENTS == align_event);
    
    time_before = 1;
    time_after = 2;
    
    [aligned_spike_times, aligned_spike_labels] = ...
        trialAlignSpikes(spike_times, align_time, time_before, time_after);
    
    bin_width = 0.01;
    [trial_spike_rate, time_bins] = ...
        binTrialAlignedSpikes(aligned_spike_times, aligned_spike_labels, time_before, time_after, bin_width);
    
    trialAvg = squeeze(mean(trial_spike_rate,1));   % dims may be time x 1 x ch or time x ch
    
    % Use channel 1 for your metric (single-channel recordings)
    y = squeeze(trialAvg(:,:,1)); y = y(:);
    x = time_bins(:);
    if length(x) == length(y) + 1
        x = x(1:end-1) + diff(x)/2;
    end
    
    % Peak in a post-stim window (0 to 0.5 s)
    post_idx = (x >= 0) & (x <= 0.5);
    [peak_rate(iF), idx] = max(y(post_idx));
    tpost = x(post_idx);
    peak_time(iF) = tpost(idx);

end %end loop through files.


% Finally, generate a figure to quantify and visualize the temporal dynamics of the
% sensory responses.
%Are response dynamics the same across neurons? Across positions?
figure;
plot(stimulus_position, peak_rate, 'o-');
xlabel('Stimulus position');
ylabel('Peak firing rate (Hz)');
title('Peak response vs position');

figure;
plot(stimulus_position, peak_time, 'o-');
xlabel('Stimulus position');
ylabel('Time to peak (s)');
title('Response latency vs position');



% For your comprehension questions, attach figures of:
% Pick one example file and show the following raw data plots:
% - spike waveforms for channel 1
% - trial-aligned raster and PSTH for channel 1 or 2, aligned to stim on
% - trial-aligned raster and PSTH for channel 1 or 2, aligned to stim off
% - Summary figure(s) to visualize/quantify the temporal dynamics of the response (as described at end of script)
