function muscles = getfLfromMot(myModel, muscles )
%% Uses a ss file to get the fLfV curves for each muscle. 
%
%
% 
% Author: James Dunne.  Date: August 2014
% muscles = getfLfromMot(myModel, muscles )

import org.opensim.modeling.*      % Import OpenSim Libraries


if nargin == 0
    [filein, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
    myModel = Model(fullfile(pathname,filein));
    state =  myModel.initSystem();
    muscles = getCoord4Musc( myModel , state);
elseif nargin == 1
    state =  myModel.initSystem();
    muscles = getCoord4Musc( myModel , state);
end

%% Get the motion file name and import the data
[motFile, pathname] = uigetfile({'*.mot','mot'}, 'Motion file...');

% set the path to file
motionFilePath = fullfile(pathname,motFile);

% Import the file
newData1 = importdata(motionFilePath);
colheaders = newData1.colheaders;
data = newData1.data;


%% Take out the time colomn from the data
[nFrames nCoord] = size(data);
if ~isempty( strmatch( 'time', char(colheaders(1)) ) )
    colheaders(:,1) = [];
    data(:,1) = [];
end
[nFrames nCoords] = size(data);


%% check that all the given coordinates are in the model
tempRef = [];
for i = 1 : myModel.getCoordinateSet.getSize
    % get a list of all the coordinates in the model 
    tempRef = [tempRef {char( myModel.getCoordinateSet.get(i-1).getName )} ];
end

for i = 1 : nCoords 
   % compare each motion file colheader against the list of coordinates
   % from the model
   if isempty( strmatch( char(colheaders(i)) , tempRef ) ) 
        error(['coordinate ' char(colheaders(i)) ' isnt in the model'])  
   end
end

%% get some variables prior to going into main loop  

% list of muscle name's from the input structure
MuscNames = fieldnames(muscles);
% generate a fresh state
s =  myModel.initSystem();
% zero matrix for dumping data
storageData = zeros(nFrames, 6);  


%% For each muscle and each row of data, set the coordinates values 
  % of the model, run equilibrateMuscles.  

for ii = 1 : length(MuscNames)

   % Get the muscle that is needed 
   myForce = myModel.getMuscles().get(char(MuscNames(ii)));
   % Get the muscleType of that myForce 
   muscleType = char(myForce.getConcreteClassName);
   % Get a reference to the concrete muscle class in the model
   eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
   % Display the muscle name
   display(char(myMuscle))
   

   for k = 1 : nFrames
     
           % Loop through and updated the model coordinate value's
           for j = 1 : myModel.updCoordinateSet.getSize
                updCoord = myModel.updCoordinateSet.get( j-1 );
                updCoord.setValue(s,  deg2rad(data(k, j )) );
                updCoord.setSpeedValue(s, 0 );
           end
                
                % Set the activation and fiber length
                myMuscle.setActivation( s, 1 )
                myMuscle.setDefaultFiberLength( 0.01 )
                myMuscle.setFiberLength( s, 0.01 )
                
                % Equilibrate the forces from the activation 
                myModel.equilibrateMuscles( s )

                % Store all the data in the zero matrix
                storageData(k,:) = [...
                    myMuscle.getFiberLength(s) ...            % Fiber length
                    myMuscle.getNormalizedFiberLength(s) ...  % Normalized Fibre Length  
                    myMuscle.getActiveFiberForce(s) ...       % active fiber force  
                    myMuscle.getPassiveFiberForce(s) ...      % passive fibre forces  
                    myMuscle.getTendonLength(s) ...           % tendon lengths  
                    myMuscle.getTendonForce(s) ...            % tendon force's  
                    ];         
                
   end

   % store the data in the output struct
   muscles.(MuscNames{ii}).motion.data = storageData;
end
