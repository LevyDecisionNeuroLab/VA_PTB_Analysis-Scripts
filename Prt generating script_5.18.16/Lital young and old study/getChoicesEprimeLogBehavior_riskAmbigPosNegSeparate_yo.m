function [vA,pA,AL,ref,choice_lottery] = getChoicesEprimeLogBehavior_riskAmbigPosNegSeparate(filename,trials2Use)

% INPUT
% filename      - text file, including path, excluding extension
% trials2Use    - vector of trial numbers
%
% OUTPUT
% vA    - values of varying options
% pA    - probabilities of varying options
% AL    - ambiguity level
% ref   - reference
% choice_lottery    - 1's and 0's

fid=fopen(filename,'r')
fgets(fid)
fgets(fid)

% read data - change if data file is changed
data = textscan(fid,'%d%d%d%d%d%d%d%s%s');

% read data into vectors for model fit
vA = data{4}(trials2Use) + data{5}(trials2Use); % value including jitter
ref = zeros(size(vA));
pA = zeros(size(vA));
AL = zeros(size(vA));
choice_lottery = zeros(size(vA));

for i = 1:length(trials2Use)
    riskAmbig = char(data{9}(trials2Use(i)));
    if strcmp(riskAmbig(1:4),'risk')
        pA(i) = str2num(riskAmbig(length(riskAmbig)-1:length(riskAmbig)))/100;
        AL(i) = 0;
    else
        pA(i) = 0.5;
        AL(i) = str2num(riskAmbig(length(riskAmbig)-1:length(riskAmbig)))/100;
    end
    % reference
    if vA(i) < 0
        ref(i) = -5;
    else
        ref(i) = 5;
    end
    
    % figure out which one is the lottery
    if (strcmp(data{8}(trials2Use(i)),'Left') && data{6}(trials2Use(i))==1) || (strcmp(data{8}(trials2Use(i)),'Right') && data{6}(trials2Use(i))==2)
        % lottery chosen
        choice_lottery(i) = 1;
    elseif data{6}(trials2Use(i)) == 0;
        % no response
        choice_lottery(i) = 2
    else
        % reference chosen
        choice_lottery(i) = 0;
    end
        
            
end     

fclose(fid)


    