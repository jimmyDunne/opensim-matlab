





import org.opensim.modeling.*      % Import OpenSim Libraries


% get the list of muscles that you want to do analysis on 
    % are we doing this on all the muscles or just a subset?
    
%% get path to a model 
[modelFileName, modelFilePath] = uigetfile({'*.osim','osim'}, 'OSIM model file...');

%% get the path to a motion to use in analysis?
[motionFileName, motionFilePath] = uigetfile({'*.mot','mot'}, 'MOT motion file...');

%% get the list of muscles I want to examine. 


%% generate an instance of the model.  
myModel = Model(fullfile(modelFilePath,modelFileName));    
    
    
%% define a couple of variable of interest.     
nCoord = myModel.getCoordinateSet().getSize();
nMusc = myModel.getMuscles().getSize();
stateDefault =  myModel.initSystem();
state =  myModel.initSystem();

%% get the list of muscles in the model 
% get an empty array for the muscle names
nameArray = ArrayStr;
% fill the array wil the names of the muscles
myModel.getMuscles().getNames(nameArray)

% fill a maltab array with the muscle names
for i = 0 : nameArray.getSize - 1
    muscleNames(i+1,1) = {char(nameArray.get(i))};
end


%%
for i = 1 : length(muscleNames)    
    
    % the muscle
    muscleName = muscleNames{i}; 
    % get the coordiantes of interest for this muscle  
    muscleCoordinates = getCoord4Musc_draft(myModel,state,muscleName); 
    
    % get the aggregate force-length-velocity curve of the muscle. 
    
    
    
    
    
    

end


























