%%%%% This script provides a guided outline for analyzing your experimental data collected
%%%%% for Experiment 3 (characterizing evoked muscle twitches in response to stimulation at differing frequencies)
%%%%% Written by A.L. Orsborn, v210122
%%%%%
%%%%%
%%%%% All lines where you have to fill in information is tagged with a comment including "FILLIN". Use this flag to find everything you need to modify.


%%%%IMPORTANT:
% This will use all the same data processing techniques and calculations we developed in experiment 1.
%Do this analysis AFTER having done the analysis for that experiment.
%you should be able to directly lift most of your code from lab 1 with slight modifications for this analysis.


%% load the data for all files, compute metrics, and make plots


%start with a fresh workspace
clear all

%again, we want to point to where our data files are. Except now, we want to specify a list of all files we want to analyze.
dataDir = 'C:\Users\metal\Downloads\lab_ee_466\lab3_ee_466\data'; %FILLIN with the path to where your data is stored

file_prefix = 'BYB_Recording_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '2026-01-27'; %FILLIN with the date string used in your file
file_idnums  = [2,6,7,8,9,10] ; %FILLIN with the LIST of numeric values of the file ids.


%we also want to define the meta-data associated with each file we listed so we can analyze trends.
stim_frequency = [2,4,8,12,16,20]; %FILLIN


num_files = length(file_idnums);


% loop through your files to calculate your evoked twitch profiles and metrics for each.
% here, we will only look at maximum amplitude of the twitch and the absolute force as a function of frequency
mean_twitch_amp = nan(num_files,1);
ste_twitch_amp = nan(num_files,1);
mean_force_amp = nan(num_files,1);
ste_force_amp = nan(num_files,1);
for iF=1:num_files

    %1. load data
    %FILLIN
    full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnums(iF)) file_type];
    [data, FS] = audioread(full_file_name);

    %correct the force-sensor data offset
    %FILLIN
    force_voltage_offset = min(data(:,2));
    data(:,2) = data(:,2) - force_voltage_offset;


    %2. detect stim events
    %FILLIN
    threshold = -0.2;
    [stim_times, ~] = detectSpikes(data(:,1), threshold, FS);
    
    MIN_STIM_DELTA = 0.005;
    dt_stim = diff(stim_times);
    too_short = find(dt_stim < MIN_STIM_DELTA);
    use_pulse = setdiff(1:length(stim_times), too_short);
    stim_times_cleaned = stim_times(use_pulse);

    %3. trial-align data to stimulation times. Remember to correct for the baseline force in each trial & create a trial_time vector.
    %FILLIN
    align_times = stim_times_cleaned;  % if stim_times are in seconds
    time_before = 0.05;
    time_after  = 0.3;
    
    L = round((time_before + time_after) * FS);   % window length in samples
    N = size(data,1);                              % total samples in file
    
    t_min = time_before + 1/FS;
    t_max = time_before + (N - L + 1)/FS;
    
    align_times = align_times(align_times >= t_min & align_times <= t_max);


    trial_force = trialAlignData(data(:,2), align_times, time_before, time_after, FS);
    trial_time = linspace(-time_before, time_after, size(trial_force,2));
    
    baseline_idx = find(trial_time>=0, 1, 'first');
    trial_baseline_force = trial_force(:, baseline_idx);
    trial_force_corrected = trial_force - repmat(trial_baseline_force, 1, size(trial_force,2));




    %4. Now compute twitch amplitude and force amplitude for each trial.
    %since we're only calculating the max for each trial, we no longer need a for-loop because the max function can operate across a matrix.
    %look at the help for 'max' to see how to do this calculation without a for-loop
    num_trials = size(trial_force_corrected,1);

    %compute the contraction amplitude (maximum change in force evoked by stim)
    %Here, we want baseline variation removed to see the delta caused by stim.
    ta = max(abs(trial_force_corrected), [], 2); %%FILLIN - twitch amplitude

    %compute the maximum absolute force for the trial
    %this requires using our "uncorrected" force profiles (where we haven't removed the baseline force)
    fa = max(abs(trial_force), [], 2); %%FILLIN - force amplitude


    %5. now compute trial-averaged metrics to summarize results
    %ste = standard error = standard deviation /sqrt(# trials)
    %hint: look up help for std
    mean_twitch_amp(iF) = mean(ta);
    ste_twitch_amp(iF) = std(ta) / sqrt(sum(~isnan(ta))); %FILLIN

    mean_force_amp(iF) = mean(fa);
    ste_force_amp(iF)  = std(fa) / sqrt(sum(~isnan(fa))); %FILLIN


end %end loop through files.


% generate figures to visualize the relationship between stimulation amplitude and
% each twitch paramter
%plot the across-trial mean with error bars showing the standard error
%hint: look up the help for 'errorbar'
%INCLUDE THIS FIGURE IN COMPREHENSION QUESTIONS
figure
subplot(1,2,1)
errorbar(stim_frequency, mean_twitch_amp, ste_twitch_amp, 'o-') %FILLIN
xlabel('Stimulation frequency (Hz)')
ylabel('Twitch amplitude (V)')

subplot(1,2,2)
errorbar(stim_frequency, mean_force_amp, ste_force_amp, 'o-') %FILLIN
xlabel('Stimulation frequency (Hz)')
ylabel('Force amplitude (V)')
