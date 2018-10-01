function [locations, errors, angles,anglesPacked] = solverIK(model, trcpath, markerList, weights)
%% solverIK is a Matlab interface to the OpenSim IKSolver(). 
% Inputs are an OpenSim Model, path to a trc file, list of markers to be
% tracked, and an array of weights corresponding with each marker. 
%
% Outputs are the locations of the model markers, the errors between the
% model and experimental markers, a coordinate value array (without labels),
% and a struct of coordinate values (allocated labels).
% 

% Use the IK solver and report back the individual marker errors. 
import org.opensim.modeling.*
% Initialize OpenSim model
s = model.initSystem();
nM = length(markerList);
trcTable = TRCFileAdapter().read(trcpath);
trcTable.removeTableMetaDataKey('Units')
trcTable.addTableMetaDataString('Units','Meters')




%% get lists of the marker and coordinate names
% markerNames = [];
% for i = 0 : model.getMarkerSet().getSize()-1;
%    markerNames = [markerNames {char(model.getMarkerSet().get(i).getName() )}];    
% end
% 
% trcNames = [];
% for i = 0 : t.getNumColumns() - 1
%     trcNames = [trcNames {char(t.getColumnLabels().get(i))}];
% end
% Generate a final list of Markers to track
% markerList = intersect(markerNames,trcNames);

coordName = [];
for i = 0 : model.getCoordinateSet().getSize()-1;
   coordName = [coordName {char(model.getCoordinateSet().get(i).getName() )}];    
end

%% Populate markers reference object with desired marker weights
markerWeights = SetMarkerWeights();
for i = 1 : length(markerList) 
    markerWeights.cloneAndAppend( MarkerWeight(markerList{i}, weights(i) ) );
end

%% Make a Marker Reference Object
markerref = MarkersReference(trcTable,markerWeights,Units('Meters'));

% Get Time values from MarkerRef
timeRange = markerref.getValidTimeRange();
startTime = timeRange.get(0);
endTime = timeRange.get(1);

%% Create an arry of blank coordinate reference objects
coordref = SimTKArrayCoordinateReference();

%     % Populate coordinate references object with desired coordinate values
%     % and weights
%     for i = 1 : length(coordName)
%         coordRef = CoordinateReference(coordName{i} , Constant() );
%         coordRef.setWeight(0);
%         coordRef.markAdopted();
%         coordref.push_back(coordRef);
%     end

%% Define kinematics reporter for output

%% Define constraint weight
constweight = Inf;

%% Instantiate the ikSolver and set some values. 
ikSolver = InverseKinematicsSolver(model,markerref,coordref,constweight);
% Set ikSolver accuracy
accuracy = 1e-5;
ikSolver.setAccuracy(accuracy);

% %% Loop through IK coordinate tasks and define values and weights
% for i = 0 : model.getMarkerSet().getSize() - 1
%      ikSolver.updateMarkerWeight(i,1);
% end
% for i = 1 : model.getCoordinateSet().getSize()
%     ikSolver.updateCoordinateReference(coordName{i},0);
% end

%% Compute dt and nFrames
dt = 1.0/markerref.getSamplingFrequency();
nFrames = round(( (endTime-startTime)/dt )+1);

%% Assemble the model
s.setTime(startTime);
time = startTime;
validTime = [];

disp('Assessing ability to assemble...' );
while time <= endTime 
    s.setTime(time);
    try 
        ikSolver.assemble(s);
        validTime(length(validTime)+1,1) = time;
    catch
        % Don't need it to do anything
    end
    % Increment time;
    time = round(time + dt, 3);
end
disp(['IK is only possible from time= ' num2str(validTime(1)) ' to ' num2str(validTime(end)) ]);
    
%% Perform IK analysis
disp('Starting IK analysis')
errors = [];
angles = [];
locations = [];
% Get a fresh State
s = model.initSystem();

for i = 1 : length(validTime)
    % Set the time
    s.setTime(validTime(i));
    % 
    if i == 1
       ikSolver.assemble(s); 
    end
        % run the iksolver for the time
        ikSolver.track(s);
    end
    % Get the marker errors
    for u = 0 : nM - 1
           errors(i,u+1) =  ikSolver.computeCurrentMarkerError(u);
    end
    % Get the Model Marker Locations
    for u = 0 : nM - 1
            location =  ikSolver.computeCurrentMarkerLocation(u);
            locations(i,(u+1)*3-2:(u+1)*3) = [location.get(0) location.get(1) location.get(2)]; 
    end
    % Get the Coordinates Values
    model.realizeVelocity(s);
    % Get the coordinate Set
    cs = model.getCoordinateSet();
    nvalues = cs.getSize();
    for u = 0 : nvalues - 1
        angles(i,u+1) = cs().get(u).getValue(s);
    end
end

%% Pack the angles 
anglesPacked = struct();
for u = 0 : nvalues - 1
    name = char(cs.get(u).getName());
    if ~isempty(strfind(name,'tx')) || ~isempty(strfind(name,'ty')) || ~isempty(strfind(name,'tz'))
        eval(['anglesPacked.' char(cs.get(u).getName()) '= angles(:,u+1);'])
    else
        % Angles are in rad. Convert to deg
        eval(['anglesPacked.' char(cs.get(u).getName()) '= rad2deg(angles(:,u+1));'])
    end
end

anglesPacked.time = [validTime(1):dt:validTime(end)]';


end