function plotFractionNeuronsRamp(glmStructure)



    
    neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group});
    neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group});

    % Identify time-, motor-, or time- and motor-related neurons for PFC and DMS.
    fullPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsPFC).pTimeSixFDR});
    sixPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeSixFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsPFC).pTimeFDR});
    bothPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeFDR}) & cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeSixFDR});
    nPFC = sum(neuronsPFC);

    fullDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsDMS).pTimeSixFDR});
    sixDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeSixFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsDMS).pTimeFDR});
    bothDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeFDR}) & cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeSixFDR});
    nDMS = sum(neuronsDMS);

    % Plot bar graphs of percentage of neurons within each category for PFC and DMS.
    y = [sum(fullPFC)/nPFC sum(fullDMS)/nDMS; sum(sixPFC)/nPFC sum(sixDMS)/nDMS; sum(bothPFC)/nPFC sum(bothDMS)/nDMS] * 100;
    b = bar(y, 'FaceColor', 'flat', 'EdgeColor', 'none');

    % Plot formatting
    b(1).CData = [94 176 71] ./ 255;
    b(2).CData = [39 43 175] ./ 255;
    ylabel('Interval-Modulated Neurons (%)');
    xticks(1:3);
    xticklabels({'0-18', '0-6', 'Both'})
    legend('PFC', 'DMS')
    box off