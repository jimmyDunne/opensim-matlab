function modelValidator(modelName)


% Author: James Dunne, Ajay Seth, Chris Dembia, Tom Uchida.  
% Started: July 2014   

%% 

import org.opensim.modeling.*      % Import OpenSim Libraries


if nargin < 1
    [filein, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
    myModel = Model(fullfile(pathname,filein));
end

stateDefault =  myModel.initSystem();
state =  myModel.initSystem();

%% Muscle Coordinate finder
%   Find the coordinate's that each muscle crosses. This is done by
%   examining the moment arm contribution of the muscle across all
%   coordinates. A muscle will contribute to any coodinate when the moment
%   arm is non-zero.
tic
muscleCoordinates = getCoord4Musc( myModel , state);
toc
%% get the force length curves of 

% Get the force length curves of the muscles
muscles = getForceLength(myModel, state, muscles);

% Get the force/length curves during a motion
muscles = getfLfromMot(myModel, muscles );

% Under development or legacy functions 
% musclesNew = getfLfV(myModel, state, muscleStruct);
% musclesFromStates = getMusclesFromStates(myModel, statesFile, muscleStruct)


%% 









end


