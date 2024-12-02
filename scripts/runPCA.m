function [coefficients, pcaScores, zPETH] = runPCA(PETH, intervalEnd, trialEnd)
%
%   Plot the slope between trial start and switch for neurons that are correlated with photometry signal or not, 
%   within each tercile of switch response.
%
%   Inputs:
%       PETH:               smoothed peri-event time histograms for each neuron
%
%   Outputs:
%       coefficients:       PCA coefficients 
%       pcaScores:          scores from PCA for each neuron


    % Parameters
    intervalStart = -4;
    binSize = 0.2;
    intervalBins = intervalStart : binSize : intervalEnd;
    trialStart = 0;

    % Run a PCA.
    timeInterval = intervalBins > (trialStart - binSize) & intervalBins < (trialEnd + binSize);
    intervalPETH = PETH(:, timeInterval); 
    zPETH = zscore(intervalPETH')';
    warning off;
    [coefficients, pcaScores, ~, ~, ~] = pca(zPETH);
    warning on;




    