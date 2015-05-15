function muscles = getfLfV(myModel, state, muscleName, muscleCoordinates)

import org.opensim.modeling.*      % Import OpenSim Libraries

% Get the muscle that is needed 
myForce = myModel.getMuscles().get(muscleName);
% Get the muscleType of that myForce 
muscleType = char(myForce.getConcreteClassName);
% Get a reference to the concrete muscle class in the model
eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
% Display the muscle name
display(char(myMuscle))

% Get the coordinate names for the muscle
coordNames = fieldnames(muscleCoordinates);
% get the number of coordinates for the muscle
nCoords = length( coordNames ); 
% matrix for storing the total complete fl curve 
flMatrix = zeros(2,4);  

% get an array of coodinaate values and speeds to set the pose of the model
[coordinateValues coordinateSpeeds] = generateCoordinateValues(myModel,state,muscleName, muscleCoordinates);

nFrames = length(coordinateValues);

flfvCurve = [];

state =  myModel.initSystem();


for i = 1 : nFrames
     
    % Loop through and update the model coordinate value's
    for j = 1 : nCoords
        updCoord = myModel.updCoordinateSet.get(coordNames(j));
        updCoord.setValue(state,  coordinateValues(i, j ) );
        updCoord.setSpeedValue(state, rad2deg(coordinateSpeeds(i, j )));
    end
    
        % Set the activation and fiber length
        myMuscle.setActivation( state, 1 )
        myMuscle.setDefaultFiberLength( 0.01 )
        myMuscle.setFiberLength( state, myMuscle.getOptimalFiberLength )
        % Equilibrate the forces from the activation 
        myModel.equilibrateMuscles( state );
   
     % Store all the data in the zero matrix
     rowData = [...
        myMuscle.getFiberLength(state) ...    
        myMuscle.getFiberVelocity(state) ...
        myMuscle.getNormalizedFiberLength(state) ...
        myMuscle.getNormalizedFiberVelocity(state) ...   
        myMuscle.getActiveFiberForce(state) ...
        myMuscle.getPassiveFiberForce(state) ...      
        myMuscle.getTendonLength(state) ...             
        myMuscle.getTendonForce(state)];              

        flfvCurve = [flfvCurve;rowData];
end



flcurve = flfvCurve(find( sum(coordinateSpeeds,2) == 0 ), :); 
flcurve(end,:) = [];

fvcurve = flfvCurve(find( sum(coordinateSpeeds,2) ~= 0 ), :); 
fvcurve(end,:) = [];





















 



