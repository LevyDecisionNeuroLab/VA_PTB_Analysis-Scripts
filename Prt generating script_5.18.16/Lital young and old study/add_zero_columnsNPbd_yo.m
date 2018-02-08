path = 'Z:\Levy_Lab\Data_fMRI\R&A_young_adults\Lital-matlab\display-vs-resp\';

NPsubjects = {'1281', '1829', '2128', '2129', '2176','2178', '2181', '2331', '2332','2334', '20004','20006', '20008', '20010', '20012','20014'};

  for s = 1:length(NPsubjects)
    subject = NPsubjects{s};
    for run = 1:4
        sdm_name = [num2str(subject) 'svbddsprsp_' num2str(run) '.sdm'];
        sdm = xff([path sdm_name]);
        sdm.NrOfPredictors = 17;
        sdm.FirstConfoundPredictor = 17;
        sdm.PredictorNames = {'RG-display', 'RG-display par', 'RG-resp','RG-resp par', 'AG-display', 'AG-display par', 'AG-resp','AG-resp par','RL-display', 'RL-display par',  'RL-resp','RL-resp par','AL-display', 'AL-display par',  'AL-resp','AL-resp par', 'constant' };
        
         if(run == 3 | run == 4)
 
            % add the columns(make sure in the right place) GAINS
            a = zeros(245,17);
            for i=1:8
                a(:,i) = sdm.SDMMatrix(:,i);
            end
    
            for i=17
            a(:,i) = sdm.SDMMatrix(:,13);
            end
            sdm.SDMMatrix = a;
                        
            % update the relevant information (color, etc)            
            colors = zeros(17,3);
            for i=1:9
                colors(i,:) = sdm.PredictorColors(i,:);
            end
  %          for i=11:13
  %              colors(i,:) = sdm.PredictorColors(i-1,:);
   %         end
   %         for i=15:17
    %            colors(i,:) = sdm.PredictorColors(i-2,:);
   %         end
            sdm.PredictorColors = colors;
          
        elseif(run == 1 | run == 2)
    
            % add the columns(make sure in the right place) LOSSES

            a = zeros(245,17);
 %           a(:,1) = sdm.SDMMatrix(:,1);
            for i=9:17
                a(:,i) = sdm.SDMMatrix(:,i-4);
            end
 %           for i=7:17
   %             a(:,i) = sdm.SDMMatrix(:,i-2);
   %         end
            sdm.SDMMatrix = a;
            
            % update the relevant information (color, etc)
          
            colors = zeros(17,3);
 %           colors(1,:) = sdm.PredictorColors(1,:);
  %          for i=3:5
   %             colors(i,:) = sdm.PredictorColors(i-1,:);
    %        end
     %       for i=7:17
      %          colors(i,:) = sdm.PredictorColors(i-2,:);
       %     end

            sdm.PredictorColors = colors;
                       
        end
        
        % save it in a new file name
        sdm.SaveAs([path subject '_' num2str(run) '_dsprsp.sdm']);
    end
    
        
  end
  
        
        
       