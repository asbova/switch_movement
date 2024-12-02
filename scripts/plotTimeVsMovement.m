function plotTimeVsMovement(glmStructure)
%
% Plot the percentage of neurons that are movement-related, time-related, or both.
%
% Input: 
%       glmStructure:           structure with GLM results for every neuron 
%
% Output: 
%       figure

    

        alphaValue = 0.2;
    

        neuronsDMS = arrayfun(@(x) contains(x, 'DMS'), {glmStructure.group});
        neuronsPFC = arrayfun(@(x) contains(x, 'PFC'), {glmStructure.group});

        hold on;
        xlim([-0.05 1.05]);
        ylim([-0.05 1.05]);
        set(gca, 'XDir', 'reverse')
        set(gca, 'YDir', 'reverse')
        patch([1.05 0.05 0.05 1.05], [1.05 1.05 0.05 0.05], [92 92 92] ./ 255, 'EdgeColor', 'none', 'FaceAlpha', alphaValue);
        patch([0.05 -0.05 -0.05 0.05], [1.05 1.05 0.05 0.05], [255 153 204] ./ 255, 'EdgeColor', 'none', 'FaceAlpha', alphaValue);
        patch([1.05 0.05 0.05 1.05], [0.05 0.05 -0.05 -0.05], [255 255 51] ./ 255, 'EdgeColor', 'none', 'FaceAlpha', alphaValue);
        patch([0.05 -0.05 -0.05 0.05], [0.05 0.05 -0.05 -0.05], [255 153 204] ./ 255, 'EdgeColor', 'none', 'FaceAlpha', alphaValue);
        patch([0.05 -0.05 -0.05 0.05], [0.05 0.05 -0.05 -0.05], [255 255 51] ./ 255, 'EdgeColor', 'none', 'FaceAlpha', alphaValue);

        scatter([glmStructure(neuronsPFC).pTimeFDR], [glmStructure(neuronsPFC).pVelocityFDR], 'MarkerFaceColor', [94 176 71] ./ 255, 'MarkerEdgeColor', 'white');
        scatter([glmStructure(neuronsDMS).pTimeFDR], [glmStructure(neuronsDMS).pVelocityFDR], 'MarkerFaceColor', [39 43 175] ./ 255, 'MarkerEdgeColor', 'white')

        xlabel('pTime')
        ylabel('pMovement')

        

