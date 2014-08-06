function muscles = getForceLength(myModel, state, muscles)

import org.opensim.modeling.*      % Import OpenSim Libraries

MuscNames = fieldnames(muscles);


for ii = 1 : length(MuscNames)

   % Get the muscle that is needed 
   myForce = myModel.getMuscles().get(char(MuscNames(ii)));
   % Get the muscleType of that myForce 
   muscleType = char(myForce.getConcreteClassName);
   % Get a reference to the concrete muscle class in the model
   eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
   % Display the muscle name
   display(char(myMuscle))
   
   % Get the coordinate names for the muscle
   coordNames = fieldnames( muscles.(MuscNames{ii}).coordinates );
   % get the number of coordinates for the muscle
   nCoords = length( coordNames ); 
   
   for k = 1 : nCoords
       % Get the name of the coordinate
       aCoord = myModel.getCoordinateSet.get( char(coordNames(k)) );
       % Get an update reference to the coordinate
       updCoord = myModel.updCoordinateSet.get( char(coordNames(k)) );
       % Get the coordinate values from the existing structure 
       coordRange = muscles.(MuscNames{ii}).coordinates.(coordNames{k});
       % Create a zero matrix for storing data
       storageData = zeros( length(coordRange), 4 );
       

           % Loop through each coordinate value and get get the fibre
           % length and force of the muscle. 
           for j = 1 : length( coordRange )
                % Get a current coordinate value
                coordValue = coordRange(j);
                % Set the coordinate value in the state
                updCoord.setValue(state, coordValue);
                % Set the speed of the Coordinate Value
                updCoord.setSpeedValue(state, 0 );
                % Set the activation and fiber length
                myMuscle.setActivation( state, 1 )
                myMuscle.setDefaultFiberLength( 0.01 )
                myMuscle.setFiberLength( state, 0.01 )
                
                % Equilibrate the forces from the activation 
                myModel.equilibrateMuscles( state )
                % Store all the data in the zero matrix
                storageData(j,:) = [...
                    rad2deg(coordValue) ...                        % Coordinate Value  
                    myMuscle.getFiberLength(state) ...            % Fiber length
                    myMuscle.getNormalizedFiberLength(state) ...  % Normalized Fibre Length  
                    myForce.getActiveFiberForce(state)];          % Active Force
           end
        
        % Store the coordinate value fiberLength and active Fibre force   
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}) = storageData ;    
        % Reset the coordinate value back to zero
        updCoord.setValue(state, 0);
        
   end
end 