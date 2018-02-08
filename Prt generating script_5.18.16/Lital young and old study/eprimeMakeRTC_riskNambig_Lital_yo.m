% use eprime data file to create rtc files
subjects = {'s1000','s1001'} % insert subjects ids if different predictors for different subjects
%indiff

subMean = 0; %subtract mean before hrf
normTo1 = 1;
hrf = 1;
z = 1; % 0 - no normalization, 1 - z normalization, 2 - subtract mean

% ------- FIXED INFORMATION -----------------------------------------------
imageLength = 1;
delayLength = 3;
responseLength = 1;
ITI = 5;
trialLength = imageLength+delayLength+responseLength;

trials2Use = 1:186;


fixed_value = 50;
fixed_prob = 0.5;

value = [50 95 180 340 650];
ambig = [.25 .50 .75];
prob = [.38 .25 .13];
jitter = 1;

scanNum = 6;
trialsPerScan = 30; % excluding first trial
offset = 2; % length of first blank in TR's after discarding 3 volumes

% -------------------------------------------------------------------------

for subject = 1: length(subjects)
    path = ['D:\Data_Analysis\riskNambiguity\scan\behavior\' subjects{subject} '\'] %pc

    path_out = ['D:\Data_Analysis\riskNambiguity\scan\multi\finalAnalysis\'] %pc


   % these are all for multiple sessions, when there are differences between subjects, so you can get rid of them and just modify it for your needs 
    for sessionNum = firstSessionScan(subject):firstSessionScan(subject)+sessionsPerSubjScan(subject)-1;

        filename = [path subjects{subject} '_' num2str(sessionNum) '.txt']

        [vA_orig1,pA1,AL1,choice_lottery1] = getChoicesEprimeLogScan(filename,trials2Use);

        % throw out first trial of each scan
        noFirstTrials = [];
        for i = 1:scanNum
            noFirstTrials = [noFirstTrials (i-1)*(trialsPerScan+1)+2 : i*(trialsPerScan+1)];
        end
        
        vA_orig = vA_orig1(noFirstTrials);
        pA = pA1(noFirstTrials);
        AL = AL1(noFirstTrials);
        choice_lottery = choice_lottery1(noFirstTrials);
        
        %group all jittered values together
        vA = zeros(size(vA_orig));
        for i = 1:length(vA)
            for j = 1:length(value)
                if vA_orig(i) >= value(j)-jitter && vA_orig(i) <= value(j)+jitter
                    vA(i) = value(j);
                end
            end
        end
        
            
        % ---PRECISE VALUE USED---
        %vA = double(vA_orig);
        
        for i = 1:scanNum            

                        %------------------------------  risk ambig binary --------------------------------------

            predNames = {'"first"','"risk_mean"','"ambig_mean"'};
            predNum = length(predNames);
            designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
            
            %             
            % first trial
            designMat(offset+1:offset+trialLength,1) = 1;

            for j = 1:trialsPerScan
                if AL((i-1)*trialsPerScan+j) == 0
                    % risk mean
                    designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,2) = 1;
                    
                else

                    % ambig mean
                    designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,3) = 1;

                end

            end

            % subtract Mean
            HRFdesignMat = designMat;
            if subMean
                for j = 1:predNum
                    HRFdesignMat = subtractMean(HRFdesignMat);
                end
                subMeanFlag = 'subMean';
            else
                subMeanFlag = '';
            end

            

            % hrf convolution
            HRFdesignMat = designMat;
            if hrf
                for j = 1:predNum
                    HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
                end
                hrfFlag = 'HRF';
            else
                hrfFlag = 'noHRF';
            end


            % zscore
            zHRFdesignMat = HRFdesignMat;
            if z == 1
                zHRFdesignMat = zscore(HRFdesignMat);
                zFlag = 'zscore';
            elseif z == 2
                zHRFdesignMat = subtractMean(HRFdesignMat);
                zFlag = 'subMean';
                    
            else
                zFlag = 'noZscore';
            end

            rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-binary_' ...
                hrfFlag '_' zFlag '.rtc'];
            writeRTC(rtcfile,predNames,zHRFdesignMat)
 
     %------------------------------ uncertainty levels--------------------------------------

            predNames = {'"first"','"risk-38"','"risk-25"','"risk-13"',...
                '"ambig-25"','"ambig-50"','"ambig-75"'};
            
            predNum = length(predNames);
            designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
            % first trial
            designMat(offset+1:offset+trialLength,1) = 1;
            

            for j = 1:trialsPerScan
                if AL((i-1)*trialsPerScan+j)==0
                    % risk
                    designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,...
                        find(prob==pA((i-1)*trialsPerScan+j))+1) = pA((i-1)*trialsPerScan+j);
                    
                else
                    % ambig
                    designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,...
                        find(ambig==AL((i-1)*trialsPerScan+j))+4) = AL((i-1)*trialsPerScan+j);
                end
            end

            % hrf convolution
            HRFdesignMat = designMat;
            if hrf
                for j = 1:predNum
                    HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
                end
                hrfFlag = 'HRF';
            else
                hrfFlag = 'noHRF';
            end

            % zscore
            zHRFdesignMat = HRFdesignMat;
            if z
                zHRFdesignMat = zscore(HRFdesignMat);
                zFlag = 'zscore';
            else
                zFlag = 'noZscore';
            end


            rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-uncertain-level_' hrfFlag '_' zFlag '.rtc'];
            writeRTC(rtcfile,predNames,zHRFdesignMat)


%             %------------------------------  risk ambig utility --------------------------------------
% 
%             predNames = {'"first"','"risk_mean"','"ambig_mean"', '"risk_utility"','"ambig_utility"'};
%             predNum = length(predNames);
%             designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
%             
%             minVal = min(min(prob)*min(value)^alpha(subject,sessionNum),...
%                 (0.5-beta(subject,sessionNum)*max(ambig)/2)*min(value)^alpha(subject,sessionNum));
% 
%             maxVal = max(max(prob)*max(value)^alpha(subject,sessionNum),...
%                 (0.5-beta(subject,sessionNum)*min(ambig)/2)*max(value)^alpha(subject,sessionNum));
%             
%             % first trial
%             designMat(offset+1:offset+trialLength,1) = 1;
% 
%             for j = 1:trialsPerScan
%                 if AL((i-1)*trialsPerScan+j) == 0
%                     % risk mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,2) = 1;
%                     
%                     % risk utility
%                     currVal = ((pA((i-1)*trialsPerScan+j)-beta(subject,sessionNum)*AL((i-1)*trialsPerScan+j)/2)...
%                         *vA((i-1)*trialsPerScan+j)^alpha(subject,sessionNum));
%                     if normTo1
%                         % normalize to 0-1 range
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = ...
%                             (currVal-minVal)/(maxVal-minVal);
%                         normFlag = 'norm';
%                     else
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = currVal;
%                         normFlag = '';
%                     end
%                 else
% 
%                     % ambig mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,3) = 1;
% 
%                     % ambig utility
%                     currVal = ((pA((i-1)*trialsPerScan+j)-beta(subject,sessionNum)*AL((i-1)*trialsPerScan+j)/2)...
%                         *vA((i-1)*trialsPerScan+j)^alpha(subject,sessionNum));
% 
%                     if normTo1
%                         % normalize to 0-1 range
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = ...
%                             (currVal-minVal)/(maxVal-minVal);
%                         normFlag = 'norm'
%                     else
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = currVal;
%                        normFlag = '';
%                     end
%                 end
% 
%             end
% 
%             % subtract Mean
%             HRFdesignMat = designMat;
%             if subMean
%                 for j = 1:predNum
%                     HRFdesignMat = subtractMean(HRFdesignMat);
%                 end
%                 subMeanFlag = 'subMean';
%             else
%                 subMeanFlag = '';
%             end
% 
%             
% 
%             % hrf convolution
%             HRFdesignMat = designMat;
%             if hrf
%                 for j = 1:predNum
%                     HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
%                 end
%                 hrfFlag = 'HRF';
%             else
%                 hrfFlag = 'noHRF';
%             end
% 
% 
%             % zscore
%             zHRFdesignMat = HRFdesignMat;
%             if z == 1
%                 zHRFdesignMat = zscore(HRFdesignMat);
%                 zFlag = 'zscore';
%             elseif z == 2
%                 zHRFdesignMat = subtractMean(HRFdesignMat);
%                 zFlag = 'subMean';
%                     
%             else
%                 zFlag = 'noZscore';
%             end
% 
%             rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-utility_' ...
%                 normFlag subMeanFlag hrfFlag '_' zFlag '.rtc'];
%             writeRTC(rtcfile,predNames,zHRFdesignMat)
% 

%             %------------------------------  risk ambig EV --------------------------------------
% 
%             predNames = {'"first"','"risk_mean"','"ambig_mean"', '"risk_EV"','"ambig_EV"'};
%             predNum = length(predNames);
%             designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
% 
%             % first trial
%             designMat(offset+1:offset+trialLength,1) = 1;
% 
%             for j = 1:trialsPerScan
%                 if AL((i-1)*trialsPerScan+j) == 0
%                     % risk mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,2) = 1;
%                     
%                     % risk EV
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = ...
%                         pA((i-1)*trialsPerScan+j)*vA((i-1)*trialsPerScan+j);
%                 else
%                     % ambig mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,3) = 1;
% 
%                     % ambig EV
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = ...
%                         pA((i-1)*trialsPerScan+j)*vA((i-1)*trialsPerScan+j);
%                 end
% 
%             end
% 
%             % subtract Mean
%             HRFdesignMat = designMat;
%             if subMean
%                 for j = 1:predNum
%                     HRFdesignMat = subtractMean(HRFdesignMat);
%                 end
%                 subMeanFlag = 'subMean';
%             else
%                 subMeanFlag = '';
%             end
% 
%             
% 
%             % hrf convolution
%             HRFdesignMat = designMat;
%             if hrf
%                 for j = 1:predNum
%                     HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
%                 end
%                 hrfFlag = 'HRF';
%             else
%                 hrfFlag = 'noHRF';
%             end
% 
% 
%             % zscore
%             zHRFdesignMat = HRFdesignMat;
%             if z == 1
%                 zHRFdesignMat = zscore(HRFdesignMat);
%                 zFlag = 'zscore';
%             elseif z == 2
%                 zHRFdesignMat = subtractMean(HRFdesignMat);
%                 zFlag = 'subMean';
%                     
%             else
%                 zFlag = 'noZscore';
%             end
% 
%             rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-EV_' subMeanFlag hrfFlag '_' zFlag '.rtc'];
%             writeRTC(rtcfile,predNames,zHRFdesignMat)
% 
%           %------------------------------  risk ambig amount --------------------------------------
% 
%             predNames = {'"first"','"risk_mean"','"ambig_mean"', '"risk_amount"','"ambig_amount"'};
%             predNum = length(predNames);
%             designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
% 
%             % first trial
%             designMat(offset+1:offset+trialLength,1) = 1;
% 
%             for j = 1:trialsPerScan
%                 if AL((i-1)*trialsPerScan+j) == 0
%                     % risk mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,2) = 1;
%                     
%                     % risk amount
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = vA((i-1)*trialsPerScan+j);
%                 else
%                     % ambig mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,3) = 1;
% 
%                     % ambig amount
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = vA((i-1)*trialsPerScan+j);
%                 end
% 
%             end
% 
%             % subtract Mean
%             HRFdesignMat = designMat;
%             if subMean
%                 for j = 1:predNum
%                     HRFdesignMat = subtractMean(HRFdesignMat);
%                 end
%                 subMeanFlag = 'subMean';
%             else
%                 subMeanFlag = '';
%             end
% 
%             
% 
%             % hrf convolution
%             HRFdesignMat = designMat;
%             if hrf
%                 for j = 1:predNum
%                     HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
%                 end
%                 hrfFlag = 'HRF';
%             else
%                 hrfFlag = 'noHRF';
%             end
% 
% 
%             % zscore
%             zHRFdesignMat = HRFdesignMat;
%             if z == 1
%                 zHRFdesignMat = zscore(HRFdesignMat);
%                 zFlag = 'zscore';
%             elseif z == 2
%                 zHRFdesignMat = subtractMean(HRFdesignMat);
%                 zFlag = 'subMean';
%                     
%             else
%                 zFlag = 'noZscore';
%             end
% 
%             rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-amount_' subMeanFlag hrfFlag '_' zFlag '.rtc'];
%             writeRTC(rtcfile,predNames,zHRFdesignMat)

 
%             %------------------------------  risk ambig utility + choice --------------------------------------
% 
%             predNames = {'"first"','"risk_mean"','"ambig_mean"', '"risk_utility"','"ambig_utility"','"risk_choice"','"ambig_choice"'};
%             predNum = length(predNames);
%             designMat = zeros(offset + (trialsPerScan+1)*(trialLength+ITI),predNum);
%             
%             minVal = min(min(prob)*min(value)^alpha(subject,sessionNum),...
%                 (0.5-beta(subject,sessionNum)*max(ambig)/2)*min(value)^alpha(subject,sessionNum));
% 
%             maxVal = max(max(prob)*max(value)^alpha(subject,sessionNum),...
%                 (0.5-beta(subject,sessionNum)*min(ambig)/2)*max(value)^alpha(subject,sessionNum));
%             
%             % first trial
%             designMat(offset+1:offset+trialLength,1) = 1;
% 
%             for j = 1:trialsPerScan
%                 if AL((i-1)*trialsPerScan+j) == 0
%                     % risk mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,2) = 1;
%                     
%                     % risk utility
%                     currVal = ((pA((i-1)*trialsPerScan+j)-beta(subject,sessionNum)*AL((i-1)*trialsPerScan+j)/2)...
%                         *vA((i-1)*trialsPerScan+j)^alpha(subject,sessionNum));
%                     if normTo1
%                         % normalize to 0-1 range
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = ...
%                             (currVal-minVal)/(maxVal-minVal);
%                         normFlag = 'norm';
%                     else
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,4) = currVal;
%                         normFlag = '';
%                     end
%                     % risk choice
%                     if choice_lottery((i-1)*trialsPerScan+j) == otherButton(subject)
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,6) = 1;
%                     end
%                 else
% 
%                     % ambig mean
%                     designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,3) = 1;
% 
%                     % ambig utility
%                     currVal = ((pA((i-1)*trialsPerScan+j)-beta(subject,sessionNum)*AL((i-1)*trialsPerScan+j)/2)...
%                         *vA((i-1)*trialsPerScan+j)^alpha(subject,sessionNum));
% 
%                     if normTo1
%                         % normalize to 0-1 range
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = ...
%                             (currVal-minVal)/(maxVal-minVal);
%                         normFlag = 'norm'
%                     else
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,5) = currVal;
%                        normFlag = '';
%                     end
%                     
%                     % ambig choice
%                     if choice_lottery((i-1)*trialsPerScan+j) == otherButton(subject)
%                         designMat(offset+ j * (trialLength+ITI) + 1 : offset+ j * (trialLength+ITI) + 5,7) = 1;
%                     end
%                 end
% 
%             end
% 
%             % subtract Mean
%             HRFdesignMat = designMat;
%             if subMean
%                 for j = 1:predNum
%                     HRFdesignMat = subtractMean(HRFdesignMat);
%                 end
%                 subMeanFlag = 'subMean';
%             else
%                 subMeanFlag = '';
%             end
% 
%             
% 
%             % hrf convolution
%             HRFdesignMat = designMat;
%             if hrf
%                 for j = 1:predNum
%                     HRFdesignMat(:,j) = convolveHRF(designMat(:,j));
%                 end
%                 hrfFlag = 'HRF';
%             else
%                 hrfFlag = 'noHRF';
%             end
% 
% 
%             % zscore
%             zHRFdesignMat = HRFdesignMat;
%             if z == 1
%                 zHRFdesignMat = zscore(HRFdesignMat);
%                 zFlag = 'zscore';
%             elseif z == 2
%                 zHRFdesignMat = subtractMean(HRFdesignMat);
%                 zFlag = 'subMean';
%                     
%             else
%                 zFlag = 'noZscore';
%             end
% 
%             rtcfile = [path_out subjects{subject} '_riskNambig_session' num2str(sessionNum) '_scan' num2str(i) '_risk-ambig-utility-choice_' ...
%                 normFlag subMeanFlag hrfFlag '_' zFlag '.rtc'];
%             writeRTC(rtcfile,predNames,zHRFdesignMat)

        end
    end
end

        
        



