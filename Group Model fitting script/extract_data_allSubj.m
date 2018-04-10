% extract all subjects data into a big table

clearvars
close all

%% Set up loading + subject selection
% TODO: Maybe grab & save condition somewhere?
% fitparwave = 'Behavior data fitpar_04030118';

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
data_path = fullfile(root, 'Behavior data of PTB log/'); % root of folders is sufficient
data_out_path = fullfile(root,'Fitpar files');
%graph_out_path  = fullfile(root, 'ChoiceGraphs/');

% if exist(fitpar_out_path)==0
%     mkdir(fullfile(root,'Fitpar files'),fitparwave)
% end

addpath(genpath(data_path)); % generate path for all the subject data folder

subjects = getSubjectsInDir(data_path, 'subj');
exclude = [77; 1218]; 

% load log files, determine which subject to exclude
log = readtable('D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\log_allSubj.xlsx');

exclude_behavior = log.id(log.isExcluded_behavior == 1);

% 76-81, PRE-MB. 
% 1218: missing many trials and did not complete study. 
% 77, 95 incomplete data
% need to do 95, incomplete data
% 1269 GL/GL

subjects = subjects(~ismember(subjects, [exclude; exclude_behavior]));
% subjects = [95];

%% load all subjects data into a big table

subj_all = [];
choice_all = [];
ambig_all = [];
prob_all = [];
val_all = [];
isgain_all = [];
group_all = {};


for subj_idx = 1:length(subjects)
%     subj_idx = 1;
  domains = {'GAINS', 'LOSS'};

  for domain_idx = 1:length(domains)
%       domain_idx = 1;
    subjectNum = subjects(subj_idx);
    domain = domains{domain_idx};
    
    fname = sprintf('RA_%s_%d.mat', domain, subjectNum);
    load(fname) % produces variable `Data`
    
    %% Refine variables

    % Exclude non-responses and test questions (where lottery value < fixed value)
    % subj 95 has incomplete data in LOSS; ToDo: change the logic to detect
    % incomplete data
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        choiceDone = zeros(1, 124);
        choiceDone(1:length(Data.choice)) = Data.choice;
        include_indices = and(choiceDone ~=0, Data.vals' ~= 4);
    else
        include_indices = and(Data.choice ~= 0, Data.vals' ~= 4);
    end
    
    choice = Data.choice(include_indices);
    values = Data.vals(include_indices);
    ambigs = Data.ambigs(include_indices);
    probs  = Data.probs(include_indices);
    
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
    
    % choice data for $4 only, for rationality check only   
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        idx_only4 = and(choiceDone ~=0, Data.vals' == 4);
    else 
        idx_only4 = and(Data.choice ~= 0, Data.vals' == 4);
    end

    
    choice4 = Data.choice(idx_only4);
    values4 = Data.vals(idx_only4);
    ambigs4 = Data.ambigs(idx_only4);
    probs4  = Data.probs(idx_only4);
    
    if Data.refSide == 2
        choice4(choice4 == 2) = 0;
        choice4(choice4 == 1) = 1;
    elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
        choice4(choice4 == 1) = 0;
        choice4(choice4 == 2) = 1;
    end
    
    choice_prob_4 = sum(choice4)/length(choice4);
    
    %% save variables in the big vectors
    subj_all = [subj_all; repmat(subjects(subj_idx),length(choice),1)];
    choice_all = [choice_all; choice'];
    ambig_all = [ambig_all; ambigs];
    prob_all = [prob_all; probs];
    val_all = [val_all; values];
    group_all = [group_all; repmat(log.group(log.id == subjects(subj_idx)),length(choice),1)];
    
    if strcmp(domain, 'GAINS')
        isgain_all = [isgain_all; ones(length(choice),1)];
    elseif strcmp(domain, 'LOSS')
        isgain_all = [isgain_all; zeros(length(choice),1)];
    end        
  end
end

% create table
tb = table(subj_all, isgain_all, choice_all, ambig_all, prob_all, val_all, group_all, 'VariableNames',...
    {'id', 'isgain', 'choice', 'ambig', 'prob', 'val', 'group'});

save(fullfile(data_out_path, 'choice_data_allSubj.mat'), 'tb')
