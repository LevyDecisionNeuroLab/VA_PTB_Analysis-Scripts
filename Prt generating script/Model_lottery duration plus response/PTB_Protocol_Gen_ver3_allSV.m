function PTB_Protocol_Gen_ver3_allSV(subjectNum, gainsloss, tr, trialduration, DiscAcq, ParametricMod, path_in, path_out, PRT, par)
%PTB_PROTOCOL_GEN Generates PRT Files from Psychtoolbox Data Files
%
%INPUTS:
%       subjectNum - Specifies subject file to be loaded
%       gainsloss - A string of either 'gains' or 'loss' to indicate the domain to extract
%       tr - Temporal resolution of the visual data, in seconds
%       trialduration - Number of seconds to analyze after trial onset
%       DiscAcq - Number of seconds to discard at the beginning of each block
%       ParametricMod - which value to use as parameter? Values: 'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'SV', or ''
%       path_in - the dominant folder that both auxiliary function files and data files are stored in
%       path_out - the folder to save the generated PRT files into
%       PRT - a struct of settings for the PRT file
%       par - a table containing model fitted parameters, both gains and
%       losses for a single subject
%
%OUTPUT: PRT files for given domain in the folder specified by `path_out`
%
% NOTE: In order to create a protocol file with onsets measured in seconds,
% simply switch tr value to 1

%% Process arguments
% Store in logical value whether protocol should be generated for gains or losses
is_gains = strcmp(gainsloss, 'gains');
if (~is_gains && ~strcmp(gainsloss, 'loss'))
  error('Aborting: `gainsloss` must be set to either "gains" or "loss"!')
  return
end

% Set NumParametricWeights on the basis of ParametricMod
permissible_parameters = {'allSV', 'allSV_Sal', 'allCV'};
if sum(strcmp(ParametricMod, permissible_parameters)) 
  % using sum because strcmp returns a matrix of logicals if string is compared 
  % with an array of strings
  NumParametricWeights = 1;
elseif strcmp(ParametricMod, 'none')
  NumParametricWeights = 0;
else
  error('Aborting: `ParametricMod` must be set to a valid parameter value!')
  return
end
PRT.ParametricWeights = num2str(NumParametricWeights);

% For PRT properties, fix colors into correct order
Colors = {PRT.Color};

%% Load Gains and Loss Data files
% Add the directory & all subdirs to path
addpath(genpath(path_in)); 

load(['RA_GAINS_' num2str(subjectNum) '_fitpar.mat']);
gdata = Data;
load(['RA_LOSS_' num2str(subjectNum) '_fitpar.mat']);
ldata = Data;

clearvars Data; % avoid accidental name collision

% Pick the domain to analyze
if (is_gains)
  data = gdata;
else
  data = ldata;
end

% model fitted parameters for calculating subjective value, read from sheet
alpha_day1 = par.alpha(par.isGain == is_gains & par.isDay1 == 1);
beta_day1 = par.beta(par.isGain == is_gains & par.isDay1 == 1);

alpha_day2 = par.alpha(par.isGain == is_gains & par.isDay1 == 0);
beta_day2 = par.beta(par.isGain == is_gains & par.isDay1 == 0);

%% Get correct block order
block_order = getBlockOrder(is_gains, gdata, ldata);

%% Get the day index for each trial
% get the date for each trial
% data = Data;

trial_day = zeros(length(data.choice),3);
for trial_idx = 1:length(data.choice)
    trial_day(trial_idx,1:3) = data.trialTime(trial_idx).trialStartTime(1:3);   
end

% determine if isDay1 is true
trial_isDay1 = zeros(length(data.choice),1);
day1_date = datetime(trial_day(1,:));

for trial_idx = 1:length(data.choice)
    if datetime(trial_day(trial_idx,:)) == day1_date
        trial_isDay1(trial_idx) = 1;
    else
        trial_isDay1(trial_idx) = 0;
    end
end

%% Compute subjective value of each choice
% Use the best fit for every subjects (most should be unconstrained, use constrained for a few subjects)
% separate day1 and day2

% for subjects who did not have beta
model_day1 = 'ambigNrisk';
model_day2 = 'ambigNrisk';

if ~isnan(alpha_day1) && isnan(beta_day1)
    model_day1 = 'risk';
end

if ~isnan(alpha_day2) && isnan(beta_day2)
    model_day2 = 'risk';
end


for reps = 1:length(data.choice)
    if trial_isDay1(reps) == 1
          sv(reps, 1) = ambig_utility(0, ...
              data.vals(reps), ...
              data.probs(reps), ...
              data.ambigs(reps), ...
              alpha_day1, ...
              beta_day1, ...
              model_day1);
    else
          sv(reps, 1) = ambig_utility(0, ...
              data.vals(reps), ...
              data.probs(reps), ...
              data.ambigs(reps), ...
              alpha_day2, ...
              beta_day2, ...
              model_day2);
    end
        
end

% Side with lottery is counterbalanced across subjects 
% -> code 0 as reference choice, 1 as lottery choice
% TODO: Double-check this is so? - This is true(RJ)
% TODO: Save in a different variable?
% if sum(choice == 2) > 0 % Only if choice has not been recoded yet. RJ-Not necessary
% RJ-If subject do not press 2 at all, the above if condition is problematic
choice = data.choice;
choice(choice==0) = NaN;

if data.refSide == 2
  choice(choice == 2) = 0;
  choice(choice == 1) = 1;
elseif data.refSide == 1 % Careful: rerunning this part will make all choices 0
  choice(choice == 1) = 0;
  choice(choice == 2) = 1;
end

% calculate the subjective value for the fixed $5
sv_fixed_day1 = ambig_utility(0,5,1,0,alpha_day1,beta_day1,'risk');
sv_fixed_day2 = ambig_utility(0,5,1,0,alpha_day2,beta_day2,'risk');

% Flip sign, since the data files store only value magnitudes 
if ~is_gains
  sv(:, 1) = -1 * sv(:, 1);
  sv_fixed_day1 = -sv_fixed_day1;
  sv_fixed_day2 = -sv_fixed_day2;

end

% calculate the chosen subjective value (CV) for each trial
cv = sv;
cv(choice' == 0 & trial_isDay1 == 1) = sv_fixed_day1;
cv(choice' == 0 & trial_isDay1 == 0) = sv_fixed_day2;
cv(isnan(choice')) = NaN;

%% Load onset times
gon = PTB_Protocol_OnsetExtract(gdata);
lon = PTB_Protocol_OnsetExtract(ldata);

% Extract per-block time info from returned argument
gonsets = {gon.b1, gon.b2, gon.b3, gon.b4};
lonsets = {lon.b1, lon.b2, lon.b3, lon.b4};

%% Iterate over blocks in domain
% NOTE: 4 is magic number, since currently each domain has exactly 4 blocks
for blocknum = 1:4
  %% Select onset/offset time block to use
  if is_gains
    prtblock = gonsets{blocknum};
  else
    prtblock = lonsets{blocknum};
  end

  %% Process onset/offset times
  [ onsets, offsets ] = getBlockOnsetOffset(prtblock, DiscAcq, tr, trialduration);

  %% Compute values from current block
  % Get indices for risk trials and ambiguity trials (30 values, regularly spaced)
  current_block_range = (2:31) + (blocknum - 1) * 31;

  % Divide blocks by type of lottery (store indices with risk-only vs. risk-and-ambiguity)
  amb_index = data.ambigs(current_block_range) > 0;
  risk_index = data.ambigs(current_block_range) == 0;

  % Parametric weights for current block
  if NumParametricWeights > 0
    block_amt = data.vals(current_block_range);
    block_rlevel = data.probs(current_block_range);
    block_alevel = data.ambigs(current_block_range);
    block_sv = sv(current_block_range);
    block_cv = cv(current_block_range);

    if ~is_gains
      block_amt = -1 * block_amt;
    end
  end

  %% Select what parametric value to write (or not write) into PRT file
  % Store the basic onset/offset, computed earlier
  block_amb = [onsets(amb_index,1) offsets(amb_index,1)];
  block_risk = [onsets(risk_index,1) offsets(risk_index,1)];
  
  block_choice = choice(current_block_range)';
  
  resp = [offsets(~isnan(block_choice),2) offsets(~isnan(block_choice),2)]; % response for all trials with response
  
%   resp = [onsets(:,2) offsets(:,2)]; % response for all trials
  
  block_all = [onsets(:,1) offsets(:,1)]; % onsets for all trials
  
  % Add the parametric value if required
   if strcmp(ParametricMod, 'allSV_Sal')
      if is_gains
        block_all = [block_all block_sv];
      elseif ~is_gains
        block_all = [block_all -block_sv];  
      end
   elseif strcmp(ParametricMod, 'allSV')
      block_all = [block_all block_sv];  
   end
      
  %% Write file to txt
  
  % Determine session for filename
  if blocknum <= 2
    Session = 'S1';
  else
    Session = 'S2';
  end

  % Open file for writing
  fname = [path_out num2str(subjectNum) '_' Session '_block' block_order{blocknum} ...
      '_' gainsloss num2str(blocknum) '_model_dispresp' '_type_' ParametricMod '.prt']
  fileID = fopen(fname, 'w');

  % TODO: Figure out how %Ns works -- it's highly unlikely that both values
  % actually do a useful thing
  fprintf(fileID, '%12s %10s\r\n \r\n', 'FileVersion:', PRT.FileVersion);
  fprintf(fileID, '%17s %11s\r\n \r\n', 'ResolutionOfTime:', PRT.ResolutionOfTime);
  fprintf(fileID, '%11s %21s\r\n \r\n', 'Experiment:', PRT.Experiment);
  fprintf(fileID, '%16s %16s\r\n', 'BackgroundColor:', PRT.BackgroundColor);
  fprintf(fileID, '%10s %16s\r\n', 'TextColor:', PRT.TextColor);
  fprintf(fileID, '%16s %10s\r\n', 'TimeCourseColor:', PRT.TimeCourseColor);
  fprintf(fileID, '%16s %6s\r\n', 'TimeCourseThick:', PRT.TimeCourseThick);
  fprintf(fileID, '%19s %11s\r\n', 'ReferenceFuncColor:', PRT.ReferenceFuncColor);
  fprintf(fileID, '%19s %3s\r\n \r\n', 'ReferenceFuncThick:', PRT.ReferenceFuncThick);

  % TODO: Shouldn't ParametricWeights be always included, even if they *are* 0?
  if NumParametricWeights > 0
      fprintf(fileID, '%18s %4s\r\n', 'ParametricWeights:', PRT.ParametricWeights);
  end

  fprintf(fileID, '\r\n%15s %7s\r\n\r\n', 'NrOfConditions:', PRT.NrOfConditions);

  
  % Print all trials
  fprintf(fileID, '%7s\r\n', ['Display']);
  fprintf(fileID, '%4s\r\n', num2str(length(block_all)));
  fprintf(fileID, '%4.0f\t %3.0f\t %1.3f\r\n', block_all');
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});
  

  % Print the response for all trials
  fprintf(fileID, '%4s\r\n', 'Resp');
  fprintf(fileID, '%4s\r\n', num2str(length(resp)));
  fprintf(fileID, '%4.0f\t %3.0f\r\n', resp');
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', PRT.ColorResp);

  fclose(fileID);
end
end
