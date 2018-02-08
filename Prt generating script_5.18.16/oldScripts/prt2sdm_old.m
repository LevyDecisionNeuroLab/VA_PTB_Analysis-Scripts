n = neuroelf;

addpath ('C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Prt files\')
prts = n.findfiles(pwd,'*.prt');

for i = 1:length(prts)
    prt = xff(prts{i});
    sdm = prt.CreateSDM(struct('nvol',490,'prtr',1000,'rcond',[]));
    x = strfind(prts{i},'\');
    name = prts{i}(x(length(x))+1:length(prts{i})-4);
    sdm.SaveAs(['C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan\SDM files\' name '.sdm']);
end
    