function plotVelocityHeatMapDLC(dataStructure)

% Creates a heat plot of average amount of time spent in sections of the operant chamber during long trials.
% Flips 18L6R protocol sessions so that all short response ports are represented on the left.
% 
% INPUTS:
%   dataStructure:      Contains DLC data for each session analyzed.
%
% OUTPUTS:
%   figure




    nSessions = size(dataStructure, 2);

    allSessionVelocity = NaN(nSessions, 144);
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
        velocityInBlocks = zeros(nTrials, length(blockDimensions));
        for jTrial = 1 : nTrials
            trialTrajectory = dlcData.smoothedTrajectories.LongTrials{jTrial}(dataIndex, :);
            velocityData = dlcData.velocity.LongTrials;
            for kBlock = 1 : length(blockDimensions)
                trajectoryPoints = trialTrajectory(:,1) >= blockDimensions{kBlock, 2}(1) & trialTrajectory(:,1) < blockDimensions{kBlock, 2}(2) & ...
                    trialTrajectory(:,2) >= blockDimensions{kBlock, 1}(1) & trialTrajectory(:,2) < blockDimensions{kBlock, 1}(2);

                velocityInBlocks(jTrial, kBlock) = mean(velocityData(jTrial, trajectoryPoints), 'omitnan');
            end
        end

        for iPoint = 1 : size(velocityInBlocks, 2)
            if sum(~isnan(velocityInBlocks(:, iPoint))) < 5
                velocityInBlocks(:,iPoint) = NaN;
            end
        end


        allSessionVelocity(iSession, :) = mean(velocityInBlocks, 'omitnan');
    end % iSession
    
    averageVelocity = mean(allSessionVelocity, 'omitnan');
    
    highestValue = max(averageVelocity);
    reshapedBlocksHistogram = [averageVelocity(1:12); averageVelocity(13:24); averageVelocity(25:36); averageVelocity(37:48); averageVelocity(49:60); averageVelocity(61:72); ...
        averageVelocity(73:84); averageVelocity(85:96); averageVelocity(97:108); averageVelocity(109:120); averageVelocity(121:132); averageVelocity(133:144)];

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
    clim([0 round(highestValue, 1)]);
    ylim([-10 210]);
    xlim([-30 230]);
    ylabel(a, 'Velocity (mm/s)', 'Rotation', 270)

    rectangle('Position', [-30 90 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 45 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');
    rectangle('Position', [220 135 20 20], 'Curvature', [1 1], 'LineWidth', 1.5, 'EdgeColor', 'w');