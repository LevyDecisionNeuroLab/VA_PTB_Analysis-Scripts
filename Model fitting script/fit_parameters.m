% NOTE: Requires MATLAB optim library
% notice to change the constrained/unconstrained function, and change the fitpat.mat file name to constrained/unconstrained

clearvars
close all

%% Input set up
fitparwave = 'Behavior data fitpar_020519';
search = 'grid'; % which method for searching optimal parameters
model = 'ambigNrisk'; % which utility function
isconstrained = 2; % if use constrained fitting. 0-unconstrained, 1-constrained, 2-both
isdivided = 1; % if fit model to data for each day. 0-fit model on all data, 1-fit model on each day's data should get two values per subject for each parameter

%% Set up loading + subject selection
% TODO: Maybe grab & save condition somewhere?

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
data_path = fullfile(root, 'Behavior data of PTB log/'); % root of folders is sufficient
fitpar_out_path = fullfile(root,'Fitpar files', fitparwave);
%graph_out_path  = fullfile(root, 'ChoiceGraphs/');

if exist(fitpar_out_path)==0
    mkdir(fullfile(root,'Fitpar files'),fitparwave)
end

addpath(genpath(data_path)); % generate path for all the subject data folder

subjects = getSubjectsInDir(data_path, 'subj');
exclude = [77 1218]; 
% 76-81, PRE-MB. 
% 1218: missing many trials and did not complete study. 
% 77, 95 incomplete data
% need to do 95, incomplete data
% 1269 GL/GL

subjects = subjects(~ismember(subjects, exclude));
% subjects = [95];
idx95 = find(subjects == 95);

for subj_idx = idx95+1:length(subjects)
%     domains = {'LOSS'};
    domains = {'GAINS', 'LOSS'};

  for domain_idx = 1:length(domains)
    subjectNum = subjects(subj_idx);
    domain = domains{domain_idx};
    
%     subjectNum = 1210;
%     domain = 'GAINS';


    fname = sprintf('RA_%s_%d.mat', domain, subjectNum);
    load(fname) % produces variable `Data`
    
    %% Refine variables

    % Exclude non-responses and test questions (where lottery value < fixed value)
    % subj 95 has incomplete data in LOSS; ToDo: change the logic to detect
    % incomplete data
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        choiceDone = zeros(1, 124);
        choiceDone(1:length(Data.choice)) = Data.choice;
        include_indices_all = and(choiceDone ~=0, Data.vals' ~= 4);
        idx_only4_all = and(choiceDone ~=0, Data.vals' == 4);
    else
        include_indices_all = and(Data.choice ~= 0, Data.vals' ~= 4);
        idx_only4_all = and(Data.choice ~= 0, Data.vals' == 4);
    end
        
    if subjectNum == 95 && strcmp(domain, 'LOSS')
        choice_all = choiceDone;
    else
        choice_all = Data.choice;
    end
       
    values_all = Data.vals;
    ambigs_all = Data.ambigs;
    probs_all  = Data.probs;
    
    %% Divide data and fit data for each day separately
    % this should be done before cleaning data, because the trials with
    % missing responses will be exlcuded after data cleaning
%     ntrials_day = length(values_all)/2;
    ntrials_day = 62;
    if isdivided == 1
        for day = 1:2
            % select trials for each day
            choice_bothday(day,:) = choice_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            values_bothday(:,day) = values_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            ambigs_bothday(:,day) = ambigs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            probs_bothday(:,day) = probs_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            include_indices_bothday(day,:) = include_indices_all((day-1) * ntrials_day + 1 : day * ntrials_day);
            idx_only4_bothday(day,:) = idx_only4_all((day-1) * ntrials_day + 1 : day * ntrials_day);
        end
    elseif isdivided == 0
            choice_bothday = choice_all;
            values_bothday = values_all;
            ambigs_bothday = ambigs_all;
            probs_bothday = probs_all;
            include_indices_bothday = include_indices_all;
            idx_only4_bothday = idx_only4_all;
    end
       
    % clean and fit data for each day
    for day = 1 : size(values_bothday, 2)        
        %% Clean data 
        
        % exclude trials with value = 4 and with no resposne
        choice = choice_bothday(day,include_indices_bothday(day,:));
        values = values_bothday(include_indices_bothday(day,:)',day);
        ambigs = ambigs_bothday(include_indices_bothday(day,:)',day);
        probs = probs_bothday(include_indices_bothday(day,:)',day);
        
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
        
        choice4 = choice_bothday(day, idx_only4_bothday(day,:));
        values4 = values_bothday(idx_only4_bothday(day,:)', day);
        ambigs4 = ambigs_bothday(idx_only4_bothday(day,:)', day);
        probs4  = probs_bothday(idx_only4_bothday(day,:)', day);

        if Data.refSide == 2
            choice4(choice4 == 2) = 0;
            choice4(choice4 == 1) = 1;
        elseif Data.refSide == 1 % Careful: rerunning this part will make all choices 0
            choice4(choice4 == 1) = 0;
            choice4(choice4 == 2) = 1;
        end

        choice_prob_4 = sum(choice4)/length(choice4);

        %% Prepare variables for model fitting

        fixed_valueP = 5; % Value of fixed reward
        fixed_prob = 1;   % prb of fixed reward 
        ambig = unique(ambigs(ambigs > 0)); % All non-zero ambiguity levels 
        prob = unique(probs); % All probability levels
        base = 0; % ? % TODO: Find out meaning -- undescribed in function. RJ-another parm in the model. Not used.

        if strcmp(search, 'grid')
        % grid search
        % range of each parameter
            if strcmp(model,'ambigNrisk')
                slopeRange = -4:0.2:1;
                bRange = -2:0.2:2;
                aRange = 0:0.2:4;
            else
                slopeRange = -4:0.2:1;
                bRange = -2:0.2:2;
                aRange = -2:0.2:2;
            end
            % three dimenstions
            [b1, b2, b3] = ndgrid(slopeRange, bRange, aRange);
            % all posibile combinatinos of three parameters
            b0 = [b1(:) b2(:) b3(:)];
        elseif strcmp(search,'single')
            % single search
            b0 = [-1 0.5 0.5]; % starting point of the search process, [gamma, beta, alpha]
        elseif strcmp(search, 'random')
            % independently randomized multiple search starting points
            bstart = [-1 0 1]; % starting point of the search process, [gamma, beta, alpha]
            itr = 100; % 100 iteration of starting point
            b0 = zeros(itr,length(bstart));
            for i = 1:itr
                % gamma: negative, around -1, so (-2,0)
                % beta: [-1,1] possible to be larger than 1?
                % alpha: (0,4)
                b0(i,:) = bstart + [-1+2*rand(1) -1+2*rand(1) -1+2*rand(1)]; % randomize search starting point, slope, beta, alpha
            end
        end


        refVal = fixed_valueP * ones(length(choice), 1);
        refProb = fixed_prob  * ones(length(choice), 1);        
        
        %% Fit model

        % Two versions of function, calculate both the unconstrained and constrained fittings:
        % fit_ambgiNrisk_model: unconstrained
        if isconstrained == 0 || isconstrained == 2
            [info_uncstr, p_uncstr] = fit_ambigNrisk_model(choice, ...
                refVal', ...
                values', ...
                refProb', ...
                probs', ...
                ambigs', ...
                model, ...
                b0, ...
                base);

            slope_uncstr = info_uncstr.b(1);
            a_uncstr = info_uncstr.b(3);
            b_uncstr = info_uncstr.b(2);
            r2_uncstr = info_uncstr.r2;

            disp(['Subject ' num2str(subjectNum) ' unconstrained fitting completed'])

        end

        if isconstrained == 1 || isconstrained == 2
            % fit_ambigNrisk_model_Constrained: constrained on alpha and beta    
            [info_cstr, p_cstr] = fit_ambigNrisk_model_Constrained(choice, ...
                refVal', ...
                values', ...
                refProb', ...
                probs', ...
                ambigs', ...
                model, ...
                b0, ...
                base);

            slope_cstr = info_cstr.b(1);
            a_cstr = info_cstr.b(3);
            b_cstr = info_cstr.b(2);
            r2_cstr = info_cstr.r2;

            disp(['Subject ' num2str(subjectNum) ' constrained fitting completed'])
        end
        
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
        valueP = unique(values_all(ambigs_all > 0 & values_all ~= 4)); % each lottery payoff value under ambiguity
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

        % Create riskyChoicesP
        % Risk levels by payoff values
        valueP = unique(values_all(ambigs_all == 0 & values_all ~= 4));
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

        % Creat risky/ambig choiecs by level (nonparametric), excluding the value 5
        for i=1:length(prob)
            riskyChoices_byLevel(1,i) = nanmean(riskyChoicesP(i,2:length(riskyChoicesP)));
        end
        for i=1:length(ambig)
            ambigChoices_byLevel(1,i) = nanmean(ambigChoicesP(i,2:length(ambigChoicesP)));
        end        
        
        
        %% Graph
%         colors =   [255 0 0;
%         180 0 0;
%         130 0 0;
%         52 181 233;
%         7 137 247;
%         3 85 155;
%         ]/255;
% 
%         figure
%         counter=5;
%         for i=1:3
%             subplot(3,2,counter)
%             plot(valueP,ambigChoicesP(i,:),'--*','Color',colors(3+i,:))
%             legend([num2str(ambig(i)) ' ambiguity'])
%             if counter==1
%                 title(['Beta = ' num2str(bP)])
%             end
%             ylabel('Chose Lottery')
%             if counter==5
%             xlabel('Lottery Value ($)')
%             end
%             counter=counter-2;
%         end
% 
%         counter=2;
%         for i=1:3
%             subplot(3,2,counter)
%             plot(valueP,riskyChoicesP(i,:),'--*','Color',colors(i,:))
%             legend([num2str(prob(i)) ' probability'])
%             if counter==2
%                 title(['Alpha = ' num2str(aP)])
%             end
%                 if counter==6
%             xlabel('Lottery Value ($)')
%                 end
%             counter=counter+2;
%         end
% 
%         set(gcf,'color','w');
%         figName=['RA_GAINS_' num2str(subjectNum) '_fitpar'];
%          exportfig(gcf,figName,'Format','eps','bounds','tight','color','rgb','LockAxes',1,'FontMode','scaled','FontSize',1,'Width',4,'Height',2,'Reference',gca);
% 
%        %% figure with fitted logistic line, only for gain
%         xP = 0:0.1:max(valueP);
%         uFP = fixed_prob * (fixed_valueP).^aP;
% 
%        figure
% 
%         % risk pos
%         for i = 1 :length(prob)
%             plot(valueP,riskyChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
%                 ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
%               hold on
%             % logistic function
%             uA = prob(i) * xP.^aP;
%             p = 1 ./ (1 + exp(slopeP*(uA-uFP)));
% 
%             plot(xP,p,'-','LineWidth',4,'Color',colors(i,:));
%             axis([0 150 0 1])
%             set(gca, 'ytick', [0 0.5 1])
%             set(gca,'xtick', [0 20  40  60  80  100 120])
%             set(gca,'FontSize',25)
%             set(gca,'LineWidth',3)
%             set(gca, 'Box','off')
% 
% 
%         end
%         title(['  alpha gain = ' num2str(aP)]);
% 
%         figure
%         % ambig pos
%         for i = 1:length(ambig)
%             plot(valueP,ambigChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
%              hold on
%  
%             % logistic function
%             uA = (0.5 - bP.*ambig(i)./2) * xP.^aP;
%             p = 1 ./ (1 + exp(slopeP*(uA-uFP)));
% 
% 
%             plot(xP,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
%             set(gca, 'ytick', [0 0.5 1])
%             set(gca,'xtick', [0 20  40  60  80  100 120])
%             set(gca,'FontSize',25)
%             set(gca,'LineWidth',3)
%             set(gca, 'Box','off')
% 
%         end
%         title([ '  beta gain = ' num2str(bP)]);
% 
%         %     % risk neg
%         subplot(2,2,2)
%             for i = 1:length(prob)
%             plot(valueN,riskyChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
%                 ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
%             hold on
%     
%             % logistic function
%             uA = -prob(i) * (-xN).^aN;
%             p = 1 ./ (1 + exp(slopeN*(uA-uFN)));
%     
%             plot(xN,p,'-','LineWidth',2,'Color',colors(i,:));
%     
%             end
%         title([char(subject) '  alpha loss = ' num2str(aN)]);
%             
%       
%         % ambig neg
%         subplot(2,2,4)
%         for i = 1:length(ambig)
%             plot(valueN,ambigChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
%               hold on
%     
%             % logistic function
%             uA = -(0.5 - bN.*ambig(i)./2) * (-xN).^aN;
%             p = 1 ./ (1 + exp(slopeN*(uA-uFN)));
%     
%     
%             plot(xN,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
%     
%         end
%         title([char(subject) '  beta loss = ' num2str(bN)]);       
        
        %% Save generated values
        if isdivided == 1   
            
            if day == 1
                
                Data.day1.riskyChoices = riskyChoicesP;
                Data.day1.ambigChoices = ambigChoicesP;

                Data.day1.choiceProb4 = choice_prob_4;

                if isconstrained == 0 || isconstrained == 2
                    Data.day1.MLE_uncstr = info_uncstr;
                    Data.day1.alpha_uncstr = info_uncstr.b(3);
                    Data.day1.beta_uncstr = info_uncstr.b(2);
                    Data.day1.gamma_uncstr = info_uncstr.b(1);
                    Data.day1.r2_uncstr = info_uncstr.r2;
                end

                if isconstrained == 1 || isconstrained == 2
                    Data.day1.MLE_cstr = info_cstr;
                    Data.day1.alpha_cstr = info_cstr.b(3);
                    Data.day1.beta_cstr = info_cstr.b(2);
                    Data.day1.gamma_cstr = info_cstr.b(1);
                    Data.day1.r2_cstr = info_cstr.r2;
                end

                Data.day1.riskyChoices_byLevel= riskyChoices_byLevel;
                Data.day1.ambigChoices_byLevel=ambigChoices_byLevel;

            elseif day == 2
                
                Data.day2.riskyChoices = riskyChoicesP;
                Data.day2.ambigChoices = ambigChoicesP;

                Data.day2.choiceProb4 = choice_prob_4;

                if isconstrained == 0 || isconstrained == 2
                    Data.day2.MLE_uncstr = info_uncstr;
                    Data.day2.alpha_uncstr = info_uncstr.b(3);
                    Data.day2.beta_uncstr = info_uncstr.b(2);
                    Data.day2.gamma_uncstr = info_uncstr.b(1);
                    Data.day2.r2_uncstr = info_uncstr.r2;
                end

                if isconstrained == 1 || isconstrained == 2
                    Data.day2.MLE_cstr = info_cstr;
                    Data.day2.alpha_cstr = info_cstr.b(3);
                    Data.day2.beta_cstr = info_cstr.b(2);
                    Data.day2.gamma_cstr = info_cstr.b(1);
                    Data.day2.r2_cstr = info_cstr.r2;
                end

                Data.day2.riskyChoices_byLevel= riskyChoices_byLevel;
                Data.day2.ambigChoices_byLevel=ambigChoices_byLevel;
            end
            
        elseif isdivided == 0
            
            Data.riskyChoices = riskyChoicesP;
            Data.ambigChoices = ambigChoicesP;

            Data.choiceProb4 = choice_prob_4;

            if isconstrained == 0 || isconstrained == 2
                Data.MLE_uncstr = info_uncstr;
                Data.alpha_uncstr = info_uncstr.b(3);
                Data.beta_uncstr = info_uncstr.b(2);
                Data.gamma_uncstr = info_uncstr.b(1);
                Data.r2_uncstr = info_uncstr.r2;
            end

            if isconstrained == 1 || isconstrained == 2
                Data.MLE_cstr = info_cstr;
                Data.alpha_cstr = info_cstr.b(3);
                Data.beta_cstr = info_cstr.b(2);
                Data.gamma_cstr = info_cstr.b(1);
                Data.r2_cstr = info_cstr.r2;
            end

            Data.riskyChoices_byLevel= riskyChoices_byLevel;
            Data.ambigChoices_byLevel=ambigChoices_byLevel;  

        end
        save(fullfile(fitpar_out_path, ['RA_' domain '_' num2str(subjectNum) '_fitpar.mat']), 'Data')
  
    end
  end
end





