%function = getMusclesFromStates(myModel, statesFilePath, muscles )
%% Uses a states file to get the fLfV curves for each muscle. 
%
%
% 
% Author: James Dunne.  Date: August 2014
%

import org.opensim.modeling.*      % Import OpenSim Libraries

myModel = Model('D:/testInstalls/OpenSim32_64bit_VC13/Models/Gait2392_Simbody/subject01_simbody_adjusted.osim');
statesFilePath = 'D:/testInstalls/OpenSim32_64bit_VC13/Models/Gait2392_Simbody/ResultsCMC/subject01_walk1_states.sto'


s =  myModel.initSystem();


%% Read in a states file as a storage object
stateStorage = Storage([statesFilePath])

% get the name of the file
statesName = f.getName()

% get the time variables
firstTime = f.getFirstTime();
lastTime = f.getLastTime();


nSteps = f.getSize


g = State()

aStatesStore = Storage()



for i = 0 : nSteps - 1

    % state = f.getStateVector(i)





    myModel.formStateStorage(stateStorage, aStatesStore)

    labels = aStatesStore.getColumnLabels()



    numOpenSimStates = labels.getSize()-1


    stateData = Vector();


    stateData.resize(numOpenSimStates);

     



    aStatesStore.getData(i, numOpenSimStates , stateData );


    aStatesStore.getData(i ,numOpenSimStates, &stateData[0]); // states
    
        // Get data into local Vector and assign to State using common utility
        // to handle internal (non-OpenSim) states that may exist
    
        Array<std::string> stateNames = aStatesStore.getColumnLabels();


        for (int j=0; j<stateData.size(); ++j){
            // storage labels included time at index 0 so +1 to skip

            aModel.setStateVariable(s, stateNames[j+1], stateData[j]);


    % Loop through each coordinate value and get get the fibre
           % length and force of the muscle. 
           % for j = 1 : length( coordRange )
           %      % Get a current coordinate value
           %      coordValue = coordRange(j);
           %      % Set the coordinate value in the state
           %      updCoord.setValue(state, coordValue);
           %      % Set the speed of the Coordinate Value
           %      updCoord.setSpeedValue(state, 0 );
           %      % Set the activation and fiber length
           %      myMuscle.setActivation( state, 1 )
           %      myMuscle.setDefaultFiberLength( 0.01 )
           %      myMuscle.setFiberLength( state, 0.01 )
                
           %      % Equilibrate the forces from the activation 
           %      myModel.equilibrateMuscles( state )
           %      % Store all the data in the zero matrix
           %      storageData(j,:) = [...
           %          rad2deg(coordValue) ...                        % Coordinate Value  
           %          myMuscle.getFiberLength(state) ...            % Fiber length
           %          myMuscle.getNormalizedFiberLength(state) ...  % Normalized Fibre Length  
           %          myForce.getActiveFiberForce(state)];          % Active Force
           % end






end















%end