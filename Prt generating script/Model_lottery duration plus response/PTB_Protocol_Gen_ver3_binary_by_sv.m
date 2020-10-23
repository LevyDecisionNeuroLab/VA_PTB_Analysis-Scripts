function PTB_Protocol_Gen_ver3_binary_by_sv(subjectNum, gainsloss, tr, trialduration, DiscAcq, ParametricMod, path_in, path_out, PRT)
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
permissible_parameters = {'binary_by_sv'};

if strcmp(ParametricMod, 'binary_by_sv')
  NumParametricWeights = 0;
else
  error('Aborting: `ParametricMod` must be set to a valid parameter value!')
  return
end
PRT.ParametricWeights = num2str(NumParametricWeights);

% For PRT properties, fix colors into correct order
if ~is_gains
  Colors = {PRT.ColorAmb_Loss, PRT.ColorRisk_Loss};
  alt_colors = {PRT.ColorAmb_Gains, PRT.ColorRisk_Gains};
else
  Colors = {PRT.ColorAmb_Gains, PRT.ColorRisk_Gains};
  alt_colors = {PRT.ColorAmb_Loss, PRT.ColorRisk_Loss};
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

%% chocie
choice = data.choice;
choice(choice==0) = NaN;

if data.refSide == 2
  choice(choice == 2) = 0;
  choice(choice == 1) = 1;
elseif data.refSide == 1 % Careful: rerunning this part will make all choices 0
  choice(choice == 1) = 0;
  choice(choice == 2) = 1;
end
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

  % Divide blocks by type of lottery (store indices with risk-only vs. risk-and-ambiguity)
  if ~is_gains
      amb_sv1_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 1;
      amb_sv2_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 2;
      amb_sv3_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 3;

      risk_sv1_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 1;
      risk_sv2_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 2;
      risk_sv3_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 3;
  
  else
      amb_sv4_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 4;
      amb_sv5_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 5;
      amb_sv6_index = data.ambigs(current_block_range) > 0 & data.sv_label(current_block_range) == 6;
      risk_sv4_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 4;
      risk_sv5_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 5;
      risk_sv6_index = data.ambigs(current_block_range) == 0 & data.sv_label(current_block_range) == 6;

  end
  %% Select what parametric value to write (or not write) into PRT file
  % Store the basic onset/offset, computed earlier
  
  if ~is_gains
      block_amb_sv1 = [onsets(amb_sv1_index,1) offsets(amb_sv1_index,1)];
      block_amb_sv2 = [onsets(amb_sv2_index,1) offsets(amb_sv2_index,1)];
      block_amb_sv3 = [onsets(amb_sv3_index,1) offsets(amb_sv3_index,1)];

      block_risk_sv1 = [onsets(risk_sv1_index,1) offsets(risk_sv1_index,1)];
      block_risk_sv2 = [onsets(risk_sv2_index,1) offsets(risk_sv2_index,1)];
      block_risk_sv3 = [onsets(risk_sv3_index,1) offsets(risk_sv3_index,1)];
  
  else
      block_amb_sv4 = [onsets(amb_sv4_index,1) offsets(amb_sv4_index,1)];
      block_amb_sv5 = [onsets(amb_sv5_index,1) offsets(amb_sv5_index,1)];
      block_amb_sv6 = [onsets(amb_sv5_index,1) offsets(amb_sv5_index,1)];
      block_risk_sv4 = [onsets(risk_sv4_index,1) offsets(risk_sv4_index,1)];
      block_risk_sv5 = [onsets(risk_sv5_index,1) offsets(risk_sv5_index,1)];
      block_risk_sv6 = [onsets(risk_sv5_index,1) offsets(risk_sv5_index,1)];
      
  end
  
  block_choice = choice(current_block_range)';
  
  resp = [offsets(~isnan(block_choice),2) offsets(~isnan(block_choice),2)]; % response for all trials with response

  

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


  fprintf(fileID, '\r\n%15s %7s\r\n\r\n', 'NrOfConditions:', PRT.NrOfConditions);

   % NOTE: Empty conditions -- set here for purposes of consistent order. 
  % Equivalent but opposite block further below
  if is_gains
    % loss predictors are empty
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv1_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv2_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv3_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv1_Display', '0', 'Color:', alt_colors{2})
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv2_Display', '0', 'Color:', alt_colors{2})
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv3_Display', '0', 'Color:', alt_colors{2});

    % Print the ambiguity block for given domain
    fprintf(fileID, '%15s\r\n', ['Amb_sv4_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv4)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv4');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});

    fprintf(fileID, '%15s\r\n', ['Amb_sv5_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv5)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv5');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});

    fprintf(fileID, '%15s\r\n', ['Amb_sv6_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv6)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv6');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});    
    
    % Print the risk block for given domain
    fprintf(fileID, '%16s\r\n', ['Risk_sv4_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv4)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv4');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});    

    fprintf(fileID, '%16s\r\n', ['Risk_sv5_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv5)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv5');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});    

    fprintf(fileID, '%16s\r\n', ['Risk_sv6_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv6)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv6');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});    
    
  else

    % Print the ambiguity block for given domain
    fprintf(fileID, '%15s\r\n', ['Amb_sv1_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv1)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv1');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});

    fprintf(fileID, '%15s\r\n', ['Amb_sv2_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv2)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv2');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});

    fprintf(fileID, '%15s\r\n', ['Amb_sv3_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_amb_sv3)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_amb_sv3');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{1});    
    
    % Print the risk block for given domain
    fprintf(fileID, '%16s\r\n', ['Risk_sv1_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv1)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv1');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});    

    fprintf(fileID, '%16s\r\n', ['Risk_sv2_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv2)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv2');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});    

    fprintf(fileID, '%16s\r\n', ['Risk_sv3_Display']);
    fprintf(fileID, '%4s\r\n', num2str(length(block_risk_sv3)));
    fprintf(fileID, '%4.0f\t %3.0f\r\n', block_risk_sv3');
    fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', Colors{2});         
      
     % gain predictors are empty
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv4_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv5_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%15s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Amb_sv6_Display', '0', 'Color:', alt_colors{1});
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv4_Display', '0', 'Color:', alt_colors{2})
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv5_Display', '0', 'Color:', alt_colors{2})
    fprintf(fileID, '%16s\r\n%3s\r\n%4s %6s\r\n\r\n', 'Risk_sv6_Display', '0', 'Color:', alt_colors{2});
     
  end

  
  

  
  
  % Print the response for all trials
  fprintf(fileID, '%4s\r\n', 'Resp');
  fprintf(fileID, '%4s\r\n', num2str(length(resp)));
  fprintf(fileID, '%4.0f\t %3.0f\r\n', resp');
  fprintf(fileID, '%6s %7s\r\n\r\n', 'Color:', PRT.ColorResp);

  fclose(fileID);
end
end
