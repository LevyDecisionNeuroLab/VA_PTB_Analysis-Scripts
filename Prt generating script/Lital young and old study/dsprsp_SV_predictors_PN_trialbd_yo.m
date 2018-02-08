clear all
close all

fixed_valueP = 5;
fixed_valueN = -5;

fixed_prob = 1;

valueP = [5 8 20 50 125]
valueN = [-5 -8 -20 -50 -125] 
base = 0;

ambig = [.25 .5 .75];
prob = [0.75 0.5 0.25];

model = 'ambigNrisk'

% Initialize parameters (this could be smarter)
if strcmp(model,'ambiguity')
   b0 = [-1 1]';
elseif strcmp(model,'power')
   b0 = [-1 0.8];
elseif strcmp(model, 'ambigNrisk')
   b0 = [-1 0.5 0.5]'; %slope, beta, alpha
elseif strcmp(model, 'ambigNriskFixSlope')
   b0 = [0.5 0.5]'; %beta, alpha
end

path = 'Z:\Levy_Lab\Data_fMRI\R&A_young_adults\Lital-matlab\display-vs-resp\';

%NPsubjects = {'1829'} % insert subjects ids if different predictors for different subjects
PNsubjects = {'20003', '20005', '20007', '20009', '20013', '20015','1825', '2130', '2179', '2175', '2177', '2180', '2182', '2333', '2335'}
    
  for s = 1:length(PNsubjects)
    subject = PNsubjects{s};

    filename = [path subject '.txt']
    
    trials2Use = 1:240
    
    [vA,pA,AL,ref,choice_lottery] = getChoicesEprimeLogBehavior_riskAmbigPosNegSeparate(filename,trials2Use); 
    vA = double(vA);

    SVs = zeros(size(vA));
  % actual choices
    choice_orig = choice_lottery;

    % get rid of no choice trials
   % choice = choice_orig(find(choice_orig~=2));
   % vA = vA(find(choice_orig~=2));
   % AL = AL(find(choice_orig~=2));
   % pA = pA(find(choice_orig~=2));


    % separate fit for pos
    choiceP = choice_orig(find(vA>0)); %change from choice to choice_orig (Lital)
    vP = vA(find(vA>0));
    pP = pA(find(vA>0));
    AP = AL(find(vA>0));
    vFP = fixed_valueP * ones(length(choiceP),1);
    pFP = fixed_prob * ones(length(choiceP),1);
    
    [info,p] = fit_ambigNrisk_model(choiceP,vFP,vP,pFP,pP,AP,model,b0,base);

    if strcmp(model,'ambigNrisk')
        slopeP = info.b(1)
        aP = info.b(3)
        bP = info.b(2)
    elseif strcmp(model,'ambigNriskFixSlope')
        slopeP = -1;
        aP = info.b(2)
        bP = info.b(1)
    end
    r2P = info.r2
 
    % separate fir for neg
    choiceN = choice_orig(find(vA<0)); %change from choice to choice_orig (Lital)
    vN = vA(find(vA<0));
    pN = pA(find(vA<0));
    AN = AL(find(vA<0));
    vFN = fixed_valueN * ones(length(choiceN),1);
    pFN = fixed_prob * ones(length(choiceN),1);
    
    [info,p] = fit_ambigNrisk_model(~choiceN,-vFN,-vN,pFN,pN,AN,model,b0,base);

    if strcmp(model,'ambigNrisk')
        slopeN = info.b(1)
        aN = info.b(3)
        bN = info.b(2)
    elseif strcmp(model,'ambigNriskFixSlope')
        slopeN = -1
        aN = info.b(2)
        bN = info.b(1)
    end
    r2N = info.r2
    
    % create SV vector to be a predictor
    for i = 1:120
        if vA(i+120) > 0
            SVs(i) = (pA(i+120) - bP * AL(i+120)/2) * vA(i+120)^aP;
        else
            SVs(i) = (pA(i+120) - bN * AL(i+120)/2) * vA(i+120)^aN;
        end
    end
    
    
    % make four prt for each subject
    prt_tmp1 = xff([path 'V3_PN1_dsprsp.prt']); %load prt file
    prt_tmp2 = xff([path 'V3_PN2_dsprsp.prt']); %load prt file
    prt_tmp3 = xff([path 'V3_PN3_dsprsp.prt']); %load prt file
    prt_tmp4 = xff([path 'V3_PN4_dsprsp.prt']); %load prt file
 %keyboard   
    prt_tmp1.FileVersion=3;
    prt_tmp1.ParametricWeights = 1;
    
    prt_tmp1.Cond(1).Weights=SVs([1 4 9:11 13:14 17:18 20 23 25:28 30]);
    prt_tmp1.Cond(3).Weights=SVs([2:3 5:8 12 15:16 19 21:22 24 29]);
    prt_tmp2.Cond(1).Weights=SVs([34 36 38:39 41:42 44:46 48:50 55:56]);
    prt_tmp2.Cond(3).Weights=SVs([31:33 35 37 40 43 47 51:54 57:60]);
    prt_tmp1.Cond(2).Weights=SVs([1 4 9:11 13:14 17:18 20 23 25:28 30]);
    prt_tmp1.Cond(4).Weights=SVs([2:3 5:8 12 15:16 19 21:22 24 29]);
    prt_tmp2.Cond(2).Weights=SVs([34 36 38:39 41:42 44:46 48:50 55:56]);
    prt_tmp2.Cond(4).Weights=SVs([31:33 35 37 40 43 47 51:54 57:60]);
    
    prt_tmp3.Cond(5).Weights=SVs([61 63 65:66 72:73 75:76 79:80 85 87:88]);
    prt_tmp3.Cond(7).Weights=SVs([62 64 67:71 74 77:78 81:84 86 89:90]);
    prt_tmp4.Cond(5).Weights=SVs([92 94:95 97:100 103 106:107 110 112 114:117 119]);
    prt_tmp4.Cond(7).Weights=SVs([91 93 96 101:102 104:105 108:109 111 113 118 120]);
    prt_tmp3.Cond(6).Weights=SVs([61 63 65:66 72:73 75:76 79:80 85 87:88]);
    prt_tmp3.Cond(8).Weights=SVs([62 64 67:71 74 77:78 81:84 86 89:90]);
    prt_tmp4.Cond(6).Weights=SVs([92 94:95 97:100 103 106:107 110 112 114:117 119]);
    prt_tmp4.Cond(8).Weights=SVs([91 93 96 101:102 104:105 108:109 111 113 118 120]);
  
    
    prt_tmp1.SaveAs([path subject '_PN1_SVdsprsp.prt']);
    prt_tmp2.FileVersion=3;
    prt_tmp2.ParametricWeights = 1;
    prt_tmp2.SaveAs([path subject '_PN2_SVdsprsp.prt']);
    prt_tmp3.FileVersion=3;
    prt_tmp3.ParametricWeights = 1;
    prt_tmp3.SaveAs([path subject '_PN3_SVdsprsp.prt']);
    prt_tmp4.FileVersion=3;
    prt_tmp4.ParametricWeights = 1;
    prt_tmp4.SaveAs([path subject '_PN4_SVdsprsp.prt']);
    
    % create sdm file:
    sdmfile1 = prt_tmp1.CreateSDM(struct('nvol',245,'prtr',2000,'rcond',[]));
    sdmfile2 = prt_tmp2.CreateSDM(struct('nvol',245,'prtr',2000,'rcond',[]));
    sdmfile3 = prt_tmp3.CreateSDM(struct('nvol',245,'prtr',2000,'rcond',[]));
    sdmfile4 = prt_tmp4.CreateSDM(struct('nvol',245,'prtr',2000,'rcond',[]));
    
    %for c=4:9
    %    sdmfile.PredictorColors(c,:)=[255 255 255];
    %    sdmfile.PredictorNames(c)={['MC' num2str(c)]};
    %end
       
   % sdmfile.SDMMatrix=[sdmfile.SDMMatrix MC_tmp.sub(q).MC];
    %sdmfile.NrOfPredictors=sdmfile.NrOfPredictors+6;
    sdmfile1.SaveAs([path subject 'svbddsprsp_1.sdm']);
    sdmfile2.SaveAs([path subject 'svbddsprsp_2.sdm']);
    sdmfile3.SaveAs([path subject 'svbddsprsp_3.sdm']);
    sdmfile4.SaveAs([path subject 'svbddsprsp_4.sdm']);

  end
  