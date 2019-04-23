% This script calculate subject specific sv for each trial, and mid-split
% low/high by labeling as 0-low, 1-high. Separate for gain and loss trials

% Author: Ruonan Jia 4.23.2019

% Input: 
% - Fitted parameters, should be a data sheet
% - Subject log .mat
% Output:
% - SV per trial
% - High/Low labeling 

%%
clearvars

fitparwave = 'Behavior data fitpar_04232019';
% outputwave = '_04232019';
isconstrained = 2;
% exclude should match those in the fit_parameters.m script
exclude = [77 1218]; 
% TEMPORARY: subjects incomplete data (that the script is not ready for)

%% folder and subjects
% root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
root = '/Users/jiaruonan/Desktop/cmhn_final';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function

% Exclude subjects with bad imaging data
exclude = [61 76 78 79 80 81 95 100 101 102 104 117 1210 1220 1234 1235 1250 1251 1268 1269 1272 1289 1300 1301 1303 1308 1316 1326 1337 1347 1357 1360];

subjects = subjects(~ismember(subjects, exclude));

path_out = fullfile(root, 'Fitpar files', fitparwave, filesep);

domains = [1, 0];

% % defining monetary values
% valueP = [4 5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
% value = repmat(valueP,6,1);
% valueN = [-4 -5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120];
% % six risk and ambig levels
% probs = [0.25; 0.5; 0.75; 0.5; 0.5; 0.5];
% ambigs = [0; 0; 0; 0.24; 0.5; 0.74];

par = readtable(fullfile(root,'Clinical and behavioral/par nonpar att_allSubj_03202019.xlsx'));

%% Load Gains and Loss Data files
% Add the directory & all subdirs to path
addpath(genpath(data_path)); 

for subject_idx = 1:length(subjects)
    
    subjectNum = subjects(subject_idx);
    
    load(['RA_GAINS_' num2str(subjectNum) '.mat']);
    gdata = Data;
    load(['RA_LOSS_' num2str(subjectNum) '.mat']);
    ldata = Data;

    clearvars Data; % avoid accidental name collision
    
    for domain_idx = 1:length(domains)
        
        is_gains = domains(domain_idx);
        
        % Pick the domain to analyze
        if (is_gains)
          data = gdata;
        else
          data = ldata;
        end

        % model fitted parameters for calculating subjective value
        alpha = par.alpha(par.isGain == is_gains);
        beta = par.beta(par.isGain == is_gains);

        %% Compute subjective value of each choice
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
        
        % save sv into data structure
        if is_gains
            Data.sv = sv;
        elseif ~is_gains
            Data.sv = -sv;
        end
        
        % label mid-split high/low trials
        % find median
        
    end
end
        
        