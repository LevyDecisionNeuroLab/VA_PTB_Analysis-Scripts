%%  This script adds the motion correction sdm to the task sdm

% History: written RJ 8.21.2018

clearvars

%%
sdmwave = 'Sdm files_042418';
sdmtype = 'none';

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Sdm files';
pathin = fullfile(root, sdmwave, sdmtype, filesep);
pathmotion = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\motion correction\';
pathout = fullfile(root, sdmwave, sdmtype, 'motion corrected', filesep);

if exist(pathout) == 0
    mkdir(pathout)
end

% all sdm file name
files2combine = dir([pathin '*.sdm']);
filesmotion = dir([pathmotion '*.sdm']);


for s = 1:length(files2combine)
    % test    
    
    % sdm before combining
    sdm_name = files2combine(s).name
    sdm = xff([pathin sdm_name]);
    
    NrOfPredictors_old = sdm.NrOfPredictors;
    PredictorNames_old = sdm.PredictorNames;
    Matrix_old = sdm.SDMMatrix;       
    
    % find the motion correction file
    m = s; % only if the order of the original sdms and motion-correct sdms are matched in the folder, should manually check it. Checked it, totally matches.
    sdmmotion_name = filesmotion(m).name;
    
    % motion correction sdm
    sdmmotion = xff([pathmotion sdmmotion_name]);
    
    PredictorNames_motion = sdmmotion.PredictorNames;
    Matrix_motion = sdmmotion.SDMMatrix;
    NrOfPredictors_motion = sdmmotion.NrOfPredictors;
    
    % new sdm components
    Matrix_new = [Matrix_old,Matrix_motion];
    PredictorNames_new = [PredictorNames_old,PredictorNames_motion];
    NrOfPredictors_new = NrOfPredictors_old + NrOfPredictors_motion;
    
    % new sdm
    sdm.NrOfPredictors = NrOfPredictors_new;
    sdm.PredictorNames = PredictorNames_new;
    sdm.SDMMatrix = Matrix_new;
%     sdm.FirstConfoundPredictor = predictorNums; % this should not change    
    
    
    sdm_name_new = [sdm_name(1:length(sdm_name)-4) '_motioncorrected.sdm'];

    % save it in its original file name in the different folder
    sdm.SaveAs([pathout sdm_name_new]);

end
