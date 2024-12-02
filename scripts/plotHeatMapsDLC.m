function plotHeatMapsDLC(dataStructure)

% Creates a heat plot of average amount of time spent in sections of the operant chamber during long trials.
% Flips 18L6R protocol sessions so that all short response ports are represented on the left.
% 
% INPUTS:
%   dataStructure:      Contains DLC data for each session analyzed.
%
% OUTPUTS:
%   figure



    nSessions = size(dataStructure, 2);

    allSessionHistograms = NaN(nSessions, 144);
    for iSession = 1 : nSessions

        if isempty(dataStructure(iSession).dlc)
            continue;
        end

        dlcData = dataStructure(iSession).dlc;
        frameRate = dlcData.frameRate;
        if frameRate == 30
            dataIndex = 121 : 660;
        else
            dataIndex = 241 : 1320;
        end

        blocksize = 20;     % Size of blocks to quantify time spent in.
        xSize = 240;
        ySize = 240;
        nBlocksX = xSize / blocksize;
        nBlocksY = ySize / blocksize;
        xBlockStart = -20;
        yBlockStart = -20;

        index = 1;
        blockDimensions = {};
        for iBlockX = 1 : nBlocksX
            for iBlockY = 1 : nBlocksY
                blockDimensions{index, 1} = [xBlockStart, xBlockStart + blocksize]; %[blocksize * (iBlockX - 1) + 1, blocksize * (iBlockX - 1) + blocksize];
                blockDimensions{index, 2} = [yBlockStart, yBlockStart + blocksize]; %[blocksize * (iBlockY - 1) + 1, blocksize * (iBlockY - 1) + blocksize];
                index = index + 1;
                yBlockStart = yBlockStart + blocksize;
            end
            xBlockStart = xBlockStart + blocksize;
            yBlockStart = -20;
        end
    
        if contains(dataStructure(iSession).mpcData.MSN, '18L')
            blockDimensions(:,1) = flip(blockDimensions(:,1), 1);
        end
    
        nTrials = length(dlcData.smoothedTrajectories.LongTrials);
        blocksHistogram = zeros(nTrials, length(blockDimensions));
        for jTrial = 1 : nTrials
            trialTrajectory = dlcData.smoothedTrajectories.LongTrials{jTrial}(dataIndex,:);
            for kBlock = 1 : length(blockDimensions)
                trajectoryPoints = find(trialTrajectory(:,1) >= blockDimensions{kBlock, 2}(1) & trialTrajectory(:,1) < blockDimensions{kBlock, 2}(2) & ...
                    trialTrajectory(:,2) >= blockDimensions{kBlock, 1}(1) & trialTrajectory(:,2) < blockDimensions{kBlock, 1}(2));
                blocksHistogram(jTrial, kBlock) = length(trajectoryPoints);
            end
        end

        blocksHistogramSeconds = blocksHistogram / frameRate;
        allSessionHistograms(iSession, :) = mean(blocksHistogramSeconds);
    end % iSession
    
    averageHistogram = mean(allSessionHistograms, 'omitnan');
    
    highestValue = max(averageHistogram);
    reshapedBlocksHistogram = [averageHistogram(1:12); averageHistogram(13:24); averageHistogram(25:36); averageHistogram(37:48); averageHistogram(49:60); averageHistogram(61:72); ...
        averageHistogram(73:84); averageHistogram(85:96); averageHistogram(97:108); averageHistogram(109:120); averageHistogram(121:132); averageHistogram(133:144)];

    hold on;
    imagesc([-20 220], [-20 220], reshapedBlocksHistogram);
    a = colorbar;
    axis('on')
    axis xy
    set(gca, 'YDir', 'reverse');
    colormap('turbo');
    clim([0 round(highestValue, 1)]);
    ylim([-10 210]);
    xlim([-30 230]);
    ylabel(a, 'Time spent in block (s)', 'Rotation', 270)

    rectangle('Position', [-30 90 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 45 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 135 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');


    








            % 
        % figure; hold on;
        % scatter(0,0,'filled','r');
        % scatter(198,0,'filled','r');
        % scatter(198,180,'filled','r');
        % scatter(0,180,'filled','r');
        % set(gca, 'YDir', 'reverse');
        % nTrials = length(dlcData.smoothedTrajectories.LongTrials);
        % for jTrial = 1 : nTrials
        %     if isnan(dlcData.smoothedTrajectories.LongTrials{jTrial})
        %         continue;
        %     end
        % 
        %     xPositions = dlcData.smoothedTrajectories.LongTrials{jTrial}(dataIndex,1);
        %     yPositions= dlcData.smoothedTrajectories.LongTrials{jTrial}(dataIndex,2);
        % 
        %     nPositions = size(xPositions,1);       
        %     cmap = jet(nPositions);
        %     for i = 1 : nPositions - 1%%
        %         plot(xPositions([i i+1]), yPositions([i i+1]), 'color', cmap(i,:), 'linewidth', 1.5);
        %     end
        % 
        % end



end