clearvars
close all
%% Input
fitparwave = 'Behavior data fitpar_102320';
prtwave = 'Prt files_102320';
% % Instead use input dialog to speficy file folders
% filefolders = inputdlg({'Fitpar date', 'Prt date'},'Specify file folders');
% fitparwave = ['Behavior data fitpar_' filefolders{1}];
% prtwave = ['Prt files_' filefolders{2}];

% Exclude subjects with bad imaging data
exclude = [61 76 78 79 80 81 100 101 102 104 117 1210 1220 1234 1235 1250 1251 1268 1269 1272 1289 1300 1301 1303 1308 1316 1326 1337 1347 1357 1360];
% subject 95 has incomplete data
% subejct 1269 GL/GL

%% Setup and settings
root = 'E:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
% Location of data files
% path_subject = fullfile(root, 'Behavior data of PTB log');
path_in = fullfile(root,  'Fitpar files', fitparwave, filesep);
% Location to save PRT files in
path_out = fullfile(root, 'Prt files', prtwave, filesep);

% create output folder if does not exist
if exist(path_out) ==0;
    mkdir(fullfile(root, 'Prt files'), prtwave);
end

% read model fitted attitudes
% because some subjects used unconstrained, some used constrained, could
% not easily read from fitpar data structure
% par = readtable('D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\par nonpar att_allSubj_03202019.csv');

% Computational parameters
tr = 1; % Temporal resolution, in seconds
trialduration = 6; % How many volumes *including onset* we analyze, in volumes
DiscardedAcquisition = 10; % How many initial volumes we discard, in volumes

% Permissible values: 'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'SV', or '' for no parameter
% NOTE: For more parameters, PTB_Protocol_Gen must be edited to (a) accept them, (b) calculate them
% ParametricModType = {'SV', 'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'none'}; 
% ParametricModType = {'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'none'}; 
% ParametricModType = {'SV'};
% ParametricModType = {'CV'};
ParametricModType = {'binary_by_sv'};
% ParametricMordType = {'none'};

% % Instead use input dialog
% param = inputdlg({'Enter Parametric Modulator name'}, 'Parametric Modulator');
% ParametricModType = param;
% NumParametricWeights is set by the script, depending on which ParametricModType is passed

% Get all subjects
% NOTE: Assuming that all subjects with gains files also have loss files
subj_files = dir([fullfile(path_in), filesep, 'RA_GAINS*fitpar.mat']);
SubjectNums = zeros(1, length(subj_files));

% Extract subject from filename
for file_idx = 1:length(subj_files)
  fname = subj_files(file_idx).name;
  matches = regexp(fname, 'RA_(?<domain>GAINS|LOSS)_(?<subjectNum>[\d]{1,4})', 'names');
  SubjectNums(file_idx) = str2num(matches.subjectNum); 
end

SubjectNums = SubjectNums(~ismember(SubjectNums, exclude));

% SubjectNums = [75];

gainsloss = {'gains', 'loss'}; % 'gains', 'loss', or both

% PRT file parameters
PRT.FileVersion =         '3';
PRT.ResolutionOfTime =    'Volumes';
PRT.Experiment =          'R&A_VA_FMRI';
PRT.NrOfConditions =      '8'; % NOTE: If this changes, PTB_Protocol_Gen must be rewritten. 

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
PRT.ColorResp =           '0 0 0';

%% Run for all of the above
% Iterate for each subject, each domain (each _fitpar data file because loss and gains are separate)
for i = 1:length(SubjectNums)
    for j = 1:length(gainsloss)
        for k = 1:length(ParametricModType)
            % for non parametric design matrices, only 13 condistions (6x2 lottery duration + 1 responses)
            PRT.NrOfConditions =      '13';

            PTB_Protocol_Gen_ver3_binary_by_sv(SubjectNums(i), gainsloss{j}, ...
                tr, trialduration, DiscardedAcquisition, ...
                ParametricModType{k}, ...
                path_in, path_out, PRT)
        end
    end
end
