% this script calculate and print out subjective value of each lottery for
% each subjects

clearvars
close all

%% subjects uncertainty attitudes
par_root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral';
par_filename = 'par nonpar att_allSubj_03202019.csv';
par = readtable(fullfile(par_root, par_filename));
subjects = unique(par.id); %function

fitparwave = 'Behavior data fitpar_08272019';
root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
data_path = fullfile(root, 'Fitpar files', fitparwave, filesep);

% defining monetary values
valueP = [4 5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
value = repmat(valueP,6,1);
valueN = [-4 -5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120];
% six risk and ambig levels
prob = [0.25; 0.5; 0.75; 0.5; 0.5; 0.5];
probs = repmat(prob, 1, length(valueP));
ambig = [0; 0; 0; 0.24; 0.5; 0.74];
ambigs = repmat(ambig, 1, length(valueP));

for s = 1:length(subjects)
    subject = subjects(s);
%     subject = 120;
    alpha_gain = par.alpha(par.id == subject & par.isGain == 1);
    beta_gain = par.beta(par.id == subject & par.isGain == 1);
    alpha_loss = par.alpha(par.id == subject & par.isGain == 0);
    beta_loss = par.beta(par.id == subject & par.isGain == 0);

    if ~isnan(beta_gain)
        model_gain = 'ambigNrisk';
    elseif isnan(beta_gain)
        model_gain = 'risk';
    end
    
    sv_gains = ambig_utility(0, ...
          value, ...
          probs, ...
          ambigs, ...
          alpha_gain, ...
          beta_gain, ...
          model_gain);
    svRef_gains = ambig_utility(0, 5, 1, 0, alpha_gain, beta_gain, model_gain);
    
    if ~isnan(beta_loss)
        model_loss = 'ambigNrisk';
    elseif isnan(beta_loss)
        model_loss = 'risk';
    end
    
    sv_loss = ambig_utility(0, ...
          value, ...
          probs, ...
          ambigs, ...
          alpha_loss, ...
          beta_loss, ...
          model_loss);
    sv_loss = -1 .* sv_loss;
    
    svRef_loss = ambig_utility(0, 5, 1, 0, alpha_loss, beta_loss, model_loss);
    svRef_loss = -1 .* svRef_loss;
   
    %% for Excel file - subjective values
    xlFile = [par_root '\SV_by_lottery_08272019.xls'];
    dlmwrite(xlFile, subject, '-append', 'roffset', 1, 'delimiter', ' '); 
    dlmwrite(xlFile, svRef_gains, '-append', 'coffset', 1, 'delimiter', '\t');
    dlmwrite(xlFile, sv_gains, 'coffset', 1, '-append', 'delimiter', '\t');
    dlmwrite(xlFile, svRef_loss, '-append', 'coffset', 1, 'delimiter', '\t');
    dlmwrite(xlFile, sv_loss, 'coffset', 1, '-append', 'delimiter', '\t');

end

