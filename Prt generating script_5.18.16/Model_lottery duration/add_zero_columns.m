%%  This script adds column of zeros to the SDM files with parametric modulator of AmbiguityLevel or RiskLevel.
%   After saving the new SDM, the number of RTCMatrix column and the number
%   of predictor colors will automatically match the new SDMMatrix.
%% 
path = 'C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan\SDM files\';
pathout = 'C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan\SDM files\AddingZeros\';


% find the files to add zeros, _AmbiguityLevel and _RiskLevel
files2add = dir([path '*_AmbiguityLevel.sdm']); % change for _RiskLevel or _AmbiguityLevel

  for s = 1:length(files2add)
      
%     for run = 1:8
%         
%         subject = 3;
%         run = 1;
%         
%         session = fix(run/4)+1; %session (day) number for each run
%         
%         if ismember(run,[1 2 7 8]) %check if this run is gain or loss block
%             gainloss = 'gains';
%             block = mod(run, 4); % relative block number for each domain
%         else
%             gainloss = 'loss';
%             block = run - 2;
%         end
%         
%         sdm_name = ['Prt files' num2str(subject) '_S' num2str(session) '_block' num2str(run) '_' gainloss num2str(block) '_type_AmbiguityLevel.sdm']; % change for RiskLevel
        
        sdm_name = files2add(s).name
        sdm = xff([path sdm_name]);
        sdm.NrOfPredictors = 9;
        sdm.FirstConfoundPredictor = 9;
        PredictorNames8 = sdm.PredictorNames;
        PredictorNames9 = {'Amb_gains', 'Amb_gains x p1', 'Risk_gains', 'Risk_gains x p1', 'Amb_loss', 'Amb_loss x p1', 'Risk_loss', 'Risk_loss x p1', 'Constant'};
        sdm.PredictorNames = PredictorNames9;
        
        % find the missing column
        for mismatch = 1:length(PredictorNames9)
            if strcmp(PredictorNames8(mismatch), PredictorNames9(mismatch))
                mismatch=mismatch+1;
            else
                break
            end
        end
        
        % insert the missing column and fill it with zeros
        a = zeros(490,9); % volume number x condition numbers
        for i=1:mismatch-1
            a(:,i) = sdm.SDMMatrix(:,i);
        end
        for i= mismatch+1:length(PredictorNames9)
            a(:,i) = sdm.SDMMatrix(:,i-1);
        end
        sdm.SDMMatrix = a;
       
        % save it in a new file name
        sdm.SaveAs([pathout sdm_name(1:length(sdm_name)-4) '_9.sdm']);
    end
   
  
        
        
       