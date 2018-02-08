function [vA,pA,AL,choice_lottery] = getChoicesEprimeLogScan(filename,trials2Use)

% [vA,pA,AL,choice_lottery,ambigChoices,riskyChoices] =
% getChoicesEprimeLog(filename)
%
% INPUT
% filename      - text file, including path, excluding extension
% trials2Use    - vector of trial numbers
%
% OUTPUT
% vA    - values of varying options
% pA    - probabilities of varying options
% AL    - ambiguity level
% choice_lottery    - 1's and 0's
% ambigChoices      - percentage of ambiguous choices
% riskyChoices      - percentage of risky choices

fid=fopen(filename,'r')
fgets(fid)
fgets(fid)

% read data - change if data file is changed
data = textscan(fid,'%d%d%d%d%d%d%d%s');

% read data into vectors for model fit
vA = data{4}(trials2Use) + data{5}(trials2Use); % value including jitter
pA = zeros(size(vA));
AL = zeros(size(vA));
for i = 1:length(trials2Use)
    if strcmp(data{8}(trials2Use(i)),'risk_blue_13') || strcmp(data{8}(trials2Use(i)),'risk_red_13')
        pA(i) = 0.13;
        AL(i) = 0;
    elseif strcmp(data{8}(trials2Use(i)),'risk_blue_25') || strcmp(data{8}(trials2Use(i)),'risk_red_25')
        pA(i) = 0.25;
        AL(i) = 0;
    elseif strcmp(data{8}(trials2Use(i)),'risk_blue_38') || strcmp(data{8}(trials2Use(i)),'risk_red_38')
        pA(i) = 0.38;
        AL(i) = 0;
    elseif strcmp(data{8}(trials2Use(i)),'ambig_25')
        pA(i) = 0.5;
        AL(i) = 0.25;
    elseif strcmp(data{8}(trials2Use(i)),'ambig_50')
        pA(i) = 0.5;
        AL(i) = 0.5;
    elseif strcmp(data{8}(trials2Use(i)),'ambig_75')
        pA(i) = 0.5;
        AL(i) = 0.75;
    end
            
end     

choice_lottery = data{6}(trials2Use);
fclose(fid)


    