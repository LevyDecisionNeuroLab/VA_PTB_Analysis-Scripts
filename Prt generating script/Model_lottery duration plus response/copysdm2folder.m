%% Copy sdm files into folders of different parametric modulators
clearvars

%%
sdmwave = 'Sdm files_042418';
root = ['D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan\Sdm files\' sdmwave];
cd (root)

desti_none = fullfile(root, 'none\');
desti_reward = fullfile(root, 'RewardValue\');
% desti_SV = fullfile(root, 'SV\');
desti_AmbigLevel = fullfile(root, 'AmbiguityLevel\');
desti_RiskLevel = fullfile(root, 'RiskLevel\');

source_none = fullfile(root, '*_none.sdm');
source_reward = fullfile(root, '*_RewardValue.sdm');
% source_SV = fullfile(root, '*_SV.sdm');
source_AmbigLevel = fullfile(root, '*_AmbiguityLevel.sdm');
source_RiskLevel = fullfile(root, '*_RiskLevel.sdm');

copyfile(source_none, desti_none)
copyfile(source_reward, desti_reward)
% copyfile(source_SV, desti_SV)
copyfile(source_AmbigLevel, desti_AmbigLevel)
copyfile(source_RiskLevel, desti_RiskLevel)