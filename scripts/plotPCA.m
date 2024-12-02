function plotPCA(coefficient, trialEnd)
%
% Plot the PCA scores for individual neurons and box plots for multiple groups.
%
% Input: 
%       scores:             
%
% Output: 
%       figure



    % Parameters
    intervalStart = -4;
    intervalEnd = trialEnd + 4;
    binSize = 0.2;
    intervalBins = intervalStart : binSize : intervalEnd;
    trialStart = 0;
    timeInterval = find(intervalBins > (trialStart - binSize) & intervalBins < (trialEnd + binSize));

    hold on;
    plot(intervalBins(timeInterval), coefficient(:,1) + 0.3, 'k', 'LineWidth', 5);
    plot(intervalBins(timeInterval), coefficient(:,2) - 0.3, 'Color', [128/255 128/255 128/255], 'LineWidth', 5);
    %plot(interval(TimeInterval), COEFF(:,3)-0.3, 'Color', 'r', 'LineWidth', 7);
    set(gca, 'ytick', []); 
    %xlim([0 18]);
    ylim([-0.5 0.6]);
    xlabel('Time from Trial Start (s)')
    text(0.5, .25, 'PC1', 'FontSize', 16);
    text(14, -.37, 'PC2', 'FontSize', 16', 'Color', [128/255 128/255 128/255]);
    box off;