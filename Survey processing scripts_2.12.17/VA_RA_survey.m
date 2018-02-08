clear all
close all

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Survey';
filename = 'VA_RA_BISBAS_BIS11_DOSPERT_factor.xlsx';
surv = readtable(fullfile(root, filename));

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Clinical and behavioral';
filename = 'Clinical_Behavioral_60subjects_102616.txt';
behav = readtable(fullfile(root, filename));