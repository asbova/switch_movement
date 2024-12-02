function plotTimeInTrialHeatMapDLC(dataStructure)

% Creates a heat plot of average amount of time spent in sections of the operant chamber during long trials.
% Flips 18L6R protocol sessions so that all short response ports are represented on the left.
% 
% INPUTS:
%   dataStructure:      Contains DLC data for each session analyzed.
%
% OUTPUTS:
%   figure




    nSessions = size(dataStructure, 2);

    allSessionTimes = NaN(nSessions, 144);
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

        blocksize = 20;     % Size of blocks to quantify velocity.
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
        timeInBlocks = zeros(nTrials, length(blockDimensions));
        for jTrial = 1 : nTrials
            trialTrajectory = dlcData.smoothedTrajectories.LongTrials{jTrial}(dataIndex, :);
            for kBlock = 1 : length(blockDimensions)
                trajectoryPoints = find(trialTrajectory(:,1) >= blockDimensions{kBlock, 2}(1) & trialTrajectory(:,1) < blockDimensions{kBlock, 2}(2) & ...
                    trialTrajectory(:,2) >= blockDimensions{kBlock, 1}(1) & trialTrajectory(:,2) < blockDimensions{kBlock, 1}(2));

                timeInBlocks(jTrial, kBlock) = mean(trajectoryPoints)/frameRate;
            end
        end

        for iPoint = 1 : size(timeInBlocks, 2)
            if sum(~isnan(timeInBlocks(:, iPoint))) < 3
                timeInBlocks(:,iPoint) = NaN;
            end
        end

        allSessionTimes(iSession, :) = mean(timeInBlocks, 'omitnan');
    end % iSession
    
    

    averageTime = mean(allSessionTimes, 'omitnan');  
    
    reshapedBlocksHistogram = [averageTime(1:12); averageTime(13:24); averageTime(25:36); averageTime(37:48); averageTime(49:60); averageTime(61:72); ...
        averageTime(73:84); averageTime(85:96); averageTime(97:108); averageTime(109:120); averageTime(121:132); averageTime(133:144)];

    hold on;
    imagesc([-20 220], [-20 220], reshapedBlocksHistogram);
    % for iBlock = 1 : length(blockDimensions)
    %     imagesc([blockDimensions{iBlock, 2}(1) blockDimensions{iBlock,2}(2)], [blockDimensions{iBlock, 1}(1) blockDimensions{iBlock, 1}(2)], blocksHistogram(iBlock));
    % end
    a = colorbar;
    axis('on')
    axis xy
    set(gca, 'YDir', 'reverse');
    colormap('turbo');
    clim([0 18]);
    ylim([-10 210]);
    xlim([-30 230]);
    ylabel(a, 'Time within trial (s)', 'Rotation', 270)

    rectangle('Position', [-30 90 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 45 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 135 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');