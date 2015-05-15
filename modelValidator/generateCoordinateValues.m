function [coordinateValues coordinateSpeeds] = generateCoordinateValues(myModel,state,muscleName,muscleCoordinates)

% Import OpenSim Libraries
import org.opensim.modeling.*      


% get he number of coordinates and the coordinate names
coordNames = fieldnames(muscleCoordinates);
nCoords = length( coordNames ); 

% define some (empty) storage space
coordinateValues = [];
%define the coodinate sppeds
coordSpeeds = deg2rad( [-120:1:120] )';

% get the default values of the coordinates
for i = 1 : nCoords
    defaultValue(i) = myModel.getCoordinateSet.get(coordNames{i}).getDefaultValue;
end

% Generate an array of coordinate values for a model.
for i = 1 : nCoords
    % get the current coordinate name
    coordNames = fieldnames(muscleCoordinates);
    % Define the coordinate 
    coordRange = muscleCoordinates.(coordNames{i}).coordValue;
    % Create a simple array of default values that is the same length as
    % the coordRange. 
    defaultMatrix = repmat(defaultValue,[length(coordRange) 1]);
    % Put in the coordinate range data into the tempory matrix
    defaultMatrix(:,i) = coordRange;
    % append row to the main storage array
    coordinateValues = [coordinateValues;defaultMatrix];
end



for i = 1 : length(coordinateValues)
     
      for j = 1 : nCoords
        updCoord = myModel.updCoordinateSet.get(coordNames{j});
        updCoord.setValue(state,  coordinateValues( i , j ) );
      end
   
     % Equilibrate the forces from the activation 
     myModel.equilibrateMuscles( state ); 

     % Store all the data in the zero matrix
     nFiberLength = myModel.getMuscles.get(muscleName).getNormalizedFiberLength(state);
     
     if abs(round(nFiberLength - 1,3)) < 0.01
        
         coordinateSpeeds = zeros(size(coordinateValues));
         
         coordinateValues = [coordinateValues; repmat(coordinateValues(i,:), [length(coordSpeeds),1])];
          
         tempValues = zeros([length(coordSpeeds), nCoords]);   
         
         tempValues(:,find(coordinateValues(i,:) ~= 0)) = coordSpeeds;
            
         coordinateSpeeds = [coordinateSpeeds;tempValues];
         
          break
%          size(coordinateValues)
%          size(coordinateSpeeds)
     end
end

