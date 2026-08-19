%%%%% This script provides a guided outline for analyzing your experimental data collected for Experiment 1 (studying the impact of referencing on recorded ephys signals)
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

dataDir = 'C:\Users\metal\Downloads\lab1 ee 466\data'; %FILLIN with the path to where your data is stored

file_prefix = 'BYB_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '011326'; %FILLIN with the date string used in your file
file_idnum  = 1; %FILLIN with the numeric value of the file id

full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnum) file_type];

% load your data file and the sampling rate into matlab into the variables 'data' and FS, respectively.
% hint: look at the Matlab function 'audioread'
[data,FS] = audioread(full_file_name);

% check the basic properties of your loaded variables
whos data FS


% plot 1 second of your data to assure the loaded file looks correct
figure
plot( data(1:FS ) ) %FILLIN the portion in the brackets to only plot 1 second
xlabel('Time, in seconds') %FILLIN the units of the time axis on this plot
ylabel('Voltage (mV)')


% Now let's find spikes and their waveforms in the data. 
% In lab 0, we wrote a function to detect spikes. We'll use it here.

%the detection algorithm requires a voltage threshold. Based on your plot above, pick a threshold that seems reasonable to start with.
threshold = 0.1; %FILLIN with a number based on your data.
[spike_times, spike_waveforms] = detectSpikes(data, threshold, FS);

%inspect our data

%plot the raw signal and times of detected spikes to see if our function is working correctly
time_data = [0:length(data)-1]./FS; %this creates a time vector of the data in seconds
plot(time_data, data) %plot the raw data
xlabel('Time (s)')
ylabel('Voltage (mV)')
hold on
plot([spike_times spike_times]', repmat([.1 .15], length(spike_times),1)', 'r') %plot a vertical line at each detected spike time on the same plot
set(gca, 'xlim', [0 0.5]); %zoom in a bit
%pan through the data to see if you are doing a good job of detecting spikes.

%also plot the waveforms to inspect. Only plotting a few (~100 or so) is recommended, because it can be difficult to see well otherwise
nPlot = 100; %pick how many waveforms to plot--you can change this
time_waveforms = [-9:20]./FS; %time vector of the waveforms in seconds
figure
plot(time_waveforms, spike_waveforms(1:nPlot,:)')
xlabel('Time (s)')
ylabel('Voltage (mV)')
title(['Threshold = ', num2str(threshold)])
%%
%compute the spike rate across your file.
%hint: count the number of spikes you observe and divide by the time of your recording to get a rate
spike_rate = length(spike_times)/(time_data(end)); %FILLIN
fprintf('The estimated spike rate is: %d', spike_rate);


% To double-check our detectSpikes function is working properly, I recommend re-running it a few times and re-generating your plots with slightly different values of the threshold
% Make sure you understand what this calculation is doing.
% Try coming up with a way to set the threshold value without having to manually set it based on inspection of the data
% hint: The data values define a distribution with a mean and standard deviation. Are the spikes close or far from the mean?



%%  Now we can proceed to look at trends in our data across our recordings

%again, we want to point to where our data files are. Except now, we want to specify a list of all files we want to analyze.
dataDir = 'C:\Users\metal\Downloads\lab1 ee 466\data'; %FILLIN with the path to where your data is stored

file_prefix = 'BYB_'; %FILLIN with the text string that is common among all your data files
file_type = '.wav';   %FILLIN with the file extension for your data type

file_date   = '011326'; %FILLIN with the date string used in your file
file_idnums  = [4,3,1,2] ; %FILLIN with the LIST of numeric values of the file ids.


%we also want to define the meta-data associated with each file we listed so we can analyze trends.
%the variable we changed across recordings is the electrode spacing. Define a variable for electrode_spacing
%that goes small -> large as the spacing between your recording and reference electrodes increases.
%note that the ordering of this variable should match the ordering of file_idnums defined above so that each file is matched with the appropriate metadata.
%Also note that it's easiest if you order the files so that electrode_spacing goes from smallest -> largest.

electrode_spacing = [0, 3, 6, 9]; %FILLIN with the LIST of values for your spacings


num_files = length(file_idnums);

all_p2p = {};
all_spike_rate = [];
all_spike_times = {};
all_spike_waveforms = {};
mean_p2p = [];
meanWaveforms = zeros([num_files, 30]);
% loop through your files to get spike rates and waveforms for all files
for iF=1:num_files

    %load the data and sampling rate, as done above
    full_file_name = [dataDir '\' file_prefix file_date '_' num2str(file_idnums(iF)) file_type];
    [data, FS] = audioread(full_file_name);

    %calculate an appropriate threshold for detecting spikes based on the data (see above)
    threshold = 0.0815; %FILLIN

    %detect spikes and waveforms. Save them into a variable for later analysis.
    %note: since there will be different numbers of spikes across files, these variables will need to be cells.
    %FILLIN with relevant code
    [spike_times, spike_waveforms] = detectSpikes(data, threshold, FS);
    all_spike_waveforms{iF}= spike_waveforms;
    all_spike_times{iF} = spike_times;


    %calculate the spike rate for each file. Again, save in a variable for later analysis.
    %FILLIN with relevant code
    spike_rate = length(spike_times)/(time_data(end));
    all_spike_rate(iF) = spike_rate;

    %calculate the peak-to-peak amplitude for your spikes and the mean peak-to-peak across all your waveforms.
    %use the provided function calcSpikePeak2Peak.m
    %FILLIN with relevant code
    p2p = calcSpikePeak2Peak(spike_waveforms);
    all_p2p{iF} = p2p; % Store peak-to-peak values for each file
    mean_p2p(iF) = mean(p2p);


    %calculate the mean waveform across all detected spikes. Save in a variable for plotting.
    %FILLIN with relevant code
    meanWaveforms(iF, :) = mean(spike_waveforms,1);

end %end loop through files.


% We will now generate figures to explore our data:

%figure 1: mean firing rate as a function of electrode spacing. (attach in your comprehension questions)
figure
plot(electrode_spacing(1:4), all_spike_rate(1:4)) %FILLIN with relevant variable name
xlabel('Length in (mm)') %FILL IN label
ylabel('Spike rate') %FILL IN label, be sure to include units


%figure 2: plot example waveforms (attach in your comprehension questions)
%as before, it may be most informative to plot a smaller subset of all waveforms.
figure
y_axis_range = [-.2 .2]; %modify if needed for your data.
time_waveforms = [-10:19]./FS; %time vector of the waveforms in seconds

%loop through each file
for iF=1:num_files
    subplot(1, num_files, iF)


    plot(time_waveforms, all_spike_waveforms{iF}(1:10,:)') %FILLIN with relevant variable name
    xlabel('Time (s)')
    ylabel('Voltage (mV)')
    set(gca, 'ylim', y_axis_range) %keep axis the same across plots for easier comparison
    title(['E-spacing: ', num2str(electrode_spacing(iF))])
end %end loop through files


%figure 3: mean waveform versus electrode_spacing (attach in your comprehension questions)
figure
plot(time_waveforms, meanWaveforms(1:4,:)) %FILLIN with relevant variable name
xlabel('Time (s)') %FILL IN label
ylabel('Voltage (mV)') %FILL IN label, be sure to include units
legendEntries = {'6mm','9mm', '3mm', '0mm'};
legend(legendEntries)


%figure 4: mean peak-to-peak amplitude versus electrode electrode spacing (attach in your comprehension questions)
figure
plot(electrode_spacing(1:4), mean_p2p(1:4)) %FILLIN with relevant variable name
xlabel('Elctrode spacing (mm)') %FILL IN label
ylabel('mean peak to peak (mV)') %%FILL IN label, be sure to include units


%figure 5: histogram of peak-to-peak amplitude for each recording (attach in your comprehension questions)
figure
histBins = [0:.01:.5]; %bins to use--note, may want to adjust depending on your data range
%loop through each file
for iF=1:num_files
    subplot(num_files, 1, iF)

    hist(all_p2p{iF}) %FILLIN with your data to make a histogram of peak-to-peak amplitudes observed across all spikes, using histBins
    xlabel('Peak to Peak value (mV)') %FILL IN label be sure to include units
    ylabel('Counts') %FILL IN label, be sure to include units
    title(['E-spacing: ', num2str(electrode_spacing(iF))])
end %end loop through files
