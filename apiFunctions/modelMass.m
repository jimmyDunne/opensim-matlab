function modelStruct = modelMass(varargin)

import org.opensim.modeling.*      % Import OpenSim Libraries

nModels = nargin;


for i = 1 : nModels
     path(i) = varargin(i);
end



%%
for u = 1 : nModels

    myModel = Model( char(path(u)));
    nBodies = myModel.getBodySet.getSize();
    for i = 1 : nBodies
           tempBody =  myModel.getBodySet.get(i-1);
           j(i) = {char(tempBody.getName)};
           m(i,1) = tempBody.getMass;
    end
    
    
    modelStruct.(['model' num2str(u)]).bodyNames  = j';
    modelStruct.(['model' num2str(u)]).bodyMasses = m;
    modelStruct.(['model' num2str(u)]).totalMass = sum(m);    
    
    clear j
    clear m 
end



end