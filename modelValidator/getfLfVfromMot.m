%function = getMusclesFromss(myModel, ssFilePath, muscles )
%% Uses a ss file to get the fLfV curves for each muscle. 
%
%
% 
% Author: James Dunne.  Date: August 2014
%

import org.opensim.modeling.*      % Import OpenSim Libraries


[filein, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
    myModel = Model(fullfile(pathname,filein));

myModel = Model('D:/testInstalls/OpenSim32_64bit_VC13/Models/Gait2392_Simbody/subject01_simbody_adjusted.osim');
fileToRead1 = 'D:/Repo/GitHub/stackJimmy/modelValidator/testData/subject01_walk1_ik.mot';



%% Import the file
newData1 = importdata(fileToRead1);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

[nFrames nss] = size( data );


%% Get a reference to the model to s
s =  myModel.initSystem();

%%
[nFrames nCoord] = size(data);
if ~isempty( strmatch( 'time', char(colheaders(1)) ) )
    colheaders(:,1) = [];
    data(:,1) = [];
end
[nFrames nCoords] = size(data);


%% check that all the given coordinates are in the model
tempRef = [];
for i = 1 : myModel.getCoordinateSet.getSize
    tempRef = [tempRef {char( myModel.getCoordinateSet.get(i-1).getName )} ];
end

for i = 1 : nCoord 
   
   if isempty( strmatch( char(colheaders(i)) , tempRef ) ) 
        error(['coordinate ' char(colheaders(i)) ' isnt in the model'])  
   end
end

%%

% Set the coordinates of the model 

for ii = 1 : nMuscles

   % Get the muscle that is needed 
   myForce = myModel.getMuscles().get(char(MuscNames(ii)));
   % Get the muscleType of that myForce 
   muscleType = char(myForce.getConcreteClassName);
   % Get a reference to the concrete muscle class in the model
   eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
   % Display the muscle name
   display(char(myMuscle))
   

   for j = 1 : nFrames
        % Set the pose of the model from the mot file
        for u = 1 : nCoords
            updCoord = myModel.updCoordinateSet.get( char(colheaders(u)) );
            updCoord.setValue(s, data(j,u));
        end

        % Set the activation and fiber length
        myMuscle.setActivation( s, 1 )
        myMuscle.setFiberLength( s, 0.01 )
        
        % Equilibrate the forces from the activation 
        myModel.equilibrateMuscles( s )

        % Get the Fiber force
        fiberlength(j,1)            = myMuscle.getFiberLength(s);
        fiberlengthNorm(j,1)        = myMuscle.getNormalizedFiberLength(s);

        fiberActiveForce(j,1)       = myForce.getActiveFiberForce(s);
        fiberPassiveForce(j,1)      = myForce.getPassiveFiberForce(s);

        % get tendon dynamics
        tendonLength(j,1)   = myForce.getTendonLength(s);
        tendonForce(j,1)    = myForce.getTendonForce(s);
   end      
    
    
end

fiberlength            = [];
fiberlengthNorm        = [];

fiberActiveForce       = [];
fiberPassiveForce      = [];

% get tendon dynamics
tendonLength   = [];
tendonForce    = [];





   % Get the maximum contraction velocity. This is in fibre length's per
   % second. 
   %%

   for k = 1 : nCoords
       % Get the name of the coordinate
       aCoord = myModel.getCoordinateSet.get( char(coordNames(k)) );
       % Get an update reference to the coordinate
       updCoord = myModel.updCoordinateSet.get( char(coordNames(k)) );
       % Get the coordinate values from the existing structure 
       coordRange = muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValue;
       
       
           % Loop through each coordinate value and get get the fibre
           % legnth's, fiber velocities force's. 
           for j = 1 : length( coordRange )
                % Get a current coordinate value
                coordValue = coordRange(j);
                % Set the coordinate value in the s
                updCoord.setValue(s, coordValue);
                
                % Set the activation and fiber length
                myMuscle.setActivation( s, 1 )
                myMuscle.setFiberLength( s, 0.01 )
                
                % Set the speed of the Coordinate Value
                updCoord.setSpeedValue(s, 0 );
                % Equilibrate the forces from the activation 
                myModel.equilibrateMuscles( s )

                
                for i = 1 : length(velocities)
                    
                    % Set the speed of the Coordinate Value
                    updCoord.setSpeedValue(s, velocities(i) );

                    % Equilibrate the forces from the activation 
                    myModel.equilibrateMuscles( s );
                    
                    coordSpeedArray(j,i) = rad2deg(velocities(i));
                    coordValueArray(j,i) = rad2deg(coordValue);
                    fiberlength(j,i) = myMuscle.getFiberLength(s);
                    fiberlengthNorm(j,i) = myMuscle.getNormalizedFiberLength(s);
                    
                    % Get the Fiber velocity
                    fiberVelocity(j,i) = myMuscle.getFiberVelocity(s);
                    % Get the Normalised Fiber Velocity 
                    fiberVelocityNorm(j,i) = myMuscle.getNormalizedFiberVelocity(s);
                    % Get the Fiber force
                    fiberForce(j,i)    = myForce.getActiveFiberForce(s);
   
                end
           end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    for i = 2 : nss
        
        myModel.setsVariable(s, char(colheaders(i)) , data(u,i) )
    
    end
 
    % At this point the system is only in stage ~1. To compute system
    % dynamics we need to realize the system upwards (further
    % reading:Simbody user manual). realize() is not exposed to users in
    % matlab (3.2) so we call computesVariableDerivatives which
    % realizes the system up to acc. 
    myModel.computesVariableDerivatives(s)
    
    for i = 1 : nMuscles - 1
        % get the muscles type buy getting the concrete Class Name
        myForce = myModel.getMuscles().get(i);
        muscleType = char(myForce.getConcreteClassName);
        % get a reference to the concrete muscle class in the model
        eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
        myMuscle.getActivation(s)
        % Equibilate the force's 
        myModel.equilibrateMuscles( s )
        % Store all the data in the zero matrix
        storageData(j,:) = [...
            rad2deg(coordValue) ...                       % Coordinate Value  
            myMuscle.getFiberLength(s) ...            % Fiber length
            myMuscle.getNormalizedFiberLength(s) ...  % Normalized Fibre Length  
            myForce.getActiveFiberForce(s)];          % Active Force
    end
  
    
end

