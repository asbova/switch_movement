




    neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group}) & cellfun(@(x) x < 0.05, {glmStructure.pTimeFDR});
    neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group}) & cellfun(@(x) x < 0.05, {glmStructure.pTimeFDR});

    slopes{1} = [glmStructure(neuronsPFC).timeSlope] / binSize;
    slopes{2} = [glmStructure(neuronsDMS).timeSlope] / binSize;

    jitterPlot(slopes, 2, {[94 176 71] ./ 255, [39 43 175] ./ 255})


    nPFC = length(slopes{1});
    nDMS = length(slopes{2});
    y = [sum(slopes{1} < 0)/nPFC sum(slopes{2} < 0)/nDMS; sum(slopes{1} > 0)/nPFC sum(slopes{2} > 0)/nDMS] * 100;


    b = bar(y, 'FaceColor', 'flat', 'EdgeColor', 'none');

    % Plot formatting
    b(1).CData = [94 176 71] ./ 255;
    b(2).CData = [39 43 175] ./ 255;
    ylabel('% of Ramping Neurons');
    xticks(1:2);
    xticklabels({'Down', 'Up'})
    legend('PFC', 'DMS')
    box off