% scriptProcessMatchedSwitchPavlovianEphys 
% Processes sorted pl2 files from open ephys recordings to extract waveform 

%%
projectName = 'switch_movement';
rootpath = '/Users/asbova/Documents/MATLAB';
cd(rootpath)
addpath(genpath(sprintf('./%s',projectName)));
cd(sprintf('./%s',projectName));

% Identify data directories.
behaviorDataFolder = './data/medpc'; % medPC files
ephysDataFolder = '/Volumes/BovaData2/TimeVsMovement'; % open ephys and sorted pl2 files

pl2Tag = 'pavlovianMatched';        % What the pl2 file name tag is.

% Get session information.
[mpcProtocols, group] = identifySessions(); 
groupNames = fieldnames(group);

% Create the data structure.
ephysDataStructure = struct;
count = 1;
for iGroup = 1 : length(groupNames)
    currentGroup = char(groupNames(iGroup));

    for jSession = 1 : size(group.(currentGroup), 2)
        ephysDataStructure(count).group = currentGroup;
        ephysDataStructure(count).mouseID = group.(currentGroup){1,jSession}{2,1};
        ephysDataStructure(count).date = datestr(group.(currentGroup){1,jSession}{1,1}, 'yyyy-mm-dd');
        count = count + 1;
    end
end

mouseIDs = {ephysDataStructure.mouseID};
mpcParsed = getDataIntr(behaviorDataFolder, mpcProtocols, mouseIDs);

%% Create the data structure from directory filenames. WORKING HERE!

ephysMouseFolders = dir(ephysDataFolder); % Each mouse has a sub-folder within the main data folder.
ephysMouseFolders = ephysMouseFolders(~ismember({ephysMouseFolders.name},{'.','..','.DS_Store','._'}));

for iMouse = 1 : size(ephysMouseFolders, 1)

    % Find the sorted pl2 files.
    currentMouseFolder = fullfile(ephysDataFolder, ephysMouseFolders(iMouse).name);
    pl2FileNames = dir(currentMouseFolder);
    pl2FileNames = pl2FileNames(contains({pl2FileNames.name}, pl2Tag) & ~contains({pl2FileNames.name},'._'));
    if isempty(pl2FileNames) | (~any(contains({pl2FileNames.name}, mouseIDs)) && ~any(contains({pl2FileNames.name}, {ephysDataStructure.date})))
        continue; % No sessions for this mouse have been sorted yet.
    end

    % Identify the open ephys folder(s).
    ephysFileList = dir(currentMouseFolder);
    ephysFileList = ephysFileList(~ismember({ephysFileList.name},{'.', '..'}));
    ephysFileList = ephysFileList([ephysFileList.isdir]);

    for jFile = 1 : length(pl2FileNames)

        % extract mouse ID and session date
        currentFilePathway = fullfile(pl2FileNames(jFile).folder, pl2FileNames(jFile).name);
        [~, currentPL2Name, ~] = fileparts(currentFilePathway);
        currentMouseID = regexp(currentPL2Name, '\w{2,4}\d{1}', 'match', 'once');
        currentDate = regexp(currentPL2Name, '\d+\-\d+\-\d+', 'match', 'once');
        currentDateMPC = datestr(datetime(currentDate, 'InputFormat', 'yyyy-MM-dd'), 'mm/dd/yy');
        structureRow = find(contains({ephysDataStructure.mouseID}, currentMouseID) & contains({ephysDataStructure.date}, currentDate));      
        if isempty(structureRow)
            continue
        else
            % This session should be analyzed!
        end

        ephysFileIndex = find(contains({ephysFileList.name}, currentDate));

        ephysDataStructure(structureRow).mpcDate = currentDateMPC;
        ephysDataStructure(structureRow).pl2FilePathway = currentFilePathway;     
        ephysDataStructure(structureRow).pl2Name = currentPL2Name;
        ephysDataStructure(structureRow).oephysName = ephysFileList(ephysFileIndex).name;
        ephysDataStructure(structureRow).oephysFilePathway = ephysFileList(ephysFileIndex).folder;
        ephysDataStructure(structureRow).format = 'bin'; % DO WE NEED THIS?? FORMAT FOR WHAT??
    end
end

%% Add behavioral data from MedPC and Open Ephys.

% Remove sessions that don't have matched pl2 sorted files.
emptyRows = cellfun(@(x) isempty(x), {ephysDataStructure.mpcDate});
ephysDataStructure(emptyRows) = [];

for iSession = 1 : length(ephysDataStructure)
    mpcIndex = find(strcmp(ephysDataStructure(iSession).mouseID, {mpcParsed.Subject}) & strcmp(ephysDataStructure(iSession).mpcDate, {mpcParsed.StartDate}));
    
    if isscalar(mpcIndex) & ~isempty(ephysDataStructure(iSession).mpcDate)
        currentEphysPathway = fullfile(ephysDataStructure(iSession).oephysFilePathway, ephysDataStructure(iSession).oephysName);
        ephysDataStructure(iSession).mpcData = mpcParsed(mpcIndex);
        if contains(ephysDataStructure(iSession).group, 'switch')       % Switch Task
            ephysDataStructure(iSession).mpcTrialData = getTrialDataSwitch(ephysDataStructure(iSession).mpcData);
            ephysDataStructure(iSession).ephysEvents = get_mpc_bin_event_oe3(currentEphysPathway, ephysDataStructure(iSession).mpcData, ...
                ephysDataStructure(iSession).mouseID, ephysDataStructure(iSession).oephysName);   
            [ephysDataStructure(iSession).withinTrialEphysEvents, ephysDataStructure(iSession).trialSpecificEphysEvents] = ...
                extractTrialEventsEphys(ephysDataStructure(iSession));
        else                                                            % Pavlovian Conditioning Task
            ephysDataStructure(iSession).mpcTrialData = getTrialDataPavlov(ephysDataStructure(iSession).mpcData);
            ephysDataStructure(iSession).ephysEvents = get_mpc_bin_event_oe3_pavlov(currentEphysPathway, ephysDataStructure(iSession).mpcData);  
            [ephysDataStructure(iSession).withinTrialEphysEvents, ephysDataStructure(iSession).trialSpecificEphysEvents] = ...
                extractTrialEventsEphysPavlov(ephysDataStructure(iSession));
        end
    else
        % Do not analyze data
    end        
end

%% Neuron analysis

for iSession = 1 : length(ephysDataStructure)
    ephysDataStructure(iSession).neurons = extractNeuronData(ephysDataStructure(iSession));
end

% Clustering analysis on DMS switch recordings.
dmsSwitchRows = cellfun(@(x) contains(x, 'DMSswitch'), {ephysDataStructure.group});
allNeurons = [];
for iSession = 1 : sum(dmsSwitchRows)
    allNeurons = [allNeurons ephysDataStructure(iSession).neurons];
end
neurons = clusterStriatalNeurons(allNeurons, 0.9);

% Distribute neuron classification identifiers to each session within ephysDataStructure.
startIndex = 1;
totalUnits = 0;
for iSession = 1 : sum(dmsSwitchRows)

    nUnits = size(ephysDataStructure(iSession).neurons, 2);         % Sometimes an extra unit in one recording. 
    nUnitsPav = size(ephysDataStructure(iSession + sum(dmsSwitchRows)).neurons, 2);
    while nUnits ~= nUnitsPav
        for jUnit = 1 : nUnits
            if ~strcmp(ephysDataStructure(iSession).neurons(jUnit).name, ephysDataStructure(iSession + sum(dmsSwitchRows)).neurons(jUnit).name) & nUnits > nUnitsPav
                matchingNeuron = find(cellfun(@(x) strcmp(x, ephysDataStructure(iSession).neurons(jUnit).filename), {neurons.filename}) & cellfun(@(x) strcmp(x, ephysDataStructure(iSession).neurons(jUnit).name), {neurons.name}));
                neurons(matchingNeuron) = [];
                ephysDataStructure(iSession).neurons(jUnit) = [];    
                nUnits = nUnits - 1;
            elseif ~strcmp(ephysDataStructure(iSession).neurons(jUnit).name, ephysDataStructure(iSession + sum(dmsSwitchRows)).neurons(jUnit).name) & nUnits < nUnitsPav
                ephysDataStructure(iSession + sum(dmsSwitchRows)).neurons(jUnit) = [];
                nUnitsPav = nUnitsPav - 1;
            end
            if nUnits == nUnitsPav
                break;
            end
        end
    end

    for jSession = [iSession, iSession + sum(dmsSwitchRows)]
        [ephysDataStructure(jSession).neurons.type] = deal(neurons(startIndex : startIndex + nUnits-1).type);
    end
    totalUnits = totalUnits + nUnits;
    startIndex = totalUnits + 1;
end

% Save file.
save('./data/matfiles/neuronStructureMatchedPavlovianMovement.mat', 'ephysDataStructure');