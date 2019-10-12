clear all
close all

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral\Surveys';
filename = 'VA survey_imaging_final.xlsx';

% read data, num is the score matrix with the first row as question ID, and
% txt is the header text. Raw is a cell array combining num and txt.
[num,txt,raw] = xlsread(fullfile(root, filename));

%% BISBAS
% read BISBAS questions: match the column with header "BISBAS"
% bisbas = num(:,[1;strmatch('BISBAS', txt(1,:))]);
bisbas = num(:, [2:25]);
% turn score 5 into NaN
% bisbas([logical(zeros(1,size(bisbas,2))); bisbas(2:size(bisbas,1),:) == 5]) = NaN;

% Reverse score for some questions
bisbasRevId = [1,3:21,23:24]; % Qids that are reverse coded
for i = 1:size(bisbas,1)
%     bisbas(i,ismember(bisbas(1,:),bisbasRevId))=5-bisbas(i,ismember(bisbas(1,:),bisbasRevId));
    bisbas(i,bisbasRevId)=5-bisbas(i,bisbasRevId);
end    

% sub-groups id
basDrvId = [3,9,12,21]; % BAS Driving
basFnSkId = [5,10,15,20]; % BAS Fun Seeking
basRwdRspId = [4,7,14,18,23]; % Bas reward Responsiveness
bisId = [2,8,13,16,19,22,24]; % Bis

% calculate sub-score (sum)
% basDrv = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basDrvId)),2);
% basFnSk = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basFnSkId)),2);
% basRwdRsp = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),basRwdRspId)),2);
% bis = nansum(bisbas(2:size(bisbas,1),ismember(bisbas(1,:),bisId)),2);

basDrv = nansum(bisbas(1:size(bisbas,1),basDrvId),2);
basFnSk = nansum(bisbas(1:size(bisbas,1),basFnSkId),2);
basRwdRsp = nansum(bisbas(1:size(bisbas,1),basRwdRspId),2);
bas_total = nansum([basDrv, basFnSk, basRwdRsp],2);
bis_total = nansum(bisbas(1:size(bisbas,1),bisId),2);

% calculate sub-score (mean)
basDrvAv = nanmean(bisbas(1:size(bisbas,1),basDrvId),2);
basFnSkAv = nanmean(bisbas(1:size(bisbas,1),basFnSkId),2);
basRwdRspAv = nanmean(bisbas(1:size(bisbas,1),basRwdRspId),2);
bisAv = nanmean(bisbas(1:size(bisbas,1),bisId),2);

%% BIS-11
% read BIS11 questions: match the column with header "BIS11"
% bis11 = num(:,[1;strmatch('BIS11', txt(1,:))]);
bis11 = num(:,[26:55]);
% turn score 5 into NaN
% bis11([logical(zeros(1,size(bis11,2))); bis11(2:size(bis11,1),:) == 5]) = NaN;

% Reverse score for some questions
bis11RevId = [9,20,30,1,7,8,12,13,10,15,29]; % Qids that are reverse coded
for i = 1:size(bis11,1)
%     bis11(i,ismember(bis11(1,:),bis11RevId))=5-bis11(i,ismember(bis11(1,:),bis11RevId));
    bis11(i,bis11RevId)=5-bis11(i,bis11RevId);

end

% sub-groups id
bis11AttId = [5,9,11,20,28]; % Attention
bis11CgnIstId = [6,24,26]; % Cognitive Instability
bis11MtrId = [2,3,4,17,19,22,25]; % Motor
bis11PrsvId = [16,21,23,30]; % Perseverance
bis11SlfCtrId = [1,7,8,12,13,14]; % Self-Control
bis11CgnCplxId = [10,15,18,27,29]; % Cognitive Complexity

% calculate sub-score (sum)
bis11Att = nansum(bis11(1:size(bis11,1), bis11AttId),2);
bis11CgnIst = nansum(bis11(1:size(bis11,1), bis11CgnIstId),2);
bis11Mtr = nansum(bis11(1:size(bis11,1), bis11MtrId),2);
bis11Prsv = nansum(bis11(1:size(bis11,1), bis11PrsvId),2);
bis11SlfCtr = nansum(bis11(1:size(bis11,1), bis11SlfCtrId),2);
bis11CgnCplx = nansum(bis11(1:size(bis11,1), bis11CgnCplxId),2);
bis11_total = nansum([bis11Att, bis11CgnIst,bis11Mtr,bis11Prsv,bis11SlfCtr,bis11CgnCplx], 2);

% calculate sub-score (mean)
bis11AttAv = nanmean(bis11(1:size(bis11,1), bis11AttId),2);
bis11CgnIstAv = nanmean(bis11(1:size(bis11,1), bis11CgnIstId),2);
bis11MtrAv = nanmean(bis11(1:size(bis11,1), bis11MtrId),2);
bis11PrsvAv = nanmean(bis11(1:size(bis11,1), bis11PrsvId),2);
bis11SlfCtrAv = nanmean(bis11(1:size(bis11,1), bis11SlfCtrId),2);
bis11CgnCplxAv = nanmean(bis11(1:size(bis11,1), bis11CgnCplxId),2);


%% DOSPERT
% read DOSPERT questions: match the column with header "DOSPERT**"
% dospertRt = num(:,[1;strmatch('DOSPERTRT', txt(1,:))]);
dospertRt = num(:,[56:85]);
% turn score 8 into NaN
% dospertRt([logical(zeros(1,size(dospertRt,2))); dospertRt(2:size(dospertRt,1),:) == 8]) = NaN;

% dospertRp = num(:,[1;strmatch('DOSPERTRP', txt(1,:))]);
dospertRp = num(:,[86:115]);
% turn score 8 into NaN
% dospertRp([logical(zeros(1,size(dospertRp,2))); dospertRp(2:size(dospertRp,1),:) == 8]) = NaN;

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
dospertRtEAv = nanmean(dospertRt(1:size(dospertRt,1), dospertEId),2);
dospertRtFiAv = nanmean(dospertRt(1:size(dospertRt,1), dospertFiId),2);
dospertRtFgAv = nanmean(dospertRt(1:size(dospertRt,1), dospertFgId),2);
dospertRtHsAv = nanmean(dospertRt(1:size(dospertRt,1), dospertHsId),2);
dospertRtRAv = nanmean(dospertRt(1:size(dospertRt,1), dospertRId),2);
dospertRtSAv = nanmean(dospertRt(1:size(dospertRt,1), dospertSId),2);

dospertRpEAv = nanmean(dospertRp(1:size(dospertRp,1), dospertEId),2);
dospertRpFiAv = nanmean(dospertRp(1:size(dospertRp,1), dospertFiId),2);
dospertRpFgAv = nanmean(dospertRp(1:size(dospertRp,1), dospertFgId),2);
dospertRpHsAv = nanmean(dospertRp(1:size(dospertRp,1), dospertHsId),2);
dospertRpRAv = nanmean(dospertRp(1:size(dospertRp,1), dospertRId),2);
dospertRpSAv = nanmean(dospertRp(1:size(dospertRp,1), dospertSId),2);

dospertRtE = nansum(dospertRt(1:size(dospertRt,1), dospertEId),2);
dospertRtFi = nansum(dospertRt(1:size(dospertRt,1), dospertFiId),2);
dospertRtFg = nansum(dospertRt(1:size(dospertRt,1), dospertFgId),2);
dospertRtHs = nansum(dospertRt(1:size(dospertRt,1), dospertHsId),2);
dospertRtR = nansum(dospertRt(1:size(dospertRt,1), dospertRId),2);
dospertRtS = nansum(dospertRt(1:size(dospertRt,1), dospertSId),2);
dospertRt_total = nansum([dospertRtE, dospertRtFi, dospertRtFg, dospertRtHs, dospertRtR, dospertRtS], 2);

dospertRpE = nansum(dospertRp(1:size(dospertRp,1), dospertEId),2);
dospertRpFi = nansum(dospertRp(1:size(dospertRp,1), dospertFiId),2);
dospertRpFg = nansum(dospertRp(1:size(dospertRp,1), dospertFgId),2);
dospertRpHs = nansum(dospertRp(1:size(dospertRp,1), dospertHsId),2);
dospertRpR = nansum(dospertRp(1:size(dospertRp,1), dospertRId),2);
dospertRpS = nansum(dospertRp(1:size(dospertRp,1), dospertSId),2);
dospertRp_total = nansum([dospertRpE, dospertRpFi, dospertRpFg, dospertRpHs, dospertRpR, dospertRpS], 2);

% dospertEbEAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertEId)),2);
% dospertEbFiAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertFiId)),2);
% dospertEbFgAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertFgId)),2);
% dospertEbHsAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertHsId)),2);
% dospertEbRAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertRId)),2);
% dospertEbSAv = nanmean(dospertEb(2:size(dospertEb,1), ismember(dospertEb(1,:),dospertSId)),2);


%% Print to .xlsx
outputname = 'VA_RA_BISBAS_BIS11_DOSPERT_factor_final.xlsx';
output = fullfile(root, outputname);
id = num(:,1);
% time = txt(4:size(txt,1),116); % when the survey response was collected

% t = table(id,...
%     basDrvAv, basFnSkAv, basRwdRspAv, bisAv,...
%     bis11AttAv, bis11CgnIstAv, bis11MtrAv, bis11PrsvAv, bis11SlfCtrAv, bis11CgnCplxAv,...
%     dospertRtEAv, dospertRtFiAv, dospertRtFgAv, dospertRtHsAv, dospertRtRAv, dospertRtSAv,...
%     dospertRpEAv, dospertRpFiAv, dospertRpFgAv, dospertRpHsAv, dospertRpRAv, dospertRpSAv);

t = table(id,...
    basDrv, basFnSk, basRwdRsp, bas_total, bis_total,...
    bis11Att, bis11CgnIst, bis11Mtr, bis11Prsv, bis11SlfCtr, bis11CgnCplx, bis11_total,...
    dospertRtE, dospertRtFi, dospertRtFg, dospertRtHs, dospertRtR, dospertRtS, dospertRt_total,...
    dospertRpE, dospertRpFi, dospertRpFg, dospertRpHs, dospertRpR, dospertRpS, dospertRp_total);

writetable(t,output, 'FileType', 'spreadsheet')
