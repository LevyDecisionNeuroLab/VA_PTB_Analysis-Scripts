% PRT2SDM Take all PRT files and re-make them into SDM files
%
% NOTE: If you get an error about `checkstruct` called in `CreateSDM`,
% this is caused by Neuroelf's function being named identically to
% MATLAB's Finance Toolkit's function. Remove the Finance Toolkit from
% path to solve the problem.
clearvars

%% Load + save settings
prtwave = 'Prt files_06072019';
sdmwave = 'Sdm files_06072019';

root_path = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';
prt_loc = [root_path filesep 'Prt files' filesep prtwave filesep];
sdm_loc = [root_path filesep 'Sdm files' filesep sdmwave filesep];

if exist(sdm_loc) == 0
    mkdir(sdm_loc);
end

n = neuroelf;
prts = n.findfiles(prt_loc, '*.prt');

for i = 1:length(prts)
    prt_filename = prts{i};
    prt = xff(prt_filename);

    % NOTE: Although there will be 490 volumes in every block, the furthest 
    % block of interest is block 482. (Due to pseudorandom ITI assignment, 
    % it can also be block 478 or 480.)
    sdm = prt.CreateSDM(struct('nvol', 490, ... 
            'prtr', 1000, ...
            'rcond', []));

    [~, name, ~] = fileparts(prt_filename); % Only filename, without path or extension
    sdm.SaveAs([sdm_loc name '.sdm']);

    % The operation takes time and operates on many files -> 
    fprintf('%.2f%%: Generated %s\n', 100 * i / length(prts), name);
end
