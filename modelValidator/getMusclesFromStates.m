%function = getMusclesFromStates(myModel, statesFilePath, muscles )
%% Uses a states file to get the fLfV curves for each muscle. 
%
%
% 
% Author: James Dunne.  Date: August 2014
%

import org.opensim.modeling.*      % Import OpenSim Libraries


[filein, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
    myModel = Model(fullfile(pathname,filein));

myModel = Model('D:/testInstalls/OpenSim32_64bit_VC13/Models/Gait2392_Simbody/subject01_simbody_adjusted.osim');
fileToRead1 = 'C:/Users\vWin7/Documents/GitHub/stackJimmy/modelValidator/testData/subject01_walk1_ik.mot';



%% Import the file
newData1 = importdata(fileToRead1);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

[nFrames nStates] = size(data);


%% Get a reference to the model to state
s =  myModel.initSystem();

for u = 1 : nFrames

    % Set the state time
    s.setTime(data(1,1))    

    for i = 2 : nStates
        myModel.setStateVariable(s, char(colheaders(i)) , data(u,i) )
    end
 
    % At this point the system is only in stage ~1. To compute system
    % dynamics we need to realize the system upwards (further
    % reading:Simbody user manual). realize() is not exposed to users in
    % matlab (3.2) so we call computeStateVariableDerivatives which
    % realizes the system up to acc. 
    myModel.computeStateVariableDerivatives(s)
    
    for i = 1 : nMuscles - 1
        % get the muscles type buy getting the concrete Class Name
        myForce = myModel.getMuscles().get(i);
        muscleType = char(myForce.getConcreteClassName);
        % get a reference to the concrete muscle class in the model
        eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
        myMuscle.getActivation(s)
        % Equibilate the force's 
        myModel.equilibrateMuscles( state )
        % Store all the data in the zero matrix
        storageData(j,:) = [...
            rad2deg(coordValue) ...                       % Coordinate Value  
            myMuscle.getFiberLength(state) ...            % Fiber length
            myMuscle.getNormalizedFiberLength(state) ...  % Normalized Fibre Length  
            myForce.getActiveFiberForce(state)];          % Active Force
    end
  
    
end

