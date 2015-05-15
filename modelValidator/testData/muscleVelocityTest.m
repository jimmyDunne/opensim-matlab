


import org.opensim.modeling.*      % Import OpenSim Libraries

% build the model 
modelPath = 'subject01_simbody_adjusted.osim';
myModel = Model(modelPath);
state =  myModel.initSystem();

% Define an array of coordinate speeds (concentric (+) to eccentric (-) )
coordSpeeds = deg2rad( fliplr([-720:1:720]) )';

% Set the coordinate to move
coordName = 'hip_flexion_r';
updCoord = myModel.updCoordinateSet.get(coordName);
% Loop through and update the model coordinate 
updCoord.setValue(state,  0 );
% Set the activation
muscleName = 'rect_fem_r';
myMuscleIndex = myModel.getMuscles.getIndex(muscleName);
myMuscle = myModel.getMuscles.get(muscleName);
%myMuscle.getActivation(state)
myMuscle.setActivation( state, 1 )
myModel.equilibrateMuscles( state );

myMuscle.getActivation(state)
state2  = myModel.getWorkingState();

myMuscle.getActivation(state)
myMuscle.getActivation(state2)

    muscle = Thelen2003Muscle.safeDownCast(myMuscle);

    muscle.getForceVelocityMultiplier
    
    
    
% define an empty array
flfvCurve = [];

for i = 1 : length(coordSpeeds)
     
    updCoord.setSpeedValue(state, coordSpeeds(i) );
    
    updCoord.getSpeedValue(state);
    
    
    derivs = myModel.computeStateVariableDerivatives(state);
    
    MuscleSpeed(i) = myMuscle.getLengtheningSpeed(state);
    MuscleActuation(i) = myMuscle.computeActuation(state);
    
    g(i) = muscle.calcInextensibleTendonActiveFiberForce(state, 1);
    
    % the recFem fiber length is at position 164 of the 
    
%     for ii = 0 : derivs.size - 1 
%    
%       dots(i,ii+1) = derivs.get(ii);
%     
%     end
    
    hipflexQdot(i) = derivs.get(6); 
    
    myMuscle.getFiberVelocity(state);
    
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



% make a figure of the normalized velocity against force  
figure
scatter(flfvCurve(:,4),flfvCurve(:,5))
title('Rectus Femoris Force Vs Normalized Fiber Velocity')
xlabel('normalised fiber velocity')
ylabel('force')

% plot change in fiber lenth
figure
plot(flfvCurve(:,1))
title('Rectus Femoris Fiber Length')
xlabel('Time')
ylabel('normalised fiber length')


% plot change in fiber lenth
figure
plot(flfvCurve(:,4))
title('Rectus Femoris Fiber Velocity')
xlabel('Time')
ylabel('normalised fiber velocity')


% make a figure of the normalized length against force  
figure
scatter(flfvCurve(:,3),flfvCurve(:,5))
title('Rectus Femoris Force Vs Normalized Fiber Length')
xlabel('normalised fiber Length')
ylabel('force')





























