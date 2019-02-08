%% This script is meant to take both constrained/unconstrained fitpar files and print paramatric fit and non-paramatric summary to Excel
% it also create choice matrix for every subject
clearvars
close all
%cd 'C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\';
%addpath(genpath('C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\'));

%Input
fitparwave = 'Behavior data fitpar_020519';
outputwave = '_020519';
isconstrained = 2;
isdivided = 1; % if fit model to data for each day. 0-fit model on all data, 1-fit model on each day's data should get two values per subject for each parameter

% exclude should match those in the fit_parameters.m script
exclude = [77 1218]; 
% TEMPORARY: subjects incomplete data (that the script is not ready for)

%% folder and subjects
root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function
subjects = subjects(~ismember(subjects, exclude));


% subjects = [1210];
path = fullfile(root, 'Fitpar files', fitparwave, filesep);
cd(path)

% defining monetary values
valueP = [4 5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
valueN = [-4 -5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120]; 

% might not need
% output_file2 = 'choice_data.txt'
if isdivided == 0
    
    summary_file = ['param_nonparam' outputwave '.txt']; % parametric and nonparametric risk and ambig attitudes
    choiceData_file = [path 'choice_data' outputwave '.xls']; % choice matrix

    % both constrained and unconstrained
    if isconstrained == 2
        % results file
        fid = fopen([path summary_file],'w')
        fprintf(fid,'\tPar_unconstrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tPar_constrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tNonPar\n')
        fprintf(fid,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
    end

    % unconstrained
    if isconstrained == 0
        % results file
        fid = fopen([path summary_file],'w')
        fprintf(fid,'\tPar_unconstrained\n')
        fprintf(fid,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
    end

    % constrained
    if isconstrained == 1
        % results file
        fid = fopen([path summary_file],'w')
        fprintf(fid,'\tPar_constrained\n')
        fprintf(fid,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
    end

    % Fill in subject numbers separated by commas
    % subjects = {'87','88'};
    for s = 1:length(subjects)

        subject = subjects(s); 

        % load gains file for subject and extract params & choice data
        load(['RA_GAINS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~=1
            aP = Data.alpha_uncstr;
            bP = Data.beta_uncstr;
            gP = Data.gamma_uncstr;
            r2P = Data.r2_uncstr;
            LLP = Data.MLE_uncstr.LL;
            AICP = Data.MLE_uncstr.AIC;
            BICP = Data.MLE_uncstr.BIC;
        end

        if isconstrained ~=0
            aP_constr = Data.alpha_cstr;
            bP_constr = Data.beta_cstr;
            gP_constr = Data.gamma_cstr;
            r2P_constr = Data.r2_cstr;
            LLP_constr = Data.MLE_cstr.LL;
            AICP_constr = Data.MLE_cstr.AIC;
            BICP_constr = Data.MLE_cstr.BIC;      
        end

        riskyChoices_byLevelP = Data.riskyChoices_byLevel;
        ambigChoices_byLevelP = Data.ambigChoices_byLevel;
        riskyChoicesP = Data.riskyChoices;
        ambigChoicesP = Data.ambigChoices;
        choices4P = [NaN Data.choiceProb4 NaN NaN NaN NaN]';

        % load gains file for subject and extract params & choice data
        load(['RA_LOSS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~= 1
            aN = Data.alpha_uncstr;
            bN = Data.beta_uncstr;
            gN = Data.gamma_uncstr;
            r2N = Data.r2_uncstr;
            LLN = Data.MLE_uncstr.LL;
            AICN = Data.MLE_uncstr.AIC;
            BICN = Data.MLE_uncstr.BIC;

        end

        if isconstrained ~=0
            aN_constr = Data.alpha_cstr;
            bN_constr = Data.beta_cstr;
            gN_constr = Data.gamma_cstr;
            r2N_constr = Data.r2_cstr;
            LLN_constr = Data.MLE_cstr.LL;
            AICN_constr = Data.MLE_cstr.AIC;
            BICN_constr = Data.MLE_cstr.BIC;

        end

        riskyChoices_byLevelN = Data.riskyChoices_byLevel;
        ambigChoices_byLevelN = Data.ambigChoices_byLevel;
        riskyChoicesN = Data.riskyChoices;
        ambigChoicesN = Data.ambigChoices;
        choices4N = [NaN Data.choiceProb4 NaN NaN NaN NaN]';       

        if isconstrained == 2
            %write into param text file
            fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP, bP, gP, r2P, LLP, AICP, BICP, aN, bN, gN, r2N, LLN, AICN, BICN, ...
                aP_constr, bP_constr, gP_constr, r2P_constr, LLP_constr, AICP_constr, BICP_constr,...
                aN_constr, bN_constr, gN_constr, r2N_constr, LLN_constr, AICN_constr, BICN_constr,...
                riskyChoices_byLevelP,ambigChoices_byLevelP,riskyChoices_byLevelN,ambigChoices_byLevelN);
        end

        if isconstrained == 0
            %write into param text file
            fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP, bP, gP, r2P, LLP, AICP, BICP, aN, bN, gN, r2N, LLN, AICN, BICN, ...
                riskyChoices_byLevelP,ambigChoices_byLevelP,riskyChoices_byLevelN,ambigChoices_byLevelN);
        end

        if isconstrained == 1
            %write into param text file
            fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr, bP_constr, gP_constr, r2P_constr, LLP_constr, AICP_constr, BICP_constr,...
                aN_constr, bN_constr, gN_constr, r2N_constr, LLN_constr, AICN_constr, BICN_constr,...
                riskyChoices_byLevelP,ambigChoices_byLevelP,riskyChoices_byLevelN,ambigChoices_byLevelN);
        end

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
    
elseif isdivided == 1
    
    % files for day1
    summary_file_day1 = ['param_nonparam_day1' outputwave '.txt']; % parametric and nonparametric risk and ambig attitudes
    choiceData_file_day1 = [path 'choice_data_day1' outputwave '.xls']; % choice matrix
    % files for day2
    summary_file_day2 = ['param_nonparam_day2' outputwave '.txt']; % parametric and nonparametric risk and ambig attitudes
    choiceData_file_day2 = [path 'choice_data_day2' outputwave '.xls']; % choice matrix

    
    % both constrained and unconstrained
    if isconstrained == 2
        % results file
        fid_day1 = fopen([path summary_file_day1],'w')
        fprintf(fid_day1,'\tPar_unconstrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tPar_constrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tNonPar\n')
        fprintf(fid_day1,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day1,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
        
        fid_day2 = fopen([path summary_file_day2],'w')
        fprintf(fid_day2,'\tPar_unconstrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tPar_constrained\t\t\t\t\t\t\t\t\t\t\t\t\t\tNonPar\n')
        fprintf(fid_day2,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day2,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

    end

    % unconstrained
    if isconstrained == 0
        % results file
        fid_day1 = fopen([path summary_file_day1],'w')
        fprintf(fid_day1,'\tPar_unconstrained\n')
        fprintf(fid_day1,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day1,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
        
        fid_day2 = fopen([path summary_file_day2],'w')
        fprintf(fid_day2,'\tPar_unconstrained\n')
        fprintf(fid_day2,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day2,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

    end

    % constrained
    if isconstrained == 1
        % results file
        fid_day1 = fopen([path summary_file_day1],'w')
        fprintf(fid_day1,'\tPar_constrained\n')
        fprintf(fid_day1,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day1,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
        
        fid_day2 = fopen([path summary_file_day2],'w')
        fprintf(fid_day2,'\tPar_constrained\n')
        fprintf(fid_day2,'subject\tgains\t\t\t\t\t\t\tlosses\t\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day2,'\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\talpha\tbeta\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

    end   
    
    % Fill in subject numbers separated by commas
    % subjects = {'87','88'};
    for s = 1:length(subjects)

        subject = subjects(s); 

        % load gains file for subject and extract params & choice data
        load(['RA_GAINS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~=1
            aP_day1 = Data.day1.alpha_uncstr;
            bP_day1 = Data.day1.beta_uncstr;
            gP_day1 = Data.day1.gamma_uncstr;
            r2P_day1 = Data.day1.r2_uncstr;
            LLP_day1 = Data.day1.MLE_uncstr.LL;
            AICP_day1 = Data.day1.MLE_uncstr.AIC;
            BICP_day1 = Data.day1.MLE_uncstr.BIC;
            
            aP_day2 = Data.day2.alpha_uncstr;
            bP_day2 = Data.day2.beta_uncstr;
            gP_day2 = Data.day2.gamma_uncstr;
            r2P_day2 = Data.day2.r2_uncstr;
            LLP_day2 = Data.day2.MLE_uncstr.LL;
            AICP_day2 = Data.day2.MLE_uncstr.AIC;
            BICP_day2 = Data.day2.MLE_uncstr.BIC;
            
        end

        if isconstrained ~=0
            aP_constr_day1 = Data.day1.alpha_cstr;
            bP_constr_day1 = Data.day1.beta_cstr;
            gP_constr_day1 = Data.day1.gamma_cstr;
            r2P_constr_day1 = Data.day1.r2_cstr;
            LLP_constr_day1 = Data.day1.MLE_cstr.LL;
            AICP_constr_day1 = Data.day1.MLE_cstr.AIC;
            BICP_constr_day1 = Data.day1.MLE_cstr.BIC;      
            
            aP_constr_day2 = Data.day2.alpha_cstr;
            bP_constr_day2 = Data.day2.beta_cstr;
            gP_constr_day2 = Data.day2.gamma_cstr;
            r2P_constr_day2 = Data.day2.r2_cstr;
            LLP_constr_day2 = Data.day2.MLE_cstr.LL;
            AICP_constr_day2 = Data.day2.MLE_cstr.AIC;
            BICP_constr_day2 = Data.day2.MLE_cstr.BIC;      
            
        end

        riskyChoices_byLevelP_day1 = Data.day1.riskyChoices_byLevel;
        ambigChoices_byLevelP_day1 = Data.day1.ambigChoices_byLevel;
        riskyChoices_byLevelP_day2 = Data.day2.riskyChoices_byLevel;
        ambigChoices_byLevelP_day2 = Data.day2.ambigChoices_byLevel;

        riskyChoicesP_day1 = Data.day1.riskyChoices;
        ambigChoicesP_day1 = Data.day1.ambigChoices;
        riskyChoicesP_day2 = Data.day2.riskyChoices;
        ambigChoicesP_day2 = Data.day2.ambigChoices;
        
        choices4P_day1 = [NaN Data.day1.choiceProb4 NaN NaN NaN NaN]';
        choices4P_day2 = [NaN Data.day2.choiceProb4 NaN NaN NaN NaN]';

        % load gains file for subject and extract params & choice data
        load(['RA_LOSS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~= 1
            aN_day1 = Data.day1.alpha_uncstr;
            bN_day1 = Data.day1.beta_uncstr;
            gN_day1 = Data.day1.gamma_uncstr;
            r2N_day1 = Data.day1.r2_uncstr;
            LLN_day1 = Data.day1.MLE_uncstr.LL;
            AICN_day1 = Data.day1.MLE_uncstr.AIC;
            BICN_day1 = Data.day1.MLE_uncstr.BIC;

            aN_day2 = Data.day2.alpha_uncstr;
            bN_day2 = Data.day2.beta_uncstr;
            gN_day2 = Data.day2.gamma_uncstr;
            r2N_day2 = Data.day2.r2_uncstr;
            LLN_day2 = Data.day2.MLE_uncstr.LL;
            AICN_day2 = Data.day2.MLE_uncstr.AIC;
            BICN_day2 = Data.day2.MLE_uncstr.BIC;

        end

        if isconstrained ~=0
            aN_constr_day1 = Data.day1.alpha_cstr;
            bN_constr_day1 = Data.day1.beta_cstr;
            gN_constr_day1 = Data.day1.gamma_cstr;
            r2N_constr_day1 = Data.day1.r2_cstr;
            LLN_constr_day1 = Data.day1.MLE_cstr.LL;
            AICN_constr_day1 = Data.day1.MLE_cstr.AIC;
            BICN_constr_day1 = Data.day1.MLE_cstr.BIC;

            aN_constr_day2 = Data.day2.alpha_cstr;
            bN_constr_day2 = Data.day2.beta_cstr;
            gN_constr_day2 = Data.day2.gamma_cstr;
            r2N_constr_day2 = Data.day2.r2_cstr;
            LLN_constr_day2 = Data.day2.MLE_cstr.LL;
            AICN_constr_day2 = Data.day2.MLE_cstr.AIC;
            BICN_constr_day2 = Data.day2.MLE_cstr.BIC;
            
        end

        riskyChoices_byLevelN_day1 = Data.day1.riskyChoices_byLevel;
        ambigChoices_byLevelN_day1 = Data.day1.ambigChoices_byLevel;
        riskyChoices_byLevelN_day2 = Data.day2.riskyChoices_byLevel;
        ambigChoices_byLevelN_day2 = Data.day2.ambigChoices_byLevel;
        
        riskyChoicesN_day1 = Data.day1.riskyChoices;
        ambigChoicesN_day1 = Data.day1.ambigChoices;
        riskyChoicesN_day2 = Data.day2.riskyChoices;
        ambigChoicesN_day2 = Data.day2.ambigChoices;
        
        choices4N_day1 = [NaN Data.day1.choiceProb4 NaN NaN NaN NaN]';       
        choices4N_day2 = [NaN Data.day2.choiceProb4 NaN NaN NaN NaN]';       

        if isconstrained == 2
            %write into param text file
            fprintf(fid_day1,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day1, bP_day1, gP_day1, r2P_day1, LLP_day1, AICP_day1, BICP_day1, aN_day1, bN_day1, gN_day1, r2N_day1, LLN_day1, AICN_day1, BICN_day1, ...
                aP_constr_day1, bP_constr_day1, gP_constr_day1, r2P_constr_day1, LLP_constr_day1, AICP_constr_day1, BICP_constr_day1,...
                aN_constr_day1, bN_constr_day1, gN_constr_day1, r2N_constr_day1, LLN_constr_day1, AICN_constr_day1, BICN_constr_day1,...
                riskyChoices_byLevelP_day1,ambigChoices_byLevelP_day1,riskyChoices_byLevelN_day1,ambigChoices_byLevelN_day1);
            
            fprintf(fid_day2,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day2, bP_day2, gP_day2, r2P_day2, LLP_day2, AICP_day2, BICP_day2, aN_day2, bN_day2, gN_day2, r2N_day2, LLN_day2, AICN_day2, BICN_day2, ...
                aP_constr_day2, bP_constr_day2, gP_constr_day2, r2P_constr_day2, LLP_constr_day2, AICP_constr_day2, BICP_constr_day2,...
                aN_constr_day2, bN_constr_day2, gN_constr_day2, r2N_constr_day2, LLN_constr_day2, AICN_constr_day2, BICN_constr_day2,...
                riskyChoices_byLevelP_day2,ambigChoices_byLevelP_day2,riskyChoices_byLevelN_day2,ambigChoices_byLevelN_day2);
            
        end

        if isconstrained == 0
            %write into param text file
            fprintf(fid_day1,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day1, bP_day1, gP_day1, r2P_day1, LLP_day1, AICP_day1, BICP_day1, aN_day1, bN_day1, gN_day1, r2N_day1, LLN_day1, AICN_day1, BICN_day1, ...
                riskyChoices_byLevelP_day1,ambigChoices_byLevelP_day1,riskyChoices_byLevelN_day1,ambigChoices_byLevelN_day1);
            
            fprintf(fid_day2,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day2, bP_day2, gP_day2, r2P_day2, LLP_day2, AICP_day2, BICP_day2, aN_day2, bN_day2, gN_day2, r2N_day2, LLN_day2, AICN_day2, BICN_day2, ...
                riskyChoices_byLevelP_day2,ambigChoices_byLevelP_day2,riskyChoices_byLevelN_day2,ambigChoices_byLevelN_day2);
            
        end

        if isconstrained == 1
            %write into param text file
            fprintf(fid_day1,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr_day1, bP_constr_day1, gP_constr_day1, r2P_constr_day1, LLP_constr_day1, AICP_constr_day1, BICP_constr_day1,...
                aN_constr_day1, bN_constr_day1, gN_constr_day1, r2N_constr_day1, LLN_constr_day1, AICN_constr_day1, BICN_constr_day1,...
                riskyChoices_byLevelP_day1, ambigChoices_byLevelP_day1, riskyChoices_byLevelN_day1, ambigChoices_byLevelN_day1);

            fprintf(fid_day2,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr_day2, bP_constr_day2, gP_constr_day2, r2P_constr_day2, LLP_constr_day2, AICP_constr_day2, BICP_constr_day2,...
                aN_constr_day2, bN_constr_day2, gN_constr_day2, r2N_constr_day2, LLN_constr_day2, AICN_constr_day2, BICN_constr_day2,...
                riskyChoices_byLevelP_day2, ambigChoices_byLevelP_day2, riskyChoices_byLevelN_day2, ambigChoices_byLevelN_day2);
            
        end

        % for Excel file - choice data
        % subject 95 have missing trials for value -5, error in matrix dimension
        if subject ~= 95
            % Firt, combine choice data with and without $4
            choices_rnaP_day1 = [riskyChoicesP_day1; ambigChoicesP_day1];
            choices_allP_day1 = [choices4P_day1,choices_rnaP_day1];
            choices_rnaN_day1 = [riskyChoicesN_day1; ambigChoicesN_day1];
            choices_allN_day1 = [choices4N_day1,choices_rnaN_day1];

            all_data_subject_day1 = [valueP; choices_allP_day1 ;valueN; choices_allN_day1];

            dlmwrite(choiceData_file_day1, subject , '-append', 'roffset', 1, 'delimiter', ' ');  
            dlmwrite(choiceData_file_day1, all_data_subject_day1, 'coffset', 1, '-append', 'delimiter', '\t');
            

            choices_rnaP_day2 = [riskyChoicesP_day2; ambigChoicesP_day2];
            choices_allP_day2 = [choices4P_day2,choices_rnaP_day2];
            choices_rnaN_day2 = [riskyChoicesN_day2; ambigChoicesN_day2];
            choices_allN_day2 = [choices4N_day2,choices_rnaN_day2];

            all_data_subject_day2 = [valueP; choices_allP_day2 ;valueN; choices_allN_day2];

            dlmwrite(choiceData_file_day2, subject , '-append', 'roffset', 1, 'delimiter', ' ');  
            dlmwrite(choiceData_file_day2, all_data_subject_day2, 'coffset', 1, '-append', 'delimiter', '\t');
            
        end

    end
    
    fclose(fid_day1);
    fclose(fid_day2);
end


