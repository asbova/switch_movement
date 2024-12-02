function plotPETH(PETH, scores, neurons, trialEnd)
%
% Plot the percentage of neurons that are modulated by time and/or movement velocity. 
%
% Input: 
%       PETH:               Z-scored peri-event time histogram. Each row is a neuron's average z-scored PETH.
%       scores:             PCA scores for each neuron.
%       neurons:            Logical to indicate which neurons to plot.
%
% Output: 
%       figure

    
    % Parameters
    intervalStart = -4;
    intervalEnd = trialEnd + 4;
    binSize = 0.2;
    intervalBins = intervalStart : binSize : intervalEnd;
    trialStart = 0;
    PCtoSort = 1; 

    % Run a PCA.
    timeInterval = intervalBins > (trialStart - binSize) & intervalBins < (trialEnd + binSize);
    plotInterval = intervalBins(timeInterval);
       
    % Plot
    [~, sortKey] = sort(scores(neurons, PCtoSort));  % Sort the data to plot by score in PC1.
    PETHtoPlot = PETH(neurons, :);
    imagesc(plotInterval, [], PETHtoPlot(sortKey,:), [-3 3]); 
    xlabel('Time from Trial Start (s)'); 
    ylabel('Neuron #')
    %xticks([0 6 18]);
    yticks([1 size(PETHtoPlot,1)]);
    colorbar;
    colormap('jet');