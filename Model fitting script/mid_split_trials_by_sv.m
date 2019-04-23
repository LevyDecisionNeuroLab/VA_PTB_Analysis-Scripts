% This script calculate subject specific sv for each trial, and mid-split
% low/high by labeling as 0-low, 1-high. Separate for gain and loss trials

% Author: Ruonan Jia 4.23.2019

% Input: 
% - Fitted parameters, should be a data sheet
% - Subject log .mat
% Output:
% - SV per trial, Data.sv
% - SV median, Data.sv_median
% - High/Low labeling based on value: Data.sv_label_val
% - High/Low labeling based on saliency: Data.sv_label_sal

%%
clearvars

%% folder and subjects
% root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
root = '/Users/jiaruonan/Desktop/cmhn_final';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function

% Exclude subjects with bad imaging data
% exclude = [61 76 78 79 80 81 95 100 101 102 104 117 1210 1220 1234 1235 1250 1251 1268 1269 1272 1289 1300 1301 1303 1308 1316 1326 1337 1347 1357 1360];
exclude =[77 1218];

subjects = subjects(~ismember(subjects, exclude));

% test
% subjects = [125];

fitparwave = 'Behavior data fitpar_04232019';
path_out = fullfile(root, 'Fitpar files', fitparwave, filesep);

if ~exist(path_out)
    mkdir(path_out)
end

domains = [1, 0];

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
          Data = gdata;
        else
          Data = ldata;
        end

        % model fitted parameters for calculating subjective value
        alpha = par.alpha(par.isGain == is_gains & par.id == subjectNum);
        beta = par.beta(par.isGain == is_gains & par.id == subjectNum);

        %% Compute subjective value of each choice
        % Use the best fit for every subjects (most should be unconstrained, use constrained for a few subjects)
        for reps = 1:length(Data.choice)
          sv(reps, 1) = ambig_utility(0, ...
              Data.vals(reps), ...
              Data.probs(reps), ...
              Data.ambigs(reps), ...
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
        sv_median = median(Data.sv);
        Data.sv_median = sv_median;
        % label mid-split, based on value
        Data.sv_label_val(Data.sv <= sv_median)  = 0;
        Data.sv_label_val(Data.sv > sv_median) = 1;
        
        % label mid-split, based on saliency
        if is_gains
            Data.sv_label_sal(Data.sv <= sv_median)  = 0;
            Data.sv_label_sal(Data.sv > sv_median) = 1; 
        elseif ~is_gains
            Data.sv_label_sal(Data.sv <= sv_median)  = 1;
            Data.sv_label_sal(Data.sv > sv_median) = 0;
        end
        
        if is_gains
            domain = 'GAINS';
        elseif ~is_gains
            domain = 'LOSS';
        end
        
        % save data into fitpar
        save(fullfile(path_out, ['RA_' domain '_' num2str(subjectNum) '_fitpar.mat']), 'Data')
        
    end
end
        
