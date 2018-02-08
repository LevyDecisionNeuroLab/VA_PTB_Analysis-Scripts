function [onsets] = PTB_Protocol_OnsetExtract_subj95(Data)
%[onsets] = PTB_ProtocolFile_v1(subjectNum, gainsloss)
%Extract onset times from PTB Data files
%
%INPUTS:
%Data - a struct loaded from a subject file
%
%OUTPUT:
%onsets - A structure that includes a matrix of various onsets times
%   .Day1 - First start trial time on Day1
%   .Day2 - First start trial time on Day2
%   .Description - Headings for block onset time matrices
%   .b1 - Onset times for block 1 by trial
%   .b2 - Onset times for block 2 by trial
%   .b3 - Onset times for block 3 by trial
%   .b4 - Onset times for block 4 by trial

% Initialize fields
trialNum = length(Data.trialTime);

start = zeros(trialNum, 5);
ends = zeros(trialNum, 5);
resp = zeros(trialNum, 5);
feedback = zeros(trialNum, 5);
ITIs = zeros(trialNum, 5);

% NOTE: for-loop necessary due to odd nested struct issues
for i = 1:trialNum
  % Extract onset times and convert from hr:min:sec into seconds
  % NOTE: To avoid repetition of indices: `var(i, 4) = var(i, 1:3) * [3600; 60; 1]`
  start(i, 1:3) = Data.trialTime(i).trialStartTime(4:6);
  start(i, 4) = start(i, 1)*3600 + start(i, 2)*60 + start(i, 3);

  % NOTE: Rarely, `ITIStartTime` and `trialEndTime` are not recorded 
  % -> get next trial's trialStartTime and settle for NaN
  try
    ends(i, 1:3) = Data.trialTime(i).trialEndTime(4:6);
    ITIs(i, 1:3) = Data.trialTime(i).ITIStartTime(4:6);
  catch ME
    fprintf('Error caught: %s in %s at choice %d\n', ME.identifier, Data.filename, i) % MATLAB.badsubscript
    if (floor(i / 31) * 31 + 1) == (i + 1) % if next choice is a different block
      ends(i, 1:3) = NaN;
    else
      ends(i, 1:3) = Data.trialTime(i + 1).trialStartTime(4:6);
    end
    ITIs(i, 1:3) = NaN;
  end
  ends(i, 4) = ends(i, 1)*3600 + ends(i, 2)*60 + ends(i, 3);
  ITIs(i, 4) = ITIs(i, 1)*3600 + ITIs(i, 2)*60 + ITIs(i, 3);

  resp(i, 1:3) = Data.trialTime(i).respStartTime(4:6);
  resp(i, 4) = resp(i, 1)*3600 + resp(i, 2)*60 + resp(i, 3);

  feedback(i, 1:3) = Data.trialTime(i).feedbackStartTime(4:6);
  feedback(i, 4) = feedback(i, 1)*3600 + feedback(i, 2)*60 + feedback(i, 3);


  % Calculate time in relation to the appropriate block's first trial onset
  if i < 32
    first_trial = 1;
  elseif i < 63
    first_trial = 32;
  elseif i < 94
    first_trial = 63;
  else
    first_trial = 94;
  end
  % NOTE: `floor(i / 31) * 31 + 1` designates each block's first trial for
  % an arbitrary number of blocks, but this is more straightforward.

  start(i, 5) = start(i, 4) - start(first_trial, 4);
  ends(i, 5) = ends(i, 4) - start(first_trial, 4);
  resp(i, 5) = resp(i, 4) - start(first_trial, 4);
  feedback(i, 5) = feedback(i, 4) - start(first_trial, 4);
  ITIs(i, 5) = ITIs(i, 4) - start(first_trial, 4);
end

%% Take the time in seconds and divide into blocks
block1 = [start(1:31, 5) resp(1:31, 5) feedback(1:31, 5) ITIs(1:31, 5) ends(1:31, 5)];
block2 = [start(32:62, 5) resp(32:62, 5) feedback(32:62, 5) ITIs(32:62, 5) ends(32:62, 5)];
if strcmp(Data.filename(12), 'G') % extract block 3 and 4 for gain domain only
    block3 = [start(63:93, 5) resp(63:93, 5) feedback(63:93, 5) ITIs(63:93, 5) ends(63:93, 5)];
    block4 = [start(94:124, 5) resp(94:124, 5) feedback(94:124, 5) ITIs(94:124, 5) ends(94:124, 5)];
end
%% Return
FirstTrial1 = Data.trialTime(1).trialStartTime(1:6);  % First Day 1 trial
if strcmp(Data.filename(12), 'G') % extract block 3 and 4 for gain domain only
    FirstTrial2 = Data.trialTime(63).trialStartTime(1:6); % First Day 2 trial
end

onsets.Day1 = [num2str(FirstTrial1(4)) ':' num2str(FirstTrial1(5)) ':' num2str(FirstTrial1(6)) ', ' num2str(FirstTrial1(2)) '/' num2str(FirstTrial1(3)) '/' num2str(FirstTrial1(1))];
if strcmp(Data.filename(12), 'G') % extract block 3 and 4 for gain domain only
    onsets.Day2 = [num2str(FirstTrial2(4)) ':' num2str(FirstTrial2(5)) ':' num2str(FirstTrial2(6)) ', ' num2str(FirstTrial2(2)) '/' num2str(FirstTrial2(3)) '/' num2str(FirstTrial2(1))];
end

onsets.Description = 'Start - Response - Feedback - ITI - End';
onsets.b1 = block1;
onsets.b2 = block2;
if strcmp(Data.filename(12), 'G') % extract block 3 and 4 for gain domain only
    onsets.b3 = block3;
    onsets.b4 = block4;
end
end
