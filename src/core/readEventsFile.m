function [EVENTS,EVENT_TIMES] = readEventsFile(events_file)

  %%%%% All lines where you have to fill in information is tagged with a comment including "FILLIN". Use this flag to find everything you need to modify.
  % The function description below described the high-level goals of the function and formats of the inputs and outputs. Read this carefully.

%[EVENTS,EVENT_TIMES] = readEventsFile(events_file)
%   reads events text file from BackyardBrains
%   Returns vectors with the event codes and corresponding time-stamps for
%   all events logged in the file.
%   Assumes text file structure is:
%     - opening lines with comments, start with '#'
%     - data lines with 'EVENT, EVENT_TIME'
%   Reads in EVENT as a double, EVENT_TIME as a float
%
%inputs: events_file - string with full path of event-file to load
%outputs: EVENTS - vector (#events x 1) of event values (1 - 9)
%         EVENT_TIMES - vector (#events x 1) of time-stamps for each event
%

%define constants
COMMENT_CHARACTER = '#';
MAX_NUM_LINES = 1000;   %set max possible number of lines in txt file.

%open the events_file text-file for reading, create a pointer to it
fileID = fopen(events_file, 'r');

at_end_of_file = 0; %flag of progress.

%initialize EVENTS and EVENT_TIME
EVENTS = nan(MAX_NUM_LINES,1);
EVENT_TIMES = nan(MAX_NUM_LINES,1);

num_lines = 0; %counter for number of lines read

%while not at file end, continue loading data.
while ~at_end_of_file && num_lines < MAX_NUM_LINES

    %load a line of the text file
    text_line = fgetl(fileID);

    %iterate on your counter of number of lines
    num_lines = num_lines + 1; %FILLIN

    %if line is a comment, ignore and continue
    if text_line(1) == COMMENT_CHARACTER
        continue
    end %FILLIN

    %if at the end of the file, text_line = -1.
    %when at the end, stop looping
    if text_line == -1
        at_end_of_file = 1;
        continue
    end %FILLIN

    %otherwise, use sscanf to look for the pattern ('%d, %f') and get the
    %numbers
    %store first value in EVENTS and second value in EVENT_TIMES
    vals = sscanf(text_line, '%d, %f');
    EVENTS(num_lines) = vals(1);
    EVENT_TIMES(num_lines) = vals(2); %FILLIN

end

%clean-up the extra values added to events/event-times
EVENTS = EVENTS(~isnan(EVENTS)); %FILLIN
EVENT_TIMES = EVENT_TIMES(~isnan(EVENT_TIMES)); %FILLIN

%close the text-file
fclose(fileID);

end
