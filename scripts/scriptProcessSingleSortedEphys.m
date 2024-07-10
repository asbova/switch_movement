% scriptProcessSingleSortedEphys 
% Processes sorted pl2 files from open ephys recordings to extract waveform 

%%
addpath(genpath('./switch_movement'))
cd './switch_movement'

% Identify data directories.
behaviorDataFolder = './data/medpc'; % medPC files
ephysDataFolder = '/Volumes/BovaData2/TimeVsMovement'; % open ephys and sorted pl2 files

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

%% Create the data structure from directory filenames.

ephysMouseFolders = dir(ephysDataFolder); % Each mouse has a sub-folder within the main data folder.
ephysMouseFolders = ephysMouseFolders(~ismember({ephysMouseFolders.name},{'.','..','.DS_Store','._'}));

for iMouse = 1 : size(ephysMouseFolders, 1)

    % Find the sorted pl2 files.
    currentMouseFolder = fullfile(ephysDataFolder, ephysMouseFolders(iMouse).name);
    pl2FileNames = dir(currentMouseFolder);
    pl2FileNames = pl2FileNames(contains({pl2FileNames.name},'roughsort') & ~contains({pl2FileNames.name},'._'));
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

        ephysDataStructure(structureRow).mpcDate = currentDateMPC;
        ephysDataStructure(structureRow).pl2FilePathway = currentFilePathway;     
        ephysDataStructure(structureRow).pl2Name = currentPL2Name;
        ephysDataStructure(structureRow).oephysName = ephysFileList(jFile).name;
        ephysDataStructure(structureRow).oephysFilePathway = ephysFileList(jFile).folder;
        ephysDataStructure(structureRow).format = 'bin'; % DO WE NEED THIS?? FORMAT FOR WHAT??
    end
end

%% Add behavioral data from MedPC and Open Ephys.

for iSession = 1 : length(ephysDataStructure)
    mpcIndex = find(strcmp(ephysDataStructure(iSession).mouseID, {mpcParsed.Subject}) & strcmp(ephysDataStructure(iSession).mpcDate, {mpcParsed.StartDate}));
    currentEphysPathway = fullfile(ephysDataStructure(iSession).oephysFilePathway, ephysDataStructure(iSession).oephysName);

    if isscalar(mpcIndex)
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

% Clustering analysis
allNeurons = [];
nSessions = 0;
for iSession = 1 : length(ephysDataStructure)
    if contains(ephysDataStructure(iSession).group, 'DMS')
        allNeurons = [allNeurons ephysDataStructure(iSession).neurons];
        nSessions = nSessions + 1;
    else
        % Not a striatal neuron so does not need to be put through clustering analysis.
    end
end
neurons = clusterStriatalNeurons(allNeurons, 0.9);

% Distribute neuron classification identifiers to each session within ephysDataStructure.
startIndex = 1;
totalUnits = 0;
for iSession = 1 : nSessions    % This assumes that the DMS sessions all come before PFC.
    nUnits = size(ephysDataStructure(iSession).neurons, 2);
    [ephysDataStructure(iSession).neurons.type] = deal(neurons(startIndex : startIndex + nUnits-1).type);
    totalUnits = totalUnits + nUnits;
    startIndex = totalUnits + 1;
end

% Save file.
save('./data/matfiles/neuronStructure.mat', 'ephysDataStructure');