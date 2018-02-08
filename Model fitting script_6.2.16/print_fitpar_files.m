%% This script is meant to take both constrained/unconstrained fitpar files and print paramatric fit and non-paramatric summary to Excel
% it also create choice matrix for every subject
clearvars
close all
%cd 'C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\';
%addpath(genpath('C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\'));

%Input
fitparwave = 'Behavior data fitpar_091017';
outputwave = '_091017';
% exclude should match those in the fit_parameters.m script
exclude = [77 1218]; 
% TEMPORARY: subjects incomplete data (that the script is not ready for)

%% folder and subjects
root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function
subjects = subjects(~ismember(subjects, exclude));

path = fullfile(root, fitparwave, filesep);
cd(path)
% cd 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Behavior data fitpar_091017';

% defining monetary values
valueP = [4 5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
valueN = [-4 -5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120]; 

summary_file1 = ['param_nonparam' outputwave '.txt']; % parametric and nonparametric risk and ambig attitudes
choiceData_file = [path 'choice_data' outputwave '.xls']; % choice matrix

% might not need
% output_file2 = 'choice_data.txt'

% results file
fid = fopen([path summary_file1],'w')
fprintf(fid,'\tPar_unconstrained\t\t\t\t\t\t\t\tPar_constrained\t\t\t\t\t\t\t\tNonPar\n')
fprintf(fid,'subject\tgains\t\t\t\tlosses\t\t\t\tgains\t\t\t\tlosses\t\t\t\tgains\t\t\t\t\t\tlosses\n')
fprintf(fid,'\talpha\tbeta\tgamma\tr2\talpha\tbeta\tgamma\tr2\talpha\tbeta\tgamma\tr2\talpha\tbeta\tgamma\tr2\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

% Fill in subject numbers separated by commas
% subjects = {'87','88'};
for s = 1:length(subjects)
    
    subject = subjects(s); 
    % load gains file for subject and extract params & choice data
    load(['RA_GAINS_' num2str(subject) '_fitpar.mat']);
    aP = Data.alpha_uncstr;
    bP = Data.beta_uncstr;
    gP = Data.gamma_uncstr;
    r2P = Data.r2_uncstr;
    aP_constr = Data.alpha_cstr;
    bP_constr = Data.beta_cstr;
    gP_constr = Data.gamma_cstr;
    r2P_constr = Data.r2_cstr;        
    
    riskyChoices_byLevelP = Data.riskyChoices_byLevel;
    ambigChoices_byLevelP = Data.ambigChoices_byLevel;
    riskyChoicesP = Data.riskyChoices;
    ambigChoicesP = Data.ambigChoices;
    choices4P = [NaN Data.choiceProb4 NaN NaN NaN NaN]';
    
    % load gains file for subject and extract params & choice data
    load(['RA_LOSS_' num2str(subject) '_fitpar.mat']);
    aN = Data.alpha_uncstr;
    bN = Data.beta_uncstr;
    gN = Data.gamma_uncstr;
    r2N = Data.r2_uncstr;
    aN_constr = Data.alpha_cstr;
    bN_constr = Data.beta_cstr;
    gN_constr = Data.gamma_cstr;
    r2N_constr = Data.r2_cstr;

    riskyChoices_byLevelN = Data.riskyChoices_byLevel;
    ambigChoices_byLevelN = Data.ambigChoices_byLevel;
    riskyChoicesN = Data.riskyChoices;
    ambigChoicesN = Data.ambigChoices;
    choices4N = [NaN Data.choiceProb4 NaN NaN NaN NaN]';       
    
    %write into param text file
    fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
        num2str(subject), aP, bP, gP, r2P, aN, bN, gN, r2N,...
        aP_constr, bP_constr, gP_constr, r2P_constr, aN_constr, bN_constr, gN_constr, r2N_constr,...
        riskyChoices_byLevelP,ambigChoices_byLevelP,riskyChoices_byLevelN,ambigChoices_byLevelN);
    
    % for Excel file - choice data   
    % subject 95 have missing trials for value -5, error in matrix
    % dimension
    if subject ~= 95
        % Firt, combine choice data with and without $4
        choices_rnaP = [riskyChoicesP; ambigChoicesP];
        choices_allP = [choices4P,choices_rnaP];
        choices_rnaN = [riskyChoicesN; ambigChoicesN];
        choices_allN = [choices4N,choices_rnaN];

        all_data_subject = [valueP; choices_allP ;valueN; choices_allN];

        dlmwrite(choiceData_file, subject , '-append', 'roffset', 1, 'delimiter', ' ');  
        dlmwrite(choiceData_file, all_data_subject, 'coffset', 1, '-append', 'delimiter', '\t');
    end
    
end

fclose(fid);
