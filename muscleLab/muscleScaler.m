function muscleScaler(modelPath, mass, height)

import org.opensim.modeling.*      % Import OpenSim Libraries

% Define the specific tension of muscle in N/cm^2(Arnold) 
p = 30; %specificTension 
% load the model 
myModel   = Model(modelPath);
muscleSet = myModel.getMuscles();

for i = 0 : muscleSet.getSize()-1
   muscleNames(i+1,1)  =  {char(muscleSet.get(i).getName)};
end

%% Get the volume of the muscles in the model
% Get the muscle volume of the generic model
modelVolume   = HansFieldMuscleVolumeRegression(75.337, 1.7);
% Get the muscle volume of the subject
subjectVolume = HansFieldMuscleVolumeRegression(mass, height);

volScaleFac = subjectVolume/modelVolume;

[muscles] = musclePropList('musclePropertyList.txt');

musclePropNames = fieldnames(muscles);

masterIndex= [];
for i = 1 : length(musclePropNames) 
    
   % Find the index number matching the property list to the model  
   index = find(cellfun(@(x) ~isempty( strfind(x, char(musclePropNames(i)) ) ), muscleNames) == 1 );
   
  [pcsa, maxMuscleForce] = calcPCSA(muscles.(musclePropNames{i})(1)/100*subjectVolume,...
                                  muscles.(musclePropNames{i})(2),...
                                  muscles.(musclePropNames{i})(3),...
                                  p);
   
   muscleMaxForceCmp(i,:) = [muscleSet().get(index(1)-1).getMaxIsometricForce maxMuscleForce];
                              
   for u = 1 : length(index)                           
         muscleSet.get(index(u)-1).setMaxIsometricForce(maxMuscleForce);
   end
   
   masterIndex = [masterIndex;index];
end

display('Model Muscle strength updated') 

myModel.print(modelPath);

