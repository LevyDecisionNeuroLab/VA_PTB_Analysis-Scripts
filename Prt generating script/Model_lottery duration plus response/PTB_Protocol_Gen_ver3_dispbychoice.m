function PTB_Protocol_Gen_ver3_dispbychoice(subjectNum, gainsloss, tr, trialduration, DiscAcq, ParametricMod, path_in, path_out, PRT, par)
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

NumParametricWeights = 1;

PRT.ParametricWeights = num2str(NumParametricWeights);

% For PRT properties, fix colors into correct order
% For PRT properties, fix colors into correct order
if ~is_gains
  Colors = {PRT.Color_Disp_Lott_loss, PRT.Color_Disp_Ref_loss, PRT.Color_Resp_Lott_loss, PRT.Color_Resp_Ref_loss};
  alt_colors = {PRT.Color_Disp_Lott_gains, PRT.Color_Disp_Ref_gains, PRT.Color_Resp_Lott_gains, PRT.Color_Resp_Ref_gains};
else
  Colors = {PRT.Color_Disp_Lott_gains, PRT.Color_Disp_Ref_gains, PRT.Color_Resp_Lott_gains, PRT.Color_Resp_Ref_gains};
  alt_colors = {PRT.Color_Disp_Lott_loss, PRT.Color_Disp_Ref_loss, PRT.Color_Resp_Lott_loss, PRT.Color_Resp_Ref_loss};
end

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

%% Compute subjective value of each choice
% model fitted parameters for calculating subjective value
alpha = par.alpha(par.isGain == is_gains);
beta = par.beta(par.isGain == is_gains);

% Use the best fit for every subjects (most should be unconstrained, use constrained for a few subjects)
for reps = 1:length(data.choice)
  sv(reps, 1) = ambig_utility(0, ...
      data.vals(reps), ...
      data.probs(reps), ...
      data.ambigs(reps), ...
      alpha, ...
      beta, ...
      'ambigNrisk');
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
sv_fixed = ambig_utility(0,5,1,0,alpha,beta,'ambigNrisk');

% Flip sign, since the data files store only value magnitudes 
if ~is_gains
  sv(:, 1) = -1 * sv(:, 1);
  sv_fixed = -sv_fixed;
end

% calculate the chosen subjective value (CV) for each trial
cv = sv;
cv(choice == 0) = sv_fixed;
cv(isnan(choice)) = NaN;

%% Get correct block order
if subjectNum ~= 95
    block_order = getBlockOrder(is_gains, gdata, ldata);
    % Load onset times
    gon = PTB_Protocol_OnsetExtract(gdata);
    lon = PTB_Protocol_OnsetExtract(ldata);

    % Extract per-block time info from returned argument
    gonsets = {gon.b1, gon.b2, gon.b3, gon.b4};
    lonsets = {lon.b1, lon.b2, lon.b3, lon.b4};
else
    block_order = getBlockOrder_subj95(is_gains, gdata, ldata);
    % Load onset times
    gon = PTB_Protocol_OnsetExtract_subj95(gdata);
    lon = PTB_Protocol_OnsetExtract_subj95(ldata);
    
    % Extract per-block time info from returned argument
    gonsets = {gon.b1, gon.b2, gon.b3, gon.b4};
    lonsets = {lon.b1, lon.b2};
end

%% Iterate over blocks in domain
% NOTE: 4 is magic number, since currently each domain has exactly 4 blocks
for blocknum = 1:4
  if subjectNum == 95 && (blocknum == 3 || blocknum ==4) && ~is_gains  
     continue % skip the for loop
  end
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
    
  block_choice = choice(current_block_range)';
  lott_index = block_choice == 1;
  ref_index = block_choice == 0;
  
  % onset and off set for choice
  disp_lott = [onsets(lott_index, 1) offsets(lott_index, 1)]; 
  disp_ref = [onsets(ref_index, 1) offsets(ref_index, 1)];
  resp_lott = [offsets(lott_index, 2) offsets(lott_index, 2)];
  resp_ref = [offsets(ref_index, 2) offsets(ref_index, 2)];
  
  % Add the selected parametric value if required
  if NumParametricWeights > 0
    if strcmp(ParametricMod, 'SV_choice')
      disp_lott = [disp_lott block_sv(lott_index)];
      disp_ref= [disp_ref block_sv(ref_index)];
    end
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

  if ~is_gains
    fprintf(fileID, '%8s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Lott_gains', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%13s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Lott_gains x p1', '0', 'Color:', '0 0 0');
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Ref_gains', '0', 'Color:', alt_colors{2});
    fprintf(fileID, '%14s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Ref_gains x p1', '0', 'Color:', '0 0 0');
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Resp_Lott_gains', '0', 'Color:', alt_colors{3});
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Resp_Ref_gains', '0', 'Color:', alt_colors{4});
  end
  
  % Print display lottery
  fprintf(fileID, '%9s\r\n', ['Disp_Lott_' gainsloss]);
  fprintf(fileID, '%4s\r\n', num2str(size(disp_lott,1)));
  if size(disp_lott,1) > 0
    fprintf(fileID, '%4.0f\t %3.0f\t %1.3f\r\n', disp_lott'); 
  end
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1}); 
  
  if size(disp_lott,1) == 0
      fprintf(fileID, '%13s\r\n%3s\r\n%4s %6s\r\n\r\n', ['Disp_Lott_' gainsloss ' x p1'], '0', 'Color:', '0 0 0');
  end
  
  % print display reference
  fprintf(fileID, '%8s\r\n', ['Disp_Ref_' gainsloss]);
  fprintf(fileID, '%4s\r\n', num2str(size(disp_ref,1)));
  if size(disp_ref,1) > 0
    fprintf(fileID, '%4.0f\t %3.0f\t %1.3f\r\n', disp_ref'); 
  end
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});

  if size(disp_ref,1) == 0
      fprintf(fileID, '%13s\r\n%3s\r\n%4s %6s\r\n\r\n', ['Disp_Ref_' gainsloss ' x p1'], '0', 'Color:', '0 0 0');
  end
  
  % print response lottery
  fprintf(fileID, '%9s\r\n', ['Resp_Lott_' gainsloss]);
  fprintf(fileID, '%4s\r\n', num2str(size(resp_lott,1)));
  if size(resp_lott,1) > 0
    fprintf(fileID, '%4.0f\t %3.0f\r\n', resp_lott'); 
  end
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{3});
  
  % print response reference
  fprintf(fileID, '%8s\r\n', ['Resp_Ref_' gainsloss]);
  fprintf(fileID, '%4s\r\n', num2str(size(resp_ref,1)));
  if size(resp_ref,1) > 0
    fprintf(fileID, '%4.0f\t %3.0f\r\n', resp_ref'); 
  end
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{4});
  
  if is_gains
    fprintf(fileID, '%8s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Lott_loss', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%13s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Lott_loss x p1', '0', 'Color:', '0 0 0');
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Ref_loss', '0', 'Color:', alt_colors{2});
    fprintf(fileID, '%14s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Disp_Ref_loss x p1', '0', 'Color:', '0 0 0');
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Resp_Lott_loss', '0', 'Color:', alt_colors{3});
    fprintf(fileID, '%9s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Resp_Ref_loss', '0', 'Color:', alt_colors{4});
  end    

  fclose(fileID);
end
end
