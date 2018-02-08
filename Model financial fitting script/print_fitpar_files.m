%% This script is meant to take both constrained/unconstrained fitpar files and print paramatric fit and non-paramatric summary to Excel

clear all
close all
%cd 'C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\';
%addpath(genpath('C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\'));

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function
 exclude = [76 77 78 79 80 81 95 1218]; % TEMPORARY: subjects incomplete data (that the script is not ready for)
subjects = subjects(~ismember(subjects, exclude));


cd 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Behavior data financial fitpar_011717\';
path = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Behavior data financial fitpar_011717\';

% defining monetary values
valueP = [4 5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
valueN = [-4 -5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120]; 

output_file1 = 'param_nonparam.txt';
% might not need
% output_file2 = 'choice_data.txt'

% results file
fid = fopen([path output_file1],'w')
fprintf(fid,'\tPar_unconstrained\n')
% fprintf(fid,'subject\tgains\t\tlosses\t\tgains\t\tlosses\t\tgains\t\t\t\t\t\tlosses\n')
% fprintf(fid,'\talpha\tbeta\talpha\tbeta\talpha\tbeta\talpha\tbeta\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

% Fill in subject numbers separated by commas
% subjects = {'87','88'};
for s = 1:length(subjects)
    
    subject = subjects(s); 
    % load gains file for subject and extract params & choice data
    load(['RA_GAINS_' num2str(subject) '_financial_fitpar_unconstrained.mat']);
    k1P = Data.k1;
    k1Pse = Data.MLE.se(3);
    k2P = Data.k2;
    k2Pse = Data.MLE.se(2);
    slopeP = Data.gamma;
    slopePse = Data.MLE.se(1);
    
    riskyChoices_byLevelP = Data.riskyChoices_byLevel;
    ambigChoices_byLevelP = Data.ambigChoices_byLevel;
    riskyChoicesP = Data.riskyChoices;
    ambigChoicesP = Data.ambigChoices;
    choices4P = [NaN Data.choiceProb4 NaN NaN NaN NaN]';
    
 

    
    % load gains file for subject and extract params & choice data
    load(['RA_LOSS_' num2str(subject) '_financial_fitpar_unconstrained.mat']);
    k1N = Data.k1;
    k1Nse = Data.MLE.se(3);
    k2N = Data.k2;
    k2Nse = Data.MLE.se(2);
    slopeN = Data.gamma;
    slopeNse = Data.MLE.se(1);

    riskyChoices_byLevelN = Data.riskyChoices_byLevel;
    ambigChoices_byLevelN = Data.ambigChoices_byLevel;
    riskyChoicesN = Data.riskyChoices;
    ambigChoicesN = Data.ambigChoices;
    choices4N = [NaN Data.choiceProb4 NaN NaN NaN NaN]';
    

    %write into param text file
    fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',num2str(subject),k1P,k1Pse,k2P,k2Pse,slopeP,slopePse,k1N,k1Nse,k2N,k2Nse,slopeN,slopeNse)
    
    % for Excel file - choice data
    
    % Firt, combine choice data with and without $4
    choices_rnaP = [riskyChoicesP; ambigChoicesP];
    choices_allP = [choices4P,choices_rnaP];
    choices_rnaN = [riskyChoicesN; ambigChoicesN];
    choices_allN = [choices4N,choices_rnaN];
    
    all_data_subject = [valueP; choices_allP ;valueN; choices_allN];
    
    xlFile = [path 'choice_data.xls'];
    dlmwrite(xlFile, subject , '-append', 'roffset', 1, 'delimiter', ' ');  
    dlmwrite(xlFile, all_data_subject, 'coffset', 1, '-append', 'delimiter', '\t');
    
end

fclose(fid);
