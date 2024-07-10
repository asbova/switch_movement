function [trialEventStructure, eventStructure] = extractTrialEventsEphysPavlov(sessionData)

% Pulls out within trial events for each session
%
% Input:
%   sessionData:    Structure containing open ephys and medpc beahavioral data for the current session
%
% Output:
%   


    % Classify trials based on if rewarded or not rewarded, from MedPC.
    rewardedTrials = cellfun(@(x) ~isempty(x), {sessionData.mpcTrialData.reward});
    unrewardedTrials = cellfun(@(x) isempty(x), {sessionData.mpcTrialData.reward});
    
    % Extract Open Ephys events.
    cueOnTimestamps = sessionData.ephysEvents.evt3.ts;
    cueOffTimestamps = sessionData.ephysEvents.evt17.ts; 
    rewardResponseTimestamps = sessionData.ephysEvents.evt10.ts;
    rewardDispenseTimestamps = sessionData.ephysEvents.evt9.ts;
    
    nTrials = min(length(cueOnTimestamps), length(cueOffTimestamps));
    if length(rewardDispenseTimestamps) < nTrials
        rewardDispenseTimestamps(nTrials) = NaN;
    end

    trialEventStructure = struct;
    for iTrial = 1 : nTrials
        currentTrialStart = cueOnTimestamps(iTrial);
        trialEventStructure(iTrial).cuesOnTime = currentTrialStart;
        trialEventStructure(iTrial).rewardDispenseTime = rewardDispenseTimestamps(iTrial);

        % Extract timestamps of reward entry events that are within the trial and before the next trial.      
        if iTrial < nTrials
            nextTrialStart = cueOnTimestamps(iTrial + 1);
            trialEventStructure(iTrial).rewardResponseTime = rewardResponseTimestamps(rewardResponseTimestamps > currentTrialStart & rewardResponseTimestamps <= nextTrialStart);
        else
            trialEventStructure(iTrial).rewardResponseTime = rewardResponseTimestamps(rewardResponseTimestamps > currentTrialStart);
        end
    end

    eventStructure = struct;
    eventStructure.rewardedTrialCuesOn = cueOnTimestamps(rewardedTrials);
    eventStructure.unrewardedTrialCuesOn = cueOnTimestamps(unrewardedTrials);
    eventStructure.rewardDispense = rewardDispenseTimestamps;
    eventStructure.rewardResponse = rewardResponseTimestamps;


end