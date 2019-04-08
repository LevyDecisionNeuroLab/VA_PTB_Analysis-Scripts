clearvars
close all

%% Input set up
output_wave = '_04082019';
isdivided = 1; % if fit model to data for each day. 0-fit model on all data, 1-fit model on each day's data should get two values per subject for each parameter

%% Set up loading + subject selection
% TODO: Maybe grab & save condition somewhere?

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
data_path = fullfile(root, 'Behavior data of PTB log/'); % root of folders is sufficient
out_path = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\';

addpath(genpath(data_path)); % generate path for all the subject data folder

subjects = getSubjectsInDir(data_path, 'subj');
exclude = [77 1218]; 
% 76-81, PRE-MB. 
% 1218: missing many trials and did not complete study. 
% 77, 95 incomplete data
% need to do 95, incomplete data
% 1269 GL/GL

subjects = subjects(~ismember(subjects, exclude));
% subjects = [95];
% idx95 = find(subjects == 95);

% output setup
if isdivided == 0
    summary_file = ['error' output_wave '.txt'];
    fid_both = fopen([out_path summary_file],'w');
else
    summary_file_day1 = ['error_day1' output_wave '.txt'];
    summary_file_day2 = ['error_day2' output_wave '.txt'];
    fid_day1 = fopen([out_path summary_file_day1],'w');
    fid_day2 = fopen([out_path summary_file_day2],'w');
end

%% loop subject
for subj_idx = 1:length(subjects)
%     domains = {'LOSS'};
    domains = {'GAINS', 'LOSS'};

  for domain_idx = 1:length(domains)
    subjectNum = subjects(subj_idx);
    domain = domains{domain_idx};
    
%     subjectNum = 1210;
%     domain = 'GAINS';


    fname = sprintf('RA_%s_%d.mat', domain, subjectNum);
    load(fname) % produces variable `Data`
    
    %% Refine variables

    % Exclude non-responses and test questions (where lottery value < fixed value)
    % subj 95 has incomplete data in LOSS
    % incomplete data
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        choiceDone = zeros(1, 124);
        choiceDone(1:length(Data.choice)) = Data.choice;
        include_indices_all = Data.vals' ~= 4;
        idx_only4_all = Data.vals' == 4;
        idx_error_all = and(choiceDone ~= 0, Data.vals' == 5);
    else
        include_indices_all = Data.vals' ~= 4;
        idx_only4_all = Data.vals' == 4;
        idx_error_all = and(Data.choice ~= 0, Data.vals' == 5);
    end
        
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        choice_all = choiceDone;
    else
        choice_all = Data.choice;
    end
       
    values_all = Data.vals;
    ambigs_all = Data.ambigs;
    probs_all  = Data.probs;
    
    %% Divide data and fit data for each day separately
    % this should be done before cleaning data, because the trials with
    % missing responses will be exlcuded after data cleaning
%     ntrials_day = length(values_all)/2;
    ntrials_day = 62;
    if isdivided == 1
        for day = 1:2
            % select trials for each day
            choice_bothday(day,:) = choice_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            values_bothday(:,day) = values_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            ambigs_bothday(:,day) = ambigs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            probs_bothday(:,day) = probs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            include_indices_bothday(day,:) = include_indices_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            idx_only4_bothday(day,:) = idx_only4_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            idx_error_bothday(day,:) = idx_error_all((day-1) * ntrials_day + 1 : day * ntrials_day);
        end
    elseif isdivided == 0
            choice_bothday = choice_all;
            values_bothday = values_all;
            ambigs_bothday = ambigs_all;
            probs_bothday = probs_all;
            include_indices_bothday = include_indices_all;
            idx_only4_bothday = idx_only4_all;
            idx_error_bothday = idx_error_all;
    end
       
    % clean and fit data for each day
    for day = 1 : size(values_bothday, 2)        
        %% Clean data and calculate
        
        % exclude trials with value = 4 and with no resposne
        choice = choice_bothday(day,include_indices_bothday(day,:));
        values = values_bothday(include_indices_bothday(day,:)',day);
        ambigs = ambigs_bothday(include_indices_bothday(day,:)',day);
        probs = probs_bothday(include_indices_bothday(day,:)',day);
        
        % Side with lottery is counterbalanced across subjects 
        % -> code 0 as reference choice, 1 as lottery choice
        % TODO: Double-check this is so? - This is true(RJ)
        % TODO: Save in a different variable?
        % if sum(choice == 2) > 0 % Only if choice has not been recoded yet. RJ-Not necessary
        % RJ-If subject do not press 2 at all, the above if condition is problematic
          if Data.refSide == 2
              choice(choice == 2) = 0;
              choice(choice == 1) = 1;
          elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
              choice(choice == 1) = 0;
              choice(choice == 2) = 1;
          end
        % end
        
        %% missing trials
        
        %%  calculate choice prob for $4 trials
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
        
        %%  calculate choice prob for $5 trials
        choice_error = choice_bothday(day, idx_error_bothday(day,:));
        values_error = values_bothday(idx_error_bothday(day,:)', day);
        ambigs_error = ambigs_bothday(idx_error_bothday(day,:)', day);
        probs_error  = probs_bothday(idx_error_bothday(day,:)', day);

        if Data.refSide == 2
            choice_error(choice_error == 2) = 0;
            choice_error(choice_error == 1) = 1;
        elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
            choice_error(choice_error == 1) = 0;
            choice_error(choice_error == 2) = 1;
        end

        choice_prob_error = sum(choice_error)/length(choice_error);
        
        %% print
        if isdivided == 0
            fprintf(fid_both,'%s\t%s\t%f\n',...
                num2str(subjectNum), domain, choice_prob_error);
        elseif isdivided == 1
            if day == 1
                fprintf(fid_day1,'%s\t%s\t%f\n',...
                    num2str(subjectNum), domain, choice_prob_error);
            elseif day == 2
                fprintf(fid_day2,'%s\t%s\t%f\n',...
                    num2str(subjectNum), domain, choice_prob_error);
            end
        end
    end
  end
end

if isdivided == 0
    fclose(fid_both)
else
    fclose(fid_day1)
    fclose(fid_day2)
end
            
            
        
