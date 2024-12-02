function plotAverageVelocity(dataStructure)
%
% Plot the average velocity of long trials across mice.
%
% Input: 
%       dataStructure:              structure with behavioral, ephys, and deeplabcut data for each session (row)
%
% Output: 
%       figure

    
    

        nSession = size(dataStructure, 2);
        nPoints = size(dataStructure(1).dlc.velocity.LongTrials, 2);

        averageVelocity = NaN(nSession, nPoints);
        for iSession = 1 : nSession

            if isempty(dataStructure(iSession).dlc)
                continue;
            end

            velocityData = dataStructure(iSession).dlc.velocity.LongTrials;
            frameRate = dataStructure(iSession).dlc.frameRate;          % Some sessions were recorded at 30, others 60 fps.
            if frameRate == 30
                averageVelocity(iSession,:) = mean(velocityData, 1, 'omitnan');
            else
                binnedVelocity = [];            
                for jTrial = 1 : size(velocityData, 1)
                    binnedVelocity(jTrial, 1:nPoints) = arrayfun(@(x) mean(velocityData(jTrial, x:x+1)), 1:2:length(velocityData)-2);
                end
                averageVelocity(iSession,:) = mean(binnedVelocity, 'omitnan');
            end            
        end



        % Plot individual session data.
        hold on;
        for iSession = 1 : nSession
            if contains(dataStructure(iSession).group, 'DMS')
                plotColor = [192 194 242] ./ 255;
            else
                plotColor = [207 236 198] ./ 255; 
            end
            plot(1 : nPoints, averageVelocity(iSession, :), 'Color', plotColor, 'LineWidth', 0.5);
        end
        plot(1 : nPoints, mean(averageVelocity, 'omitnan'), 'Color', 'k', 'LineWidth', 1.5)

        xlim([0 779]);
        xticks([0 120 300 660 779]);
        xticklabels([-4 0 6 18 22]);
        xlabel('Time from Trial Start (s)');
        ylabel('Average Velocity (mm/s)');