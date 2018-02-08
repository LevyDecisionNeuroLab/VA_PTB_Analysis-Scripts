%% Copy sdm files into folders of different parametric modulators
%%
root = 'C:\Users\rj299\Documents\Projects in the lab\VA_RA_PTB\Analysis Ruonan\SDM files';
cd (root)

desti_none = fullfile(root, 'ParamNone\');
desti_reward = fullfile(root, 'ParamRewardValue\');
desti_SV = fullfile(root, 'ParamSV\');

source_none = fullfile(root, '*_none.sdm');
source_reward = fullfile(root, '*_RewardValue.sdm');
source_SV = fullfile(root, '*_SV.sdm');

copyfile(source_none, desti_none)
copyfile(source_reward, desti_reward)
copyfile(source_SV, desti_SV)

    
    