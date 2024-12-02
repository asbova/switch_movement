%% sub functions
function jitterPlot(data, type, color)

% colorTable = [colorTable;colorTable;     colorTable;     colorTable;     ];     
% colorTable = [colorTable;colorTable;     colorTable;     colorTable;     ];     
% colorTable = [colorTable;colorTable;     colorTable;     colorTable;     ];     

hold on
for count = 1:length(data)

        means = nanmean(data{count});
        medians = nanmedian(data{count});
        if type == 1 % medians
            pH = line([count-0.3 count+0.3], [medians medians]); set(pH, 'Color', [0 0 0], 'LineWidth', 4);
        else
            pH = line([count-0.3 count+0.3], [means means]); set(pH, 'Color', [0 0 0], 'LineWidth', 4);
        end
    
        s = length(data{count}); % doing this in case you have a situation where a subject had no data.     
        se=nanstd(data{count})./sqrt(s);
        for i_line = 1:length(data{count}); 
            
                    pH = plot([count-0.2 + 0.4*i_line/length(data{count})],data{count}(i_line),'ko');   
                    set(pH, 'MarkerFaceColor', color{count}, 'MarkerEdgeColor', 'white'); 
        end;

        


        
end




