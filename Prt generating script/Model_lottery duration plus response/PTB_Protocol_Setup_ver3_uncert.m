clearvars
close all
%% Input
fitparwave = 'Behavior data fitpar_020519';
prtwave = 'Prt files_02200120';
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
par = readtable('E:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\par nonpar att_allSubj_03202019.csv');

% Computational parameters
tr = 1; % Temporal resolution, in seconds
trialduration = 6; % How many volumes *including onset* we analyze, in volumes
DiscardedAcquisition = 10; % How many initial volumes we discard, in volumes

% Permissible values: 'RewardValue', 'RiskLevel', 'AmbiguityLevel', 'SV', or '' for no parameter
ParametricModType = {'uncert_none'};

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

PRT.BackgroundColor =     '255 255 255'; % white
PRT.TextColor =           '0 0 0'; % black
PRT.TimeCourseColor =     '0 0 0';
PRT.TimeCourseThick =     '2';
PRT.ReferenceFuncColor =  '30 200 30'; % Green
PRT.ReferenceFuncThick =  '2';


PRT.ColorLoss_r25 =    '254 0 3';
PRT.ColorLoss_r50 =    '0 43 209';
PRT.ColorLoss_r75 =   '105 255 42';

PRT.ColorLoss_a24 =   '158 158 255';
PRT.ColorLoss_a50 =   '80 80 231';
PRT.ColorLoss_a74 =   '0 0 168';
PRT.ColorLoss_resp = '0 0 0'; % color for response

PRT.ColorGain_r25 =    '254 0 3';
PRT.ColorGain_r50 =    '0 43 209';
PRT.ColorGain_r75 =   '105 255 42';

PRT.ColorGain_a24 =   '0 229 96';
PRT.ColorGain_a50 =   '0 127 53';
PRT.ColorGain_a74 =   '0 76 32';
PRT.ColorGain_resp = '0 0 0'; % color for response

%% Run for all of the above
% Iterate for each subject, each domain (each _fitpar data file because loss and gains are separate)
for i = 1:length(SubjectNums)
    for j = 1:length(gainsloss)
        for k = 1:length(ParametricModType)
            % for non parametric design matrices 13 condistions (6 uncertainty * 2 domains + 1 response)
            if strcmp(ParametricModType{k}, 'uncert_none')
                PRT.NrOfConditions =      '13';
            end
            PTB_Protocol_Gen_ver3_uncert(SubjectNums(i), gainsloss{j}, ...
                tr, trialduration, DiscardedAcquisition, ...
                ParametricModType{k}, ...
                path_in, path_out, PRT, par(par.id == SubjectNums(i),:))
        end
    end
end
