path = 'C:\Documents and Settings\lr382\Desktop\Lital\Risk-young-adults\fmri data\V2\matlab\';

PNsubjects = {'20003', '20005', '20007', '20009', '20013', '20015','2182'};
%'2130','2175','2180','2182',

  for s = 1:length(PNsubjects)
    subject = PNsubjects{s};
    for run = 1:4
        sdm_name = [num2str(subject) 'sv_' num2str(run) '.sdm'];
        sdm = xff([path sdm_name]);
        sdm.NrOfPredictors = 9;
        sdm.FirstConfoundPredictor = 9;
        sdm.PredictorNames = {'Risk-Gains', 'Risk-Gains par',  'Ambig-Gains', 'Ambig-Gains par', 'Risk-Losses', 'Risk-Losses par','Ambig-Losses', 'Ambig-Losses par', 'constant' };
        
        if(run == 1 | run == 2)
 
            % add the columns(make sure in the right place) GAINS

            a = zeros(245,9);
            for i=1:5
                a(:,i) = sdm.SDMMatrix(:,i);
            end
            a(:,7) = sdm.SDMMatrix(:,6);
            a(:,9) = sdm.SDMMatrix(:,7);
            sdm.SDMMatrix = a;
            
            % update the relevant information (color, etc)            
            colors = zeros(9,3);
            for i=1:5
                colors(i,:) = sdm.PredictorColors(i,:);
            end
            colors(7,:) = sdm.PredictorColors(6,:);
            colors(9,:) = sdm.PredictorColors(7,:);
            sdm.PredictorColors = colors;
          
        elseif(run == 3 | run == 4)
    
            % add the columns(make sure in the right place) LOSSES

            a = zeros(245,9);
            a(:,1) = sdm.SDMMatrix(:,1);
            a(:,3) = sdm.SDMMatrix(:,2);
            for i=5:9
                a(:,i) = sdm.SDMMatrix(:,i-2);
            end
            sdm.SDMMatrix = a;
            
            % update the relevant information (color, etc)
          
            colors = zeros(9,3);
            colors(1,:) = sdm.PredictorColors(1,:);
            colors(3,:) = sdm.PredictorColors(3,:);
            for i=5:9
                colors(i,:) = sdm.PredictorColors(i-2,:);
            end

            sdm.PredictorColors = colors;
                       
        end
        
        % save it in a new file name
        sdm.SaveAs([path subject '_' num2str(run) '_9.sdm']);
    end
    
        
  end
  
        
        
       