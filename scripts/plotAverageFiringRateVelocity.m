function plotAverageFiringRateVelocity(periEventSpike, velocity, interval, plotColor)
%
% Plot the kernel estimated neuronal firing rate
%
% INPUTS:
%   periEventSpike:         matrix (trial x spike timestamps)
%   interval:               time vector of peri-event time
%   plotColor:              color for plotting
%
% OUTPUT
%   figure handle


    % default kernel bandwidth and time output limit to remove edge artifact
    binSize = interval(2)-interval(1);
    kernelWindow = binSize * 1;
    intervalLimit = [interval(1) + kernelWindow*4 interval(end) - kernelWindow*4];

    % single condition 
    if ~iscell(periEventSpike)
        periEventSpike = {periEventSpike};
    end
    
    nConditions = length(periEventSpike);
    % randomly select trials for raster plot
    ipermut = cell(nConditions,1);
    for iCondition = 1 : nConditions
        nTrials = size(periEventSpike{iCondition}, 1);
        ipermut{iCondition} = 1 : nTrials;
    end

    % Plot the estimated firing rate
    [data, ci] = gksmooth(periEventSpike{iCondition}, interval, kernelWindow);
    yyaxis left
    hold on;
    plotband(interval, data, ci, plotColor{1})    
    ylabel('Firing Rate (Hz)')
    
    % Plot the average velocity    
    averageVelocity = mean(velocity, 'omitnan');
    stdVelocity = std(velocity, 0, 1, 'omitnan') ./ sqrt(size(velocity, 1));
    yyaxis right
    x = intervalLimit(1) + 1/60 : 1/60 : intervalLimit(2);
    plotband(x, averageVelocity(61 : 1500), stdVelocity(61 : 1500), plotColor{2})
    ylabel('Velocity (pixels/s)')

    ax = gca;
    ax.YAxis(1).Color = plotColor{1};
    ax.YAxis(2).Color = plotColor{2};
    xlim(intervalLimit);
    xticks(0:6:18);
    set(gca, 'box', 'off');
    set(gca, 'color', 'none');
    xlabel('Time from Trial Start (s)');

    % temporary
    xline(0, 'Color', 'b', 'LineStyle', '--')
    xline(6, 'Color', 'b', 'LineStyle', '--')
    xline(18, 'Color', 'b', 'LineStyle', '--')   
    
    hold off

end

function plotband(x, means, variance, color)

px = [x fliplr(x)];
if size(variance,1) == 1 % single variance like std or sem
    patch(px, [means+variance fliplr(means-variance)], color, 'EdgeAlpha', 0.1, 'FaceAlpha', 0.3, 'linewidth',0.5);
    hold on
    plot(x, means, 'LineWidth', 2, 'Color',color)
elseif size(variance,1) == 2 % dual variance like confidence intervals
    patch(px, [variance(1,:) fliplr(variance(2,:))], color, 'EdgeAlpha', 0.1, 'FaceAlpha', 0.3, 'linewidth',0.5);
    hold on
    plot(x, means, 'LineWidth', 2, 'Color',color)
end

end
