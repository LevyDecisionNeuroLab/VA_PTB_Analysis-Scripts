function Data = load_mat(subjectNum, domain)
    
    fname = sprintf('RA_%s_%d.mat', domain, subjectNum);

    load(fname); % produces variable 'Data'
    