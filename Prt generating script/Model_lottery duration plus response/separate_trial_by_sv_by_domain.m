clearvars
close all

%% behavioral fitting results
behav_path = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral';
% add path of function 'ambig_utility.m'
addpath 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\VA_PTB_Analysis-Scripts\Model fitting script'
% read data contains the fitted parameters
% par = readtable('all data_09152018.xlsx');
% par = readtable('par nonpar att_allSubj_day1day2_04082019.csv');
par = readtable(fullfile(behav_path,'par nonpar att_allSubj_day1day2_08262019.csv'));

path_out = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Fitpar files\Behavior data fitpar_102320';

if ~exist(path_out)
    mkdir(path_out)
end

%% folder and subjects
root = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function

% Exclude subjects with bad imaging data
% exclude = [61 76 78 79 80 81 95 100 101 102 104 117 1210 1220 1234 1235 1250 1251 1268 1269 1272 1289 1300 1301 1303 1308 1316 1326 1337 1347 1357 1360];
exclude =[77 1218];

subjects = subjects(~ismember(subjects, exclude));
domains = [1,0];


%% Load Gains and Loss Data files
% Add the directory & all subdirs to path
addpath(genpath(data_path)); 

for subject_idx = 1:length(subjects)
%     subject_idx = 2;
    
    subjectNum = subjects(subject_idx);
    
    load(['RA_GAINS_' num2str(subjectNum) '.mat']);
    gdata = Data;
    load(['RA_LOSS_' num2str(subjectNum) '.mat']);
    ldata = Data;

    clearvars Data; % avoid accidental name collision
    
    %% loop domain
    % for each domain, break sv into 3 tiers
    for domain_idx = 1:length(domains)

%         domain_idx = 1;
        
        is_gains = domains(domain_idx);
        
        % excluded
        if  (subjectNum == 95 && ~is_gains) || subjectNum == 101
            continue % skip the for loop
        end
  
        % Pick the domain to analyze
        if (is_gains)
          data = gdata;
        else
          data = ldata;
        end
        
        %% table for saving sv for a single participant
        % columns: isDay1, isAmbig, sv, label
        sv_table = zeros(length(data.choice),4);

       %% model-fitting parameters
        % model fitted parameters for calculating subjective value, read from sheet
        alpha_day1 = par.alpha(par.isGain == is_gains & par.isDay1 == 1 & par.id == subjectNum);
        beta_day1 = par.beta(par.isGain == is_gains & par.isDay1 == 1 & par.id == subjectNum);

        alpha_day2 = par.alpha(par.isGain == is_gains & par.isDay1 == 0 & par.id == subjectNum);
        beta_day2 = par.beta(par.isGain == is_gains & par.isDay1 == 0 & par.id == subjectNum);
        
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
        
        %% determine risk or ambiguity
        trial_isAmbig = zeros(length(data.choice),1);
        trial_isAmbig = data.ambigs ~= 0;
        
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
        
        % correct based on domain
        if is_gains
            sv = sv;
        elseif ~is_gains
            sv = -sv;
        end
        
        %% save sv into a data table
        sv_table(:,1) = trial_isDay1;
        sv_table(:,2) = trial_isAmbig;
        sv_table(:,3) = sv;
        
        %% bin trials based on SV, separate risk and ambig
%         bin_n = 3; % number of bins

        % mask of risk and ambiguous trials
        mask_ambig = sv_table(:,2) == 1;
        mask_risk = sv_table(:,2) == 0;
        
        % find critical values and lable trials 
        sv_ambig = sv_table(mask_ambig, 3);
        sv_ambig_uniq = unique(sv_ambig); 
        critical_ambig = quantile(sv_ambig_uniq, [.33, .66, ]);           

        label_ambig = zeros(length(sv_ambig),1);
        label_ambig(sv_ambig<= critical_ambig(1)) = 1;
        label_ambig(sv_ambig <= critical_ambig(2) & sv_ambig > critical_ambig(1)) = 2;
        label_ambig(sv_ambig > critical_ambig(2)) = 3;
        
        sv_risk = sv_table(mask_risk, 3);
        sv_risk_uniq = unique(sv_risk); 
        critical_risk = quantile(sv_risk_uniq, [.33, .66, ]);           

        label_risk = zeros(length(sv_risk),1);
        label_risk(sv_risk<= critical_risk(1)) = 1;
        label_risk(sv_risk <= critical_risk(2) & sv_risk > critical_risk(1)) = 2;
        label_risk(sv_risk > critical_risk(2)) = 3;        
        
        % save labels into sv table   
        sv_table(mask_ambig,4) = label_ambig;
        sv_table(mask_risk,4) = label_risk;
        
        % if gains, turn 1 2 3 into 4 5 6
        if is_gains == 1
           sv_table(sv_table(:,4)==1, 4) = 4;
           sv_table(sv_table(:,4)==2, 4) = 5;
           sv_table(sv_table(:,4)==3, 4) = 6;
        end
        
        % correct zeros
        sv_table(sv_table(:,4)==0, 4) = NaN;
        
        %% save into data
        data.sv_label = sv_table(:,4);
        Data = data;
        
        if is_gains == 1
            save(fullfile(path_out, ['RA_GAINS_' num2str(subjectNum) '_fitpar.mat']), 'Data')
        else
            save(fullfile(path_out, ['RA_LOSS_' num2str(subjectNum) '_fitpar.mat']), 'Data')
        end
    end
    


end



