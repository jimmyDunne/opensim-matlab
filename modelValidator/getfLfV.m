function muscles = getfLfV(myModel, state, muscles)

import org.opensim.modeling.*      % Import OpenSim Libraries

MuscNames = fieldnames(muscles);



normVelocity = [-0.85:0.05:0.85];




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
   
   % Get the maximum contraction velocity. This is in fibre length's per
   % second. 
   velocities = normVelocity*mConVelocity
   %%
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
           % legnth's, fiber velocities force's. 
           for j = 1 : length( coordRange )
                % Get a current coordinate value
                coordValue = coordRange(j);
                % Set the coordinate value in the state
                updCoord.setValue(state, coordValue);
                
                % Set the activation and fiber length
                myMuscle.setActivation( state, 1 )
                myMuscle.setFiberLength( state, 0.01 )
                
                % Set the speed of the Coordinate Value
                updCoord.setSpeedValue(state, 0 );
                % Equilibrate the forces from the activation 
                myModel.equilibrateMuscles( state )

                
                for i = 1 : length(velocities)
                    % Set the speed of the Coordinate Value
                    updCoord.setSpeedValue(state, velocities(i) );

                    % Equilibrate the forces from the activation 
                    myModel.equilibrateMuscles( state );
                    
                    coordValueArray(j,i) = rad2deg(coordValue);
                    fiberlength(j,i) = myMuscle.getFiberLength(state);
                    fiberlengthNorm(j,i) = myMuscle.getNormalizedFiberLength(state);
                    
                    % Get the Fiber velocity
                    fiberVelocity(j,i) = myMuscle.getFiberVelocity(state);
                    % Get the Fiber force
                    fiberForce(j,i)    = myForce.getActiveFiberForce(state);
   
                end
           end
        
        % Store the coordinate value fiberLength and active Fibre force   
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).coordValue      = coordValueArray ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlength     = fiberlength ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberlengthNorm = fiberlengthNorm ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberVelocity   = fiberVelocity ; 
        muscles.(MuscNames{ii}).coordinates.(coordNames{k}).fiberForce      = fiberForce ; 
        
        % Reset the coordinate value back to zero
        updCoord.setValue(state, 0);
        scatter3(X,Y,Z)
   end
   %%
end 
