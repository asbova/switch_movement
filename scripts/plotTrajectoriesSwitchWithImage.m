function plotTrajectoriesSwitchWithImage(trajectoryData, frameRate)
% 
% INPUTS:
%   trajectoryData:     Within trial smoothed trajectories for short and long trials from one session.
%   corners:            x,y locations of all 4 behavior chamber corners
%   imageFile:          file pathway of still image (.jpg) from video 
%
% OUTPUTS:
%   figure




   
    % Plot trajectories of long trials.
    hold on
    nTrials = length(trajectoryData);    
    for iTrial = 1 : nTrials
        if isnan(trajectoryData{iTrial})
            continue;
        end

        if frameRate == 30
            dataIndex = 121 : 660;
        else
            dataIndex = 241 : 1320;
        end

        xPositions = trajectoryData{iTrial}(dataIndex,1);
        yPositions = trajectoryData{iTrial}(dataIndex,2);
        nPositions = size(xPositions,1);
        cmap = jet(nPositions);
    
        for i = 1 : nPositions - 1
            plot(xPositions([i i+1]), yPositions([i i+1]), 'color', cmap(i,:), 'linewidth', 1.5);
        end
    end

    % Make legend
    ylim([-10 210]);
    xlim([-30 230]);
    figureXLim = get(gca, 'xlim');
    figureYLim = get(gca, 'ylim');
    legendX = (figureXLim(1) + 10 : figureXLim(1) + 150)';
    legendY = ones(length(legendX),1)* (figureYLim(2)-10);
    n = size(legendX,1)-1;
    cmap = turbo(n);
    for i = 1:n
        plot(legendX([i i+1]), legendY([i i+1]), 'color', cmap(i,:), 'linewidth', 4);
    end

    text(legendX(1)-5, legendY(1) + 6, '0', 'Color', 'k', 'FontSize', 10, 'FontName', 'arial')
    text(legendX(end)-5, legendY(1) + 6, '18s', 'Color', 'k', 'FontSize', 10, 'FontName', 'arial')





    
    






    