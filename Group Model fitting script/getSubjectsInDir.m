function [ subjects ] = getSubjectsInDir(data_path, prefix)
%GETSUBJECTSINDIR Extracts all subject IDs from a DATA_PATH,
%Data in .mat file are generated when running the task script. We save the data from the same subject in the folder named 'subjNo.' such as 'subj78'. 
%assuming that all folders follow the naming convention "prefix{ID}"

subj_dirs = dir([fullfile(data_path, prefix) '*']);

subjects = zeros(1, length(subj_dirs));
for k = 1 : length(subj_dirs)
    % Extract subject ids from folder names
    if subj_dirs(k).isdir
        subjects(k) = str2num(subj_dirs(k).name((1 + length(prefix)) : end));
    end
end

% Remove zeros and sort
subjects = subjects(subjects > 0); % in case we looped through non-dir
subjects = sort(subjects);
end