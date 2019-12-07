clearvars

fixedButton = 0;

fixed_value = 5;
fixed_prob = 1;

value = [5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
ambig = [.24 .50 .74];
prob = [0.25 0.5 0.75];
jitter = 0;

otherButton = 1;
noResponse = 2;

domains = {'GAINS', 'LOSS'};

% change if move to other folder
root = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
data_path = fullfile(root, 'Behavior data of PTB log'); % root of folders is sufficient
out_path = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\';

addpath(genpath(data_path)); % generate path for all the subject data folder
subjects = getSubjectsInDir(data_path, 'subj');
exclude = [77 1218]; 
% 76-81, PRE-MB. 
% 1218: missing many trials and did not complete study. 
% 77, 95 incomplete data
% need to do 95, incomplete data
% 1269 GL/GL
subjects = subjects(~ismember(subjects, exclude));

choice_file = [out_path 'ra_ptsd_trial_choice_12072019.txt'];
fid = fopen(choice_file, 'w');
fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',...
    'subjID', 'day', 'is_gain', 'reward_var', 'prob', 'ambig', 'choice', 'reward_fix', 'prob_fix');
fclose(fid);

for subj_idx = 1:length(subjects)    
    for domain_idx = 1:length(domains)
        
        %% Load data
        subjectNum = subjects(subj_idx)
        domain = domains{domain_idx};

    %     subjectNum = 1210;
    %     domain = 'GAINS';

        Data = load_mat(subjectNum, domain);    
        
        %% Select variables

        % Exclude non-responses and test questions (where lottery value < fixed value)
        % subj 95 has incomplete data in LOSS
        if subjectNum == 95 && strcmp(domain, 'LOSS')
            choiceDone = zeros(1, 124);
            choiceDone(1:length(Data.choice)) = Data.choice;
            include_indices_all = and(choiceDone ~=0, Data.vals' ~= 4);
            idx_only4_all = and(choiceDone ~=0, Data.vals' == 4);
        else
            include_indices_all = and(Data.choice ~= 0, Data.vals' ~= 4);
            idx_only4_all = and(Data.choice ~= 0, Data.vals' == 4);
        end

        if subjectNum == 95 && strcmp(domain, 'LOSS')
            choice_all = choiceDone;
        else
            choice_all = Data.choice;
        end

        values_all = Data.vals;
        ambigs_all = Data.ambigs;
        probs_all  = Data.probs;
        
        %% Divide data into seperate days
        % this should be done before cleaning data, because the trials with
        % missing responses will be exlcuded after data cleaning
        ntrials_day = 62;
        for day = 1:2
            % select trials for each day
            choice_bothday(day,:) = choice_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            values_bothday(:,day) = values_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            ambigs_bothday(:,day) = ambigs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            probs_bothday(:,day) = probs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            include_indices_bothday(day,:) = include_indices_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            idx_only4_bothday(day,:) = idx_only4_all((day-1) * ntrials_day + 1 : day * ntrials_day);
        end

        %% Refine data for each day
        % exclude $4 trials and no-response trials
        for day = 1 : size(values_bothday, 2)        

            % exclude trials with value = 4 and with no resposne
            choice = choice_bothday(day,include_indices_bothday(day,:));
            values = values_bothday(include_indices_bothday(day,:)',day);
            ambigs = ambigs_bothday(include_indices_bothday(day,:)',day);
            probs = probs_bothday(include_indices_bothday(day,:)',day);

            % Side with lottery is counterbalanced across subjects 
            % -> code 0 as reference choice, 1 as lottery choice
            if Data.refSide == 2
              choice(choice == 2) = 0;
              choice(choice == 1) = 1;
            elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
              choice(choice == 1) = 0;
              choice(choice == 2) = 1;
            end
            % end

            choice4 = choice_bothday(day, idx_only4_bothday(day,:));
            values4 = values_bothday(idx_only4_bothday(day,:)', day);
            ambigs4 = ambigs_bothday(idx_only4_bothday(day,:)', day);
            probs4  = probs_bothday(idx_only4_bothday(day,:)', day);

            if Data.refSide == 2
                choice4(choice4 == 2) = 0;
                choice4(choice4 == 1) = 1;
            elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
                choice4(choice4 == 1) = 0;
                choice4(choice4 == 2) = 1;
            end

            choice_prob_4 = sum(choice4)/length(choice4);
        
            vF = fixed_value * ones(length(choice),1);
            pF = fixed_prob * ones(length(choice),1);

            id = subjectNum * ones(length(choice),1);
            day_idx = day * ones(length(choice),1);
            if strcmp(domain, 'GAINS')
                is_gain = ones(length(choice),1);
            else
                is_gain =  zeros(length(choice),1);
            end
            
            cols = [id, day_idx, is_gain, values, probs, ambigs, choice', vF, pF];

            dlmwrite(choice_file, cols, 'coffset', 0, '-append', 'delimiter', '\t');

        end
    end
    
end

