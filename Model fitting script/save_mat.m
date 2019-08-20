function save_mat(Data, subjectNum, domain, fitpar_out_path)
    
    save(fullfile(fitpar_out_path, ['RA_' domain '_' num2str(subjectNum) '_fitpar.mat']), 'Data')
    