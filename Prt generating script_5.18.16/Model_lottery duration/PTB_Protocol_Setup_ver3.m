%% Setup and settings
root = 'C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
% Location of data files

% path_subject = fullfile(root, 'Behavior data of PTB log');
path_in = fullfile(root, 'Behavior data fitpar\');

% Location to save PRT files in
path_out = fullfile(root, 'Prt files\');

% Computational parameters
tr = 1; % Temporal resolution, in seconds
trialduration = 6; % How many volumes *including onset* we analyze, in volumes
DiscardedAcquisition = 10; % How many initial volumes we discard, in volumes

% Permissible values: 'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'SV', or '' for no parameter
% NOTE: For more parameters, PTB_Protocol_Gen must be edited to (a) accept them, (b) calculate them
ParametricModType = {'SV', 'RewardValue', 'RiskLevel', 'AmbiguityLevel', ''}; 
% NumParametricWeights is set by the script, depending on which ParametricModType is passed

% Get all subjects
% NOTE: Assuming that all subjects with gains files also have loss files
subj_files = dir([fullfile(path_in), filesep, 'RA_GAINS*fitpar_constrained.mat']);
SubjectNums = zeros(1, length(subj_files));

% Extract subject from filename
for file_idx = 1:length(subj_files)
  fname = subj_files(file_idx).name;
  matches = regexp(fname, 'RA_(?<domain>GAINS|LOSS)_(?<subjectNum>[\d]{1,4})', 'names');
  SubjectNums(file_idx) = str2num(matches.subjectNum); 
end

% Exclude subjects with ineligible imaging data
exclude = [76 77 78 79 80 81 95 101 102 117];
SubjectNums = SubjectNums(~ismember(SubjectNums, exclude));

gainsloss = {'gains', 'loss'}; % 'gains', 'loss', or both

% PRT file parameters
PRT.FileVersion =         '3';
PRT.ResolutionOfTime =    'Volumes';
PRT.Experiment =          'R&A_VA_FMRI';
PRT.NrOfConditions =      '6'; % NOTE: If this changes, PTB_Protocol_Gen must be rewritten. 

PRT.BackgroundColor =     '255 255 255';
PRT.TextColor =           '0 0 0';
PRT.TimeCourseColor =     '0 0 0';
PRT.TimeCourseThick =     '2';
PRT.ReferenceFuncColor =  '30 200 30';
PRT.ReferenceFuncThick =  '2';

PRT.ColorAmb_Loss =       '0 0 77';
PRT.ColorRisk_Loss =      '140 0 0';
PRT.ColorAmb_Gains =      '0 0 255';
PRT.ColorRisk_Gains =     '255 0 0';

%% Run for all of the above
% Iterate for each subject, each domain (each _fitpar data file because loss and gains are separate)
for i = 1:length(SubjectNums)
    for j = 1:length(gainsloss)
        for k = 1:length(ParametricModType)
            % for non parametric design matrics, only 4 condistions.RJ
            if strcmp(ParametricModType{k}, '')
                PRT.NrOfConditions =      '4';
            else
                PRT.NrOfConditions =      '6';
            end
            PTB_Protocol_Gen_ver3(SubjectNums(i), gainsloss{j}, ...
                tr, trialduration, DiscardedAcquisition, ...
                ParametricModType{k}, ...
                path_in, path_out, PRT)
        end
    end
end
