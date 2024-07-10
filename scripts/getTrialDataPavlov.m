%% Code built to pull data from MedPC files for Pavlovian Conditioning
%% Adjusted from Youngcho's getTrialData and Ben's getTrialData_Bisection
    % getTrialData_Bisection.m, Benjamin De Corte 2017. Organize mpc output for bisection task.
%% Alexandra Bova

%% Changes to make - notes go here

%% following are data format from MEDPC output file
%{
\   C(0)    Maximum Session Duration / 30 (minutes)
\   C(1)    Maximum Reward / 40
\   C(2)    Trial Counter
\   C(5)    Reward counter *
\   C(7)    Output Frequency counter
\   C(8)    Interval Duration
\   C(9)    ITI?
\   C(13)   Reward Magazine Entry counter
\ 
\   D       Cue off record array
\   E       Trial Start time record array
\   H       Trial duration record array
\   I       ITI record array
\   J       Pellet dispense time record array
\   K       milli second Timer for recording events
\   L       Reward zone in record array
\   M       Reward zone out record array
\   O       Opto On or Off array
%}

%% Starts to pull values from MedPC files
function TrialDataStructure = getTrialDataPavlov(mpcParsed)

    uniqueMice = unique({mpcParsed.Subject});
    nTrials = cellfun(@length, {mpcParsed.E}); 
    
    for iMouse = 1 : size(uniqueMice,2)
        mouseIndex = strcmp(uniqueMice(iMouse), {mpcParsed.Subject}) &  nTrials;
        mouseLineIndex = find(mouseIndex);
        nSessions = sum(mouseIndex);
        mouseID = char(uniqueMice(iMouse));  
    
        for jSession = 1 : nSessions
            lineIndex = mouseLineIndex(jSession);
                
            % Extract behavioral response time stamps.
            trialDuration = mpcParsed(lineIndex).C(9);
            trialStart = mpcParsed(lineIndex).E'; 
            ITIlengths = mpcParsed(lineIndex).I';           
            reward = mpcParsed(lineIndex).J';
            opto = mpcParsed(lineIndex).O';
            opto = opto == 1;                           % 1 = laser off, 2 = laser on.
            if ~isempty(mpcParsed(lineIndex).P)
                trialType = mpcParsed(lineIndex).P'; 
                trialType = trialType == 1;             % 1 = rewarded trial, 0 = reward omission trial.
            else
                trialType(1:length(trialStart)) = 1;
            end                        
            rewardResponseIn = mpcParsed(lineIndex).L'; 
            rewardResponseOut = mpcParsed(lineIndex).M';
                
            % Add trial by trial data to structure.
            trial = struct;
            rewardCount = 1;
            for kTrial = 1 : nTrials
                currentTrialStart = trialStart(kTrial); 
                trial(kTrial).trialStart = currentTrialStart;
                trial(kTrial).trialDuration = trialDuration/1000;
                trial(kTrial).ITIduration = ITIlengths(kTrial);
                trial(kTrial).opto = opto(kTrial);
                trial(kTrial).trialType = trialType(kTrial);

                if kTrial < nTrials
                    nextTrialStart = trialStart(kTrial + 1); % Get the next trial's start time.
                else
                    nextTrialStart = mpcParsed.K; % Use the end of the recording as the next trial start if this is the last trial of the session.
                end
                trial(kTrial).rewardResponseTimes = rewardResponseIn(rewardResponseIn > currentTrialStart & rewardResponseIn <= nextTrialStart) - currentTrialStart; 
    
                if trialType(kTrial) == 1
                    trial(kTrial).reward = reward(rewardCount) - currentTrialStart;
                    rewardCount = rewardCount + 1;
                else
                    trial(kTrial).reward = [];
                end
            end

            trial(1).mpc = mpcParsed(lineIndex); 
            TrialDataStructure = trial; % 
        end  
    end

end