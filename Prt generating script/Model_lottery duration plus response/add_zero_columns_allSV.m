%%  This script adds column of zeros to the SDM files with parametric modulator of (CV) chosen subjective value.
%   Adding column of zeros is random for CV. Ideally, subject chose both
%   fixed and varied option during a scan, but sometimes, expecially in
%   Loss, they just chose the fixed option. When that happened, the sdm created from prt
%   will not cotain a column for that parametric predictor

%   After saving the new SDM, the number of RTCMatrix column and the number
%   of predictor colors will automatically match the new SDMMatrix.
clearvars
%% 
sdmwave = 'Sdm files_091019';
predictorNums = 4; % the correct number of predictors
PredictorNames_new = {'Display', 'Display x p1', 'Resp', 'Constant'};

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Sdm files';
pathin = fullfile(root, sdmwave, filesep);
pathout = fullfile(root, sdmwave, 'AddingZeros', filesep);

if exist(pathout) == 0
    mkdir(pathout)
end

% find the files to add zeros
param2add = {'allSV'};
for i = 1:length(param2add)
    files2add = dir([pathin '*_' param2add{i} '.sdm']);
      for s = 1:length(files2add)
            sdm_name = files2add(s).name
            sdm = xff([pathin sdm_name]);
            sdm.NrOfPredictors = predictorNums;
            sdm.FirstConfoundPredictor = predictorNums;
            PredictorNames_old = sdm.PredictorNames;
            sdm.PredictorNames = PredictorNames_new;

            % find the missing column
            miss = 0; %How many columns are missing
            for m = 1:length(PredictorNames_new)
                exist = 0;
                for n = 1:length(PredictorNames_old)
                     if strcmp(PredictorNames_old(n), PredictorNames_new(m))
                        exist = exist+1; %the m-th column in PredictorNames17 is found in PredictorNames15
                     end
                end
                if exist == 0; %the m-th column in PredictorNames17 is missing in PredictorNames15
                    miss = miss+1;
                    mismatch(miss)= m; % store which column of PredictorNames17 is missing
                end
            end
            
            if miss ~= 0              
                % insert the missing column and fill it with zeros
                a = zeros(490,predictorNums); % volume number x condition numbers
                i=1; %column number for new SDM 
                j=1; %column number for old SDM 
                while i < (predictorNums + 1)
                    if isempty(find(mismatch(mismatch == i)))== 1 %if the column is not missing
                        a(:,i) = sdm.SDMMatrix(:,j);
                        i = i+1;
                        j = j+1;
                    else
                        i=i+1;
                    end
                end
                sdm.SDMMatrix = a;

                
            end
            % save it in its original file name in the different folder
            sdm.SaveAs([pathout sdm_name]);
      end
end
  
% move the missing-column  _RiskLevel and _Ambiguitylevel sdm to the old folder
desti_old = fullfile(pathin,'sdm_missingColumns\');
source_sv = fullfile(pathin, '*_allSV.sdm');
   
movefile(source_sv,desti_old);

% move the adding-column sdm out of the AddingZeros folder
source_sv = fullfile(pathout, '*_allSV.sdm');

movefile(source_sv,pathin);

rmdir(pathout) % remove AddingZeros folder
        
        
       