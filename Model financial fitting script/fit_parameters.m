% NOTE: Requires MATLAB optim library
% notice to change the constrained/unconstrained function, and change the fitpat.mat file name to constrained/unconstrained

%% Set up loading + subject selection
% TODO: Maybe grab & save condition somewhere?
clear all
close all

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
% root = 'Z:\Levy_Lab\Data_fMRI\VA_fMRI_PTB';
% root = '~/Box Sync/VA_RA_PTB/';
data_path = fullfile(root, 'Behavior data of PTB log/'); % root of folders is sufficient
% data_path = fullfile(root, 'Behavior/'); % root of folders is sufficient
fitpar_out_path = fullfile(root, 'Behavior data financial fitpar_011717/');
%graph_out_path  = fullfile(root, 'ChoiceGraphs/');

addpath(genpath(data_path)); % generate path for all the subject data folder

subjects = getSubjectsInDir(data_path, 'subj');
exclude = [76 77 78 79 80 81 95 1218]; % TEMPORARY: subjects incomplete data (that the script is not ready for)

subjects = subjects(~ismember(subjects, exclude));

% subjects = [1072];

for subj_idx = 1:length(subjects)
  domains = {'GAINS', 'LOSS'};

  for domain_idx = 1:length(domains)
    subjectNum = subjects(subj_idx);
    domain = domains{domain_idx};
    
    fname = sprintf('RA_%s_%d.mat', domain, subjectNum);
    load(fname) % produces variable `Data`
    
    %% Refine variables

    % Exclude non-responses and test questions (where lottery value < fixed value)
    include_indices = and(Data.choice ~= 0, Data.vals' ~= 4);

    choice = Data.choice(include_indices);
    values = Data.vals(include_indices);
    ambigs = Data.ambigs(include_indices);
    probs  = Data.probs(include_indices);
    
    % Side with lottery is counterbalanced across subjects 
    % -> code 0 as reference choice, 1 as lottery choice
    % TODO: Double-check this is so? - This is true(RJ)
    % TODO: Save in a different variable?
    % if sum(choice == 2) > 0 % Only if choice has not been recoded yet. RJ-Not necessary
    % RJ-If subject do not press 2 at all, the above if condition is problematic
      if Data.refSide == 2
          choice(choice == 2) = 0;
          choice(choice == 1) = 1;
      elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
          choice(choice == 1) = 0;
          choice(choice == 2) = 1;
      end
    % end
    
    % choice data for $4 only, for rationality check only
    idx_only4 = and(Data.choice ~= 0, Data.vals' == 4);
    choice4 = Data.choice(idx_only4);
    values4 = Data.vals(idx_only4);
    ambigs4 = Data.ambigs(idx_only4);
    probs4  = Data.probs(idx_only4);
    
    if Data.refSide == 2
        choice4(choice4 == 2) = 0;
        choice4(choice4 == 1) = 1;
    elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
        choice4(choice4 == 1) = 0;
        choice4(choice4 == 2) = 1;
    end
    
    choice_prob_4 = sum(choice4)/length(choice4);
    
    %% Prepare variables for model fitting & fit the model

    fixed_valueP = 5; % Value of fixed reward
    fixed_prob = 1;   % prb of fixed reward 
    ambig = unique(ambigs(ambigs > 0)); % All non-zero ambiguity levels 
    prob = unique(probs); % All probability levels

    model = 'financial';
    b0 = [-1 0 0]'; % ? % TODO: Find out meaning -- undescribed in function
    refVal = fixed_valueP * ones(length(choice), 1);
    refProb = fixed_prob  * ones(length(choice), 1);

    % TODO: Check that the calculation in the called function makes sense
    % Two versions of function:
    %       fit_ambgiNrisk_model: unconstrained
    %       fit_ambigNrisk_model_Constrained: constrained on alpha and beta
    [info, p] = fit_ambigNrisk_model(choice, ...
        refVal', ...
        values', ...
        refProb', ...
        probs', ...
        ambigs', ...
        model, ...
        b0);

    slopeP = info.b(1);
    k1 = info.b(3);
    k2 = info.b(2);
    r2P = info.r2;
    
    %% Create choice matrices

    % One matrix per condition. Matrix values are binary (0 for sure
    % choice, 1 for lottery). Matrix dimensions are prob/ambig-level
    % x payoff values. Used for graphing and some Excel exports.

    % Inputs: 
    %  Data
    %   .values, .ambigs, .probs, .choices (filtered by include_indices and transformed)
    %  ambig, prob (which are subsets of ambigs and probs, ran through `unique`)
    %
    % Outputs:
    %  ambigChoicesP
    %  riskyChoicesP
    %
    % Side-effects:
    %  one graph generated per-subject-domain
    %  .ambigChoicesP and .riskyChoicesP saved into `fitpar` file

    % Ambiguity levels by payoff values
    valueP = unique(values(ambigs > 0)); % each lottery payoff value under ambiguity
    ambigChoicesP = zeros(length(ambig), length(valueP)); % each row an ambiguity level
    for i = 1:length(ambig)
        for j = 1:length(valueP)
            selection = find(ambigs == ambig(i) & values == valueP(j));
            if ~isempty(selection)
                ambigChoicesP(i, j) = choice(selection);
            else
                ambigChoicesP(i, j) = NaN;
            end
        end
    end
    
    %% Create riskyChoicesP
    % Risk levels by payoff values
    valueP = unique(values(ambigs == 0));
    riskyChoicesP = zeros(length(prob), length(valueP));
    for i = 1:length(prob)
        for j = 1:length(valueP)
            selection = find(probs == prob(i) & values == valueP(j) & ambigs == 0);
            if ~isempty(selection)
                riskyChoicesP(i, j) = choice(selection);
            else
                riskyChoicesP(i, j) = NaN;
            end
        end
    end
    
    %% Creat risky/ambig choiecs by level (nonparametric), excluding the value 5
    for i=1:length(prob)
        riskyChoices_byLevel(1,i) = nanmean(riskyChoicesP(i,2:length(riskyChoicesP)));
    end
    for i=1:length(ambig)
        ambigChoices_byLevel(1,i) = nanmean(ambigChoicesP(i,2:length(ambigChoicesP)));
    end
    
  %% Graph
%    colors =   [255 0 0;
%     180 0 0;
%     130 0 0;
%     52 181 233;
%     7 137 247;
%     3 85 155;
%     ]/255;
% 
%     figure
%     counter=5;
%     for i=1:3
%         subplot(3,2,counter)
%         plot(valueP,ambigChoicesP(i,:),'--*','Color',colors(3+i,:))
%         legend([num2str(ambig(i)) ' ambiguity'])
%         if counter==1
%             title(['Beta = ' num2str(bP)])
%         end
%         ylabel('Chose Lottery')
%         if counter==5
%         xlabel('Lottery Value ($)')
%         end
%         counter=counter-2;
%     end
% 
%     counter=2;
%     for i=1:3
%         subplot(3,2,counter)
%         plot(valueP,riskyChoicesP(i,:),'--*','Color',colors(i,:))
%         legend([num2str(prob(i)) ' probability'])
%         if counter==2
%             title(['Alpha = ' num2str(aP)])
%         end
%             if counter==6
%         xlabel('Lottery Value ($)')
%             end
%         counter=counter+2;
%     end
% 
%     set(gcf,'color','w');
%     figName=['RA_GAINS_' num2str(subjectNum) '_fitpar'];
%      exportfig(gcf,figName,'Format','eps','bounds','tight','color','rgb','LockAxes',1,'FontMode','scaled','FontSize',1,'Width',4,'Height',2,'Reference',gca);
% 
%    %% figure with fitted logistic line, only for gain
%     xP = 0:0.1:max(valueP);
%     uFP = fixed_prob * (fixed_valueP).^aP;
%      
%    figure
%      
%     % risk pos
%     for i = 1 :length(prob)
%         plot(valueP,riskyChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
%             ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
%           hold on
%         % logistic function
%         uA = prob(i) * xP.^aP;
%         p = 1 ./ (1 + exp(slopeP*(uA-uFP)));
% 
%         plot(xP,p,'-','LineWidth',4,'Color',colors(i,:));
%         axis([0 150 0 1])
%         set(gca, 'ytick', [0 0.5 1])
%         set(gca,'xtick', [0 20  40  60  80  100 120])
%         set(gca,'FontSize',25)
%         set(gca,'LineWidth',3)
%         set(gca, 'Box','off')
% 
% 
%     end
%     title(['  alpha gain = ' num2str(aP)]);
%     
%     figure
%     % ambig pos
%     for i = 1:length(ambig)
%         plot(valueP,ambigChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
%          hold on
% % 
%         % logistic function
%         uA = (0.5 - bP.*ambig(i)./2) * xP.^aP;
%         p = 1 ./ (1 + exp(slopeP*(uA-uFP)));
% 
% 
%         plot(xP,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
%         set(gca, 'ytick', [0 0.5 1])
%         set(gca,'xtick', [0 20  40  60  80  100 120])
%         set(gca,'FontSize',25)
%         set(gca,'LineWidth',3)
%         set(gca, 'Box','off')
% 
%     end
%     title([ '  beta gain = ' num2str(bP)]);
%     
%     %     % risk neg
% %     subplot(2,2,2)
% %         for i = 1:length(prob)
% %         plot(valueN,riskyChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
% %             ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
% %         hold on
% % 
% %         % logistic function
% %         uA = -prob(i) * (-xN).^aN;
% %         p = 1 ./ (1 + exp(slopeN*(uA-uFN)));
% % 
% %         plot(xN,p,'-','LineWidth',2,'Color',colors(i,:));
% % 
% %         end
% %     title([char(subject) '  alpha loss = ' num2str(aN)]);
% %         
% %   
% %     % ambig neg
% %     subplot(2,2,4)
% %     for i = 1:length(ambig)
% %         plot(valueN,ambigChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
% %           hold on
% % 
% %         % logistic function
% %         uA = -(0.5 - bN.*ambig(i)./2) * (-xN).^aN;
% %         p = 1 ./ (1 + exp(slopeN*(uA-uFN)));
% % 
% % 
% %         plot(xN,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
% % 
% %     end
% %     title([char(subject) '  beta loss = ' num2str(bN)]);
     %% Save generated values
    Data.riskyChoices = riskyChoicesP;
    Data.ambigChoices = ambigChoicesP;
    
    Data.choiceProb4 = choice_prob_4;

    Data.MLE = info;
    Data.k1 = info.b(3);
    Data.k2 = info.b(2);
    Data.gamma = info.b(1);
    
    Data.riskyChoices_byLevel= riskyChoices_byLevel;
    Data.ambigChoices_byLevel=ambigChoices_byLevel;

     save(fullfile(fitpar_out_path, ['RA_' domain '_' num2str(subjectNum) '_financial_fitpar_unconstrained.mat']), 'Data')
  end
end





