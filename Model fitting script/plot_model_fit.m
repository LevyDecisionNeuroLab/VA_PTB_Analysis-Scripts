% Plot choices and model fit
clearvars
close all


subjects = [1072];
fitparwave = 'Behavior data fitpar_08120119';

root = 'D:\Ruonan\Projects in the lab\VA_RA_PTB\Analysis Ruonan'; % Need to change if doing analysis in different folders
fitpar_out_path = fullfile(root,'Fitpar files', fitparwave);

func_path = fullfile(root,'VA_PTB_Analysis-Scripts', 'Model fitting script');
addpath(func_path)
cd(fitpar_out_path)

fixed_valueP = 5;
fixed_valueN = -5;
fixed_prob = 1;
valueP = [5 6 7 8 10 12 14 16 19 23 27 31 37 44 52 61 73 86 101 120];
prob = [0.25; 0.5; 0.75];
ambig = [0.24; 0.5; 0.74];
valueN = [-5 -6 -7 -8 -10 -12 -14 -16 -19 -23 -27 -31 -37 -44 -52 -61 -73 -86 -101 -120];


for subj_idx = 1:length(subjects)
    
    subjectNum = subjects(subj_idx);

    % subjectNum = 1210;
    fname = sprintf('RA_%s_%d_fitpar.mat', 'GAINS', subjectNum);
    load(fname); % produces variable 'Data'

    riskyChoicesP = Data.riskyChoices;
    ambigChoicesP = Data.ambigChoices;

    aP = Data.alpha_uncstr;
    bP = Data.beta_uncstr;
    slopeP = Data.gamma_uncstr;
        
    fname = sprintf('RA_%s_%d_fitpar.mat', 'LOSS', subjectNum);
    load(fname); % produces variable 'Data'

    riskyChoicesN = Data.riskyChoices;
    ambigChoicesN = Data.ambigChoices;

    aN = Data.alpha_uncstr;
    bN = Data.beta_uncstr;
    slopeN = Data.gamma_uncstr;        

    %% Graph
    colors =   [255 0 0;
    180 0 0;
    130 0 0;
    52 181 233;
    7 137 247;
    3 85 155;
    ]/255;

    figure
    counter=5;
    for i=1:3
        subplot(3,2,counter)
        plot(valueP,ambigChoicesP(i,:),'--*','Color',colors(3+i,:))
        legend([num2str(ambig(i)) ' ambiguity'])
        if counter==1
            title(['Beta = ' num2str(bP)])
        end
        ylabel('Chose Lottery')
        if counter==5
        xlabel('Lottery Value ($)')
        end
        counter=counter-2;
    end

    counter=2;
    for i=1:3
        subplot(3,2,counter)
        plot(valueP,riskyChoicesP(i,:),'--*','Color',colors(i,:))
        legend([num2str(prob(i)) ' probability'])
        if counter==2
            title(['Alpha = ' num2str(aP)])
        end
            if counter==6
        xlabel('Lottery Value ($)')
            end
        counter=counter+2;
    end

    set(gcf,'color','w');
    figName=['RA_GAINS_' num2str(subjectNum) '_fitpar'];
     exportfig(gcf,figName,'Format','eps','bounds','tight','color','rgb','LockAxes',1,'FontMode','scaled','FontSize',1,'Width',4,'Height',2,'Reference',gca);

    %% figure with fitted logistic line, only for gain
    xP = 0:0.1:max(valueP);
    uFP = fixed_prob * (fixed_valueP).^aP;
    xN = 0:0.1:max(valueN);
    uFN = fixed_prob * (-fixed_valueN).^aN;

    figure

    % risk pos
    for i = 1 :length(prob)
        plot(valueP,riskyChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
            ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
          hold on
        % logistic function
        uA = prob(i) * xP.^aP;
        p = 1 ./ (1 + exp(slopeP*(uA-uFP)));

        plot(xP,p,'-','LineWidth',4,'Color',colors(i,:));
        axis([0 130 0 1])
        set(gca, 'ytick', [0 0.25 0.5 0.75 1])
        set(gca,'xtick', [0 20  40  60  80  100 120])
        set(gca,'FontSize',25)
        set(gca,'LineWidth',3)
        set(gca, 'Box','off')


    end
    title(['  alpha gain = ' num2str(aP)]);

    figure
    % ambig pos
    for i = 1:length(ambig)
        plot(valueP,ambigChoicesP(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
         hold on

        % logistic function
        uA = (0.5 - bP.*ambig(i)./2) * xP.^aP;
        p = 1 ./ (1 + exp(slopeP*(uA-uFP)));


        plot(xP,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
        axis([0 130 0 1])
        set(gca, 'ytick', [0 0.25 0.5 0.75 1])
        set(gca,'xtick', [0 20  40  60  80  100 120])
        set(gca,'FontSize',25)
        set(gca,'LineWidth',3)
        set(gca, 'Box','off')

    end
    title([ '  beta gain = ' num2str(bP)]);

    %     % risk neg
    figure
    for i = 1:length(prob)
        plot(valueN,riskyChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1])...
            ,'MarkerFaceColor',colors(i,:),'Color',colors(i,:));
        hold on
%         legend('0.25', '0.25', '0.5', '0.5', '0.75', '0.75')
        legend('Location', 'northwest')
        
        % logistic function
        uA = prob(i) * (xP).^aN;
        p = 1 ./ (1 + exp(slopeN*(uA-uFN)));

        plot(-xP,p,'-','LineWidth',2,'Color',colors(i,:));
        axis([-130 0 0 1])
        set(gca, 'ytick', [0 0.25 0.5 0.75 1])
        set(gca,'xtick', [-120 -100 -80 -60 -40 -20 0])
        set(gca,'FontSize',25)
        set(gca,'LineWidth',3)
        set(gca, 'Box','off')

    end

    title([char(subjectNum) '  alpha loss = ' num2str(aN)]);


    % ambig neg
    figure
    for i = 1:length(ambig)
        plot(valueN,ambigChoicesN(i,:),'o','MarkerSize',8,'MarkerEdgeColor',colors([1 1 1]),'MarkerFaceColor',colors(length(prob)+i,:));
          hold on
        legend('Location', 'northwest')

        % logistic function
        uA = (0.5 - bN.*ambig(i)./2) * (xP).^aN;
        p = 1 ./ (1 + exp(slopeN*(uA-uFN)));


        plot(-xP,p,'-','LineWidth',2,'Color',colors(length(prob)+i,:));
        axis([-130 0 0 1])
        set(gca, 'ytick', [0 0.25 0.5 0.75 1])
        set(gca,'xtick', [-120 -100 -80 -60 -40 -20 0])
        set(gca,'FontSize',25)
        set(gca,'LineWidth',3)
        set(gca, 'Box','off')

    end
    title([char(subjectNum) '  beta loss = ' num2str(bN)]);    

end