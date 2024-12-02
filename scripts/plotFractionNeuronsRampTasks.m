function plotFractionNeuronsRampTasks(glmStructure)
%
% Plot the percentage of neurons that are movement-related, time-related, or both.
%
% Input: 
%       glmStructure:           structure with GLM results for every neuron 
%
% Output: 
%       figure

    
    

        % Separate glmStructure by task and region recorded from.
        neuronsDMSswitch = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.region}) & arrayfun(@(x) contains(x, 'switch'), {glmStructure.task});
        neuronsPFCswitch = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.region}) & arrayfun(@(x) contains(x, 'switch'), {glmStructure.task});
        neuronsDMSpavlov = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.region}) & arrayfun(@(x) contains(x, 'pavlovian'), {glmStructure.task});
        neuronsPFCpavlov = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.region}) & arrayfun(@(x) contains(x, 'pavlovian'), {glmStructure.task});

        
        % Identify time-related neurons for PFC and DMS within each task.
        timePFCswitch = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFCswitch).pTimeFDR});
        timePFCpavlov = cellfun(@(x) x < 0.05, {glmStructure(neuronsPFCpavlov).pTimeFDR});
        bothPFC = timePFCswitch & timePFCpavlov;
        nPFC = sum(neuronsPFCswitch);

        timeDMSswitch = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMSswitch).pTimeFDR});
        timeDMSpavlov = cellfun(@(x) x < 0.05, {glmStructure(neuronsDMSpavlov).pTimeFDR});
        bothDMS = timeDMSswitch & timeDMSpavlov;
        nDMS = sum(neuronsDMSswitch);

        % Plot bar graphs of percentage of neurons within each category for PFC and DMS.
        y = [sum(timePFCswitch)/nPFC sum(timeDMSswitch)/nDMS; sum(timePFCpavlov)/nPFC sum(timeDMSpavlov)/nDMS; sum(bothPFC)/nPFC sum(bothDMS)/nDMS] * 100;
        b = bar(y, 'FaceColor', 'flat', 'EdgeColor', 'none');
    
        % Plot formatting
        b(1).CData = [94 176 71] ./ 255;
        b(2).CData = [39 43 175] ./ 255;
        ylabel('Percent of Neurons');
        xticks(1:3);
        xticklabels({'Switch', 'Pavlovian', 'Both'})
        legend('PFC', 'DMS')
        box off
