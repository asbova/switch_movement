function plotFractionNonRampEvents(glmStructure) 




    neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group});
    neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group});

    % Identify time-, motor-, or time- and motor-related neurons for PFC and DMS.
    cuesPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pCuesFDR});
    responsePFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pResponseFDR});
    nPFC = sum(neuronsPFC);

    cuesDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pCuesFDR});
    responseDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pResponseFDR});
    nDMS = sum(neuronsDMS);

    % Plot bar graphs of percentage of neurons within each category for PFC and DMS.
    y = [sum(cuesPFC)/nPFC sum(cuesDMS)/nDMS; sum(responsePFC)/nPFC sum(responseDMS)/nDMS] * 100;
    b = bar(y, 'FaceColor', 'flat', 'EdgeColor', 'none');

    % Plot formatting
    b(1).CData = [94 176 71] ./ 255;
    b(2).CData = [39 43 175] ./ 255;
    ylabel('Event-Modulated Neurons (%)');
    xticks(1:3);
    xticklabels({'Cues On', 'Nosepoke'})
    legend('PFC', 'DMS')
    box off