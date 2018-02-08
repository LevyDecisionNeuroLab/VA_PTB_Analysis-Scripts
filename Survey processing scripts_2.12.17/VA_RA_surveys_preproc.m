clear all
close all

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Survey';
filename = 'VA_RA_BISBAS_BIS11_DOSPERT_170227.xlsx';

% read data, num is the score matrix with the first row as question ID, and
% txt is the header text. Raw is a cell array combining num and txt.
[num,txt,raw] = xlsread(fullfile(root, filename));

%% BISBAS
% read BISBAS questions: match the column with header "BISBAS"
bisbas = num(:,[1;strmatch('BISBAS', txt(1,:))]);
% turn score 5 into NaN
bisbas([logical(zeros(1,size(bisbas,2))); bisbas(2:size(bisbas,1),:) == 5]) = NaN;

% Reverse score for some questions
bisbasRevId = [1,3:21,23:24]; % Qids that are reverse coded
for i = 2:size(bisbas,1)
    bisbas(i,ismember(bisbas(1,:),bisbasRevId))=5-bisbas(i,ismember(bisbas(1,:),bisbasRevId));
end    

% sub-groups id
basDrvId = [3,9,12,21]; % BAS Driving
basFnSkId = [5,10,15,20]; % BAS Fun Seeking
basRwdRspId = [4,7,14,18,23]; % Bas reward Responsiveness
bisId = [2,8,13,16,19,22,24]; % Bis

% calculate sub-score (sum)
basDrv = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basDrvId)),2);
basFnSk = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basFnSkId)),2);
basRwdRsp = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basRwdRspId)),2);
bis = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),bisId)),2);

% calculate sub-score (mean)
basDrvAv = nanmean(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basDrvId)),2);
basFnSkAv = nanmean(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basFnSkId)),2);
basRwdRspAv = nanmean(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basRwdRspId)),2);
bisAv = nanmean(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),bisId)),2);

%% BIS-11
% read BIS11 questions: match the column with header "BIS11"
bis11 = num(:,[1;strmatch('BIS11', txt(1,:))]);
% turn score 5 into NaN
bis11([logical(zeros(1,size(bis11,2))); bis11(2:size(bis11,1),:) == 5]) = NaN;

% Reverse score for some questions
bis11RevId = [9,20,30,1,7,8,12,13,10,15,29]; % Qids that are reverse coded
for i = 2:size(bis11,1)
    bis11(i,ismember(bis11(1,:),bis11RevId))=5-bis11(i,ismember(bis11(1,:),bis11RevId));
end

% sub-groups id
bis11AttId = [5,9,11,20,28]; % Attention
bis11CgnIstId = [6,24,26]; % Cognitive Instability
bis11MtrId = [2,3,4,17,19,22,25]; % Motor
bis11PrsvId = [16,21,23,30]; % Perseverance
bis11SlfCtrId = [1,7,8,12,13,14]; % Self-Control
bis11CgnCplxId = [10,15,18,27,29]; % Cognitive Complexity

% calculate sub-score (sum)
bis11Att = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11AttId)),2);
bis11CgnIst = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11CgnIstId)),2);
bis11Mtr = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11MtrId)),2);
bis11Prsv = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11PrsvId)),2);
bis11SlfCtr = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11SlfCtrId)),2);
bis11CgnCplx = nansum(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11CgnCplxId)),2);

% calculate sub-score (mean)
bis11AttAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11AttId)),2);
bis11CgnIstAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11CgnIstId)),2);
bis11MtrAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11MtrId)),2);
bis11PrsvAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11PrsvId)),2);
bis11SlfCtrAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11SlfCtrId)),2);
bis11CgnCplxAv = nanmean(bis11(2:size(bis11,1), ismember(bis11(1,:),bis11CgnCplxId)),2);

%% DOSPERT
% read DOSPERT questions: match the column with header "DOSPERT**"
dospertRt = num(:,[1;strmatch('DOSPERTRT', txt(1,:))]);
% turn score 8 into NaN
dospertRt([logical(zeros(1,size(dospertRt,2))); dospertRt(2:size(dospertRt,1),:) == 8]) = NaN;

dospertRp = num(:,[1;strmatch('DOSPERTRP', txt(1,:))]);
% turn score 8 into NaN
dospertRp([logical(zeros(1,size(dospertRp,2))); dospertRp(2:size(dospertRp,1),:) == 8]) = NaN;

% this survey does not have EB (expected benefit) section
% dospertEb = num(:,[1;strmatch('DOSPERTEB', txt(1,:))]);
% % turn score 8 into NaN
% dospertEb([logical(zeros(1,size(dospertEb,2))); dospertEb(2:size(dospertEb,1),:) == 8]) = NaN;


% sub-group Id
dospertEId = [6 9 10 16 29 30]; % ethical 
dospertFiId = [12 4 18]; % financial investment
dospertFgId = [3 14 8]; % financial gambling
dospertHsId = [5 15 17 20 23 26]; % health/safety
dospertRId = [2 11 13 19 24 25]; % recreational
dospertSId = [1 7 21 22 27 28]; % social


% calculate sub-score (mean)
dospertRtEAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertEId)),2);
dospertRtFiAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertFiId)),2);
dospertRtFgAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertFgId)),2);
dospertRtHsAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertHsId)),2);
dospertRtRAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertRId)),2);
dospertRtSAv = nanmean(dospertRt(2:size(dospertRt,1), ismember(dospertRt(1,:),dospertSId)),2);

dospertRpEAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertEId)),2);
dospertRpFiAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertFiId)),2);
dospertRpFgAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertFgId)),2);
dospertRpHsAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertHsId)),2);
dospertRpRAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertRId)),2);
dospertRpSAv = nanmean(dospertRp(2:size(dospertRp,1), ismember(dospertRp(1,:),dospertSId)),2);

% dospertEbEAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertEId)),2);
% dospertEbFiAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertFiId)),2);
% dospertEbFgAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertFgId)),2);
% dospertEbHsAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertHsId)),2);
% dospertEbRAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertRId)),2);
% dospertEbSAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertSId)),2);


%% Print to .xlsx
outputname = 'VA_RA_BISBAS_BIS11_DOSPERT_factor.xlsx';
output = fullfile(root, outputname);
subjId = num(2:size(num,1),1);
% time = txt(4:size(txt,1),116); % when the survey response was collected

t = table(subjId,...
    basDrvAv, basFnSkAv, basRwdRspAv, bisAv,...
    bis11AttAv, bis11CgnIstAv, bis11MtrAv, bis11PrsvAv, bis11SlfCtrAv, bis11CgnCplxAv,...
    dospertRtEAv, dospertRtFiAv, dospertRtFgAv, dospertRtHsAv, dospertRtRAv, dospertRtSAv,...
    dospertRpEAv, dospertRpFiAv, dospertRpFgAv, dospertRpHsAv, dospertRpRAv, dospertRpSAv);

writetable(t,output, 'FileType', 'spreadsheet')
