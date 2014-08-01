function muscles = getCoord4Musc( myModel,state )
% Muscle Coordinate finder
%   Find the coordinate's that each muscle crosses. This is done by
%   examining the moment arm contribution of the muscle across all
%   coordinates. A muscle will contribute to any coodinate when the moment
%   arm is non-zero.

import org.opensim.modeling.*      % Import OpenSim Libraries

nMusc = myModel.getMuscles().getSize();
nCoord = myModel.getCoordinateSet().getSize();

for i = 0 : nMusc-1
    % get the muscles type buy getting the concrete Class Name
    myForce = myModel.getMuscles().get(i);
    muscleType = char(myForce.getConcreteClassName);

    % get a reference to the concrete muscle class in the model
    eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])

    % get a fresh matrix to dump coordinate values into 
    momentArm_aCoord =[];
    
    % iterate through coordinates, finding non-zero moment arm's
    for k = 0 : nCoord -1
        % get a reference to a coordinate
        aCoord = myModel.getCoordinateSet.get(k);
        % compute the moment arm of the muscle for that coordinate given
        % the state. 
        momentArm_aCoord(k+1) = myMuscle.computeMomentArm(state,aCoord);
    end
    
    x = round((momentArm_aCoord*1000))/1000;
    
    
    muscCoord = find(x ~= 0)-1;
    
    eval(['muscles.' char(myModel.getMuscles().get(i).getName) '.coordinates = muscCoord;' ])
end 


end

