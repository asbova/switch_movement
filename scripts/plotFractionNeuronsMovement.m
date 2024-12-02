function plotFractionNeuronsMovement(glmStructure)
%
% Plot the percentage of neurons that are movement-related, time-related, or both.
%
% Input: 
%       glmStructure:           structure with GLM results for every neuron 
%
% Output: 
%       figure

    
    

        neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group});
        neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group});

        % Identify time-, motor-, or time- and motor-related neurons for PFC and DMS.
        timePFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsPFC).pVelocity});
        motorPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pVelocityFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsPFC).pTimeFDR});
        bothPFC = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pTimeFDR}) & cellfun(@(x) x < 0.05, {glmStructure(neuronsPFC).pVelocity});
        nPFC = sum(neuronsPFC);

        timeDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsDMS).pVelocity});
        motorDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pVelocityFDR}) & cellfun(@(x) x >= 0.05, {glmStructure(neuronsDMS).pTimeFDR});
        bothDMS = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pTimeFDR}) & cellfun(@(x) x < 0.05, {glmStructure(neuronsDMS).pVelocity});
        nDMS = sum(neuronsDMS);

        % Plot bar graphs of percentage of neurons within each category for PFC and DMS.
        y = [sum(timePFC)/nPFC sum(timeDMS)/nDMS; sum(motorPFC)/nPFC sum(motorDMS)/nDMS; sum(bothPFC)/nPFC sum(bothDMS)/nDMS] * 100;
        b = bar(y, 'FaceColor', 'flat', 'EdgeColor', 'none');
    
        % Plot formatting
        b(1).CData = [94 176 71] ./ 255;
        b(2).CData = [39 43 175] ./ 255;
        ylabel('Percent of Neurons');
        xticks(1:3);
        xticklabels({'Time', 'Velocity', 'Both'})
        legend('PFC', 'DMS', 'Location', 'northwest')
        box off
