function plotSlope(glmStructure, binSize)




    

    neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group});
    neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group});

    slopes{1} = abs([glmStructure(neuronsPFC).timeSlope] / binSize);
    slopes{2} = abs([glmStructure(neuronsDMS).timeSlope] / binSize);


    jitterPlot(slopes, 2, {[94 176 71] ./ 255, [39 43 175] ./ 255})
    

    ylabel('|Slope| 0-18 seconds')
    ylim([-0.01 0.7])
    xticks([1 2]);
    xticklabels({'PFC', 'DMS'})

    