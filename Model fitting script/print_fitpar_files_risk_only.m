%% This script is meant to take both constrained/unconstrained fitpar files and print paramatric fit and non-paramatric summary to Excel
% it also create choice matrix for every subject
clearvars
close all
%cd 'C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\';
%addpath(genpath('C:\Users\lr382\Desktop\Lital\RISK-VA\Behavior for PTB\'));

%Input
fitparwave = 'Behavior data fitpar_08260119';
outputwave = '_08260119';
isconstrained = 0;
isdivided = 1; % if fit model to data for each day. 0-fit model on all data, 1-fit model on each day's data should get two values per subject for each parameter

% exclude should match those in the fit_parameters.m script
exclude = [77 1218]; 
% TEMPORARY: subjects incomplete data (that the script is not ready for)

%% folder and subjects
root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Behavior data of PTB log/'); % Original log from PTB
subjects = getSubjectsInDir(data_path, 'subj'); %function
subjects = subjects(~ismember(subjects, exclude));

% subjects = [3, 120, 1210, 1220, 1272, 1301, 1357, 1360, 1269, 1337, 1347, 1354];
subjects = [3 81 120 1300 1074 1216 1338 1345 1069];

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

    % unconstrained
    if isconstrained == 0
        % results file
        fid = fopen([path summary_file],'w')
        fprintf(fid,'\tPar_unconstrained\n')
        fprintf(fid,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
    end

    % constrained
    if isconstrained == 1
        % results file
        fid = fopen([path summary_file],'w')
        fprintf(fid,'\tPar_constrained\n')
        fprintf(fid,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
    end

    % Fill in subject numbers separated by commas
    % subjects = {'87','88'};
    for s = 1:length(subjects)

        subject = subjects(s); 

        % load gains file for subject and extract params & choice data
        load(['RA_GAINS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~=1
            aP = Data.alpha_uncstr;
            gP = Data.gamma_uncstr;
            r2P = Data.r2_uncstr;
            LLP = Data.MLE_uncstr.LL;
            AICP = Data.MLE_uncstr.AIC;
            BICP = Data.MLE_uncstr.BIC;
        end

        if isconstrained ~=0
            aP_constr = Data.alpha_cstr;
            gP_constr = Data.gamma_cstr;
            r2P_constr = Data.r2_cstr;
            LLP_constr = Data.MLE_cstr.LL;
            AICP_constr = Data.MLE_cstr.AIC;
            BICP_constr = Data.MLE_cstr.BIC;      
        end


        % load gains file for subject and extract params & choice data
        load(['RA_LOSS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~= 1
            aN = Data.alpha_uncstr;
            gN = Data.gamma_uncstr;
            r2N = Data.r2_uncstr;
            LLN = Data.MLE_uncstr.LL;
            AICN = Data.MLE_uncstr.AIC;
            BICN = Data.MLE_uncstr.BIC;

        end

        if isconstrained ~=0
            aN_constr = Data.alpha_cstr;
            gN_constr = Data.gamma_cstr;
            r2N_constr = Data.r2_cstr;
            LLN_constr = Data.MLE_cstr.LL;
            AICN_constr = Data.MLE_cstr.AIC;
            BICN_constr = Data.MLE_cstr.BIC;

        end

        if isconstrained == 0
            %write into param text file
            fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP, gP, r2P, LLP, AICP, BICP, aN, gN, r2N, LLN, AICN, BICN);
        end

        if isconstrained == 1
            %write into param text file
            fprintf(fid,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr, gP_constr, r2P_constr, LLP_constr, AICP_constr, BICP_constr,...
                aN_constr, gN_constr, r2N_constr, LLN_constr, AICN_constr, BICN_constr);
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


    % unconstrained
    if isconstrained == 0
        % results file
        fid_day1 = fopen([path summary_file_day1],'w')
        fprintf(fid_day1,'\tPar_unconstrained\n')
        fprintf(fid_day1,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day1,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
        
        fid_day2 = fopen([path summary_file_day2],'w')
        fprintf(fid_day2,'\tPar_unconstrained\n')
        fprintf(fid_day2,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day2,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

    end

    % constrained
    if isconstrained == 1
        % results file
        fid_day1 = fopen([path summary_file_day1],'w')
        fprintf(fid_day1,'\tPar_constrained\n')
        fprintf(fid_day1,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day1,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')
        
        fid_day2 = fopen([path summary_file_day2],'w')
        fprintf(fid_day2,'\tPar_constrained\n')
        fprintf(fid_day2,'subject\tgains\t\t\t\t\t\tlosses\t\t\t\t\t\tgains\t\t\t\t\t\tlosses\n')
        fprintf(fid_day2,'\talpha\tgamma\tr2\tLL\tAIC\tBIC\talpha\tgamma\tr2\tLL\tAIC\tBIC\tG_risk25\tG_risk50\tG_risk75\tG_amb24\tG_amb50\tG_amb74\tL_risk25\tL_risk50\tL_risk75\tL_amb24\tL_amb50\tL_amb74\n')

    end   
    
    for s = 1:length(subjects)

        subject = subjects(s); 

        % load gains file for subject and extract params & choice data
        load(['RA_GAINS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~=1
            aP_day1 = Data.day1.alpha_uncstr;
            gP_day1 = Data.day1.gamma_uncstr;
            r2P_day1 = Data.day1.r2_uncstr;
            LLP_day1 = Data.day1.MLE_uncstr.LL;
            AICP_day1 = Data.day1.MLE_uncstr.AIC;
            BICP_day1 = Data.day1.MLE_uncstr.BIC;
            
            aP_day2 = Data.day2.alpha_uncstr;
            gP_day2 = Data.day2.gamma_uncstr;
            r2P_day2 = Data.day2.r2_uncstr;
            LLP_day2 = Data.day2.MLE_uncstr.LL;
            AICP_day2 = Data.day2.MLE_uncstr.AIC;
            BICP_day2 = Data.day2.MLE_uncstr.BIC;
            
        end

        if isconstrained ~=0
            aP_constr_day1 = Data.day1.alpha_cstr;
            gP_constr_day1 = Data.day1.gamma_cstr;
            r2P_constr_day1 = Data.day1.r2_cstr;
            LLP_constr_day1 = Data.day1.MLE_cstr.LL;
            AICP_constr_day1 = Data.day1.MLE_cstr.AIC;
            BICP_constr_day1 = Data.day1.MLE_cstr.BIC;      
            
            aP_constr_day2 = Data.day2.alpha_cstr;
            gP_constr_day2 = Data.day2.gamma_cstr;
            r2P_constr_day2 = Data.day2.r2_cstr;
            LLP_constr_day2 = Data.day2.MLE_cstr.LL;
            AICP_constr_day2 = Data.day2.MLE_cstr.AIC;
            BICP_constr_day2 = Data.day2.MLE_cstr.BIC;      
            
        end


        % load loss file for subject and extract params & choice data
        load(['RA_LOSS_' num2str(subject) '_fitpar.mat']);
        if isconstrained ~= 1
            aN_day1 = Data.day1.alpha_uncstr;
            gN_day1 = Data.day1.gamma_uncstr;
            r2N_day1 = Data.day1.r2_uncstr;
            LLN_day1 = Data.day1.MLE_uncstr.LL;
            AICN_day1 = Data.day1.MLE_uncstr.AIC;
            BICN_day1 = Data.day1.MLE_uncstr.BIC;

            aN_day2 = Data.day2.alpha_uncstr;
            gN_day2 = Data.day2.gamma_uncstr;
            r2N_day2 = Data.day2.r2_uncstr;
            LLN_day2 = Data.day2.MLE_uncstr.LL;
            AICN_day2 = Data.day2.MLE_uncstr.AIC;
            BICN_day2 = Data.day2.MLE_uncstr.BIC;

        end

        if isconstrained ~=0
            aN_constr_day1 = Data.day1.alpha_cstr;
            gN_constr_day1 = Data.day1.gamma_cstr;
            r2N_constr_day1 = Data.day1.r2_cstr;
            LLN_constr_day1 = Data.day1.MLE_cstr.LL;
            AICN_constr_day1 = Data.day1.MLE_cstr.AIC;
            BICN_constr_day1 = Data.day1.MLE_cstr.BIC;

            aN_constr_day2 = Data.day2.alpha_cstr;
            gN_constr_day2 = Data.day2.gamma_cstr;
            r2N_constr_day2 = Data.day2.r2_cstr;
            LLN_constr_day2 = Data.day2.MLE_cstr.LL;
            AICN_constr_day2 = Data.day2.MLE_cstr.AIC;
            BICN_constr_day2 = Data.day2.MLE_cstr.BIC;
            
        end
  

        if isconstrained == 0
            %write into param text file
            fprintf(fid_day1,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day1, gP_day1, r2P_day1, LLP_day1, AICP_day1, BICP_day1, aN_day1, gN_day1, r2N_day1, LLN_day1, AICN_day1, BICN_day1);
            
            fprintf(fid_day2,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_day2, gP_day2, r2P_day2, LLP_day2, AICP_day2, BICP_day2, aN_day2, gN_day2, r2N_day2, LLN_day2, AICN_day2, BICN_day2);
            
        end

        if isconstrained == 1
            %write into param text file
            fprintf(fid_day1,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr_day1, gP_constr_day1, r2P_constr_day1, LLP_constr_day1, AICP_constr_day1, BICP_constr_day1,...
                aN_constr_day1, gN_constr_day1, r2N_constr_day1, LLN_constr_day1, AICN_constr_day1, BICN_constr_day1);

            fprintf(fid_day2,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                num2str(subject), aP_constr_day2, gP_constr_day2, r2P_constr_day2, LLP_constr_day2, AICP_constr_day2, BICP_constr_day2,...
                aN_constr_day2, gN_constr_day2, r2N_constr_day2, LLN_constr_day2, AICN_constr_day2, BICN_constr_day2);
            
        end

    end
    
    fclose(fid_day1);
    fclose(fid_day2);
end


