% delete prt files that need to be excluded

clearvars
close all

%% prt file path
prtwave = 'Prt files_06072019';
root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan';

prt_path = fullfile(root, 'Prt files', prtwave, filesep);

%% Subject number and corresponding blocks to delete
subject_list = [87 93 95 98 122 1072 1074 1208 1216 1232 1245 1278 1285 1290 1304 1305 1338 1345];
block_list = {[2], [7 8], [6], [6], [1 7 8], [6 7], [2], [7 8], [3], [1 2 3 4 8], [2], [1 2 3 4 8], [3], [3 4 8], [8], [4 8], [6], [4 7]};

for sub_idx = 1:length(subject_list)
    subject_id = subject_list(sub_idx);
    for block_idx = 1:length(block_list{sub_idx})
        block_id = block_list{sub_idx}(block_idx);
        filename = fullfile(prt_path, [num2str(subject_id),'_*_block', num2str(block_id), '*.prt']);
        delete(filename)
        disp(['Deleted subject ' num2str(subject_id), ' block ' num2str(block_id)]);
        disp(filename)
    end
end