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
muscles = getCoord4Musc( myModel , state );

%% 
MuscNames = fieldnames(muscles);
actualAngle=[];

%%
tic
for ii = i : length(MuscNames)

   muscleIndex = ii-1;
   myForce = myModel.getMuscles().get(muscleIndex);
   muscleType = char(myForce.getConcreteClassName);
   % get a reference to the concrete muscle class in the model
   eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
   
   eval([ 'coords = muscles.' char(MuscNames(ii)) '.coordinates;' ]) 
   
   display(char(myMuscle))
   
   for k = 1 : length(coords)
       
       coord = coords(k);

       aCoord = myModel.getCoordinateSet.get(coord);
       
       updCoord = myModel.updCoordinateSet.get(coord);

       tempMat =[];
       actualAngle = [];
       fiberlength = [];
       normFiberLength = [];
       activeForce =[];
       
       for angle = aCoord.getRangeMin :0.01: aCoord.getRangeMax
            
            updCoord.setValue(state, angle);

            updCoord.setSpeedValue(state, 0 );

            %for i = 0.05:0.01:1
            for i = 1
                
               myMuscle.setActivation(state,i)
               myMuscle.setDefaultFiberLength(0.01)
               myMuscle.setFiberLength(state,0.01)

               myModel.equilibrateMuscles(state)
    
               myMuscle.getActivation(state);
               
               fiberlength =        [fiberlength myMuscle.getFiberLength(state)];
               normFiberLength =    [normFiberLength myMuscle.getNormalizedFiberLength(state)];
               activeForce =        [activeForce myForce.getActiveFiberForce(state)];
               actualAngle =        [actualAngle rad2deg(angle)];
           
            end

       end
       
            activeForce     = activeForce';
            actualAngle     = actualAngle';
            normFiberLength = normFiberLength';
            fiberlength     = fiberlength';

            eval(['muscles.' char(myForce) '.' char(aCoord) ' = [actualAngle fiberlength normFiberLength activeForce];'])
            
            updCoord.setValue(state, 0);

   end
   
   
end
toc
%%


     passiveForce(r) = muscles.get(12).getPassiveFiberForce(state);
   
    % force variables
     getActiveFiberForce
     getFiberForce
     getTendonForce
     
    % length/velocity
     getFiberLength
     getFiberVelocity

     % normalized velocity and length. 
     getNormalizedFiberLength
     getNormalizedFiberVelocity
     
     
     

for i = -120:1:0
    
    r = r+1;
        
    
    ;

    angle(r) = i;          

end

plot(angle,passiveForce,'r')


The assumptions made by the GUI/plotter are that:
1. Muscle Activation(s) = 1
2. Muscle FiberLength(s) = default value of .01 I believe

3. equilibrateMuscles on the whole model is invoked. The values specified in 1. & 2. above are used as initial conditions to solve for muscle equilibrium.

Since you don't do 1 & 2 I'd expect the results to be different. 

Hope this helps,
-Ayman


end












