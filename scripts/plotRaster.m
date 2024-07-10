function plotRaster(periEventSpike, interval, plotColor)
%
% Plots peri-event raster plot.
%
% INPUTS:
%   periEventSpike:         matrix (trial x spike timestamps)
%   interval:               time vector of peri-event time
%   plotColor:              color of raster lines
%
% OUTPUT:
%   figure handle

    % default kernel bandwidth and time output limit to remove edge artifact
    binSize = interval(2)-interval(1);
    kernelWindow = binSize*1;
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
     
    % Raster plot
    perTrialSpikes = periEventSpike{iCondition}(ipermut{iCondition},:);
    periEventRaster(perTrialSpikes, intervalLimit, 'Color', plotColor, 'FontSize',4);

end





function varargout = periEventRaster(periEventSpike, tlimit, varargin)
    
    % plot spike raster using text '|', scale better than line plot
    alphaThresh = 40000;
    dataIdx = ~isnan(periEventSpike);
    [row,~] = find(dataIdx);
    rasterSpike = periEventSpike(dataIdx);
    limitIdx = rasterSpike > tlimit(1) & rasterSpike < tlimit(2);
    rasterSpike = rasterSpike(limitIdx);
    row = row(limitIdx);
    plot(rasterSpike, row, 'LineStyle', 'none', 'Marker', 'none');
    t = text(rasterSpike, row, '|', 'HorizontalAlignment','center', varargin{:});
    if length(rasterSpike) > alphaThresh
        alphaNum = alphaThresh/length(rasterSpike);
        alpha(t,alphaNum);
    end
    %axis tight
    xlim(tlimit);
    axis off
            
    if nargout==1
        varargout{1} = t;
    end

end

