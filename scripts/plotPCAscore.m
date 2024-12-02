function plotPCAscore(scores, DMSneurons, PFCneurons)
%
% Plot the PCA scores for individual neurons and box plots for multiple groups.
%
% Input: 
%       scores:             
%
% Output: 
%       figure



    plotColors = {[94 176 71] ./ 255; [39 43 175] ./ 255};

    scoresPlot{1} = abs(scores(PFCneurons, 1));
    scoresPlot{2} = abs(scores(DMSneurons, 1));
    boxplotValues = [ones(1, length(scoresPlot{1})), 2 * ones(1, length(scoresPlot{2}))];
    allScores = [scoresPlot{1}; scoresPlot{2}]';

    hold on;
    scatter(ones(size(scoresPlot{1})) .* (1 + (rand(size(scoresPlot{1})) -0.5) / 5), scoresPlot{1}, 'filled', 'MarkerFaceColor', plotColors{1}, 'MarkerFaceAlpha', 0.3);
    scatter(2 * ones(size(scoresPlot{2})) .* (1 + (rand(size(scoresPlot{2})) -0.5) / 8), scoresPlot{2}, 'filled', 'MarkerFaceColor', plotColors{2},'MarkerFaceAlpha', 0.3);
    boxplot(allScores, boxplotValues, 'Color', 'k');
    ylabel('PC1 |Score|');
    set(gca, 'xtick', 1:2, 'xticklabel', {'PFC', 'DMS'});
    box off