function [ output_args ] = Untitled( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here








% steep ascend < 0.75
% shallow ascend 0.75 < 0.95
% plateau 0.95 < 1.05
% descending limb 1.05 < 0.75


MuscNames = fieldnames(muscles);

%%
ii = 34;

for ii = 1 : length(MuscNames)
    
    fiberLengthNorm  = muscles.(MuscNames{ii}).motion.data(:,2);
    steepAscend = find( fiberLengthNorm < 0.75 ) ; 
    shallowAscend = find( 0.75 > fiberLengthNorm < 0.95 ) ; 
    plateau = find( 1.05 > fiberLengthNorm < 0.95 ) ;
    descendingLimb = find(fiberLengthNorm > 1.05 );
    
    totalFrames = length(muscles.(MuscNames{ii}).motion.data(:,2));
    nSteepAscend = length(steepAscend) ;
    nShallowAscend = length(shallowAscend) ;
    nPlateau = length(plateau) ;
    nDescendingLimb = length(descendingLimb) ; 
    
    
    percents = [nSteepAscend nShallowAscend nPlateau nDescendingLimb]*100/totalFrames;
    

    
    
    activeFiberForce = muscles.(MuscNames{ii}).motion.data(:,3);
    passiveFiberForce = muscles.(MuscNames{ii}).motion.data(:,4);

    flCurveFiberLength       = muscles.(MuscNames{ii}).forceLength(:,1);
    flCurveFiberActiveforce  = muscles.(MuscNames{ii}).forceLength(:,2);
    flCurveFiberPassiveforce = muscles.(MuscNames{ii}).forceLength(:,3);

    hold on    
    data = [flCurveFiberLength flCurveFiberActiveforce]
    B = sortrows(data,1)
    plot(B(:,1),B(:,2), 'k')

    
    data = [fiberLengthNorm activeFiberForce]
    B = sortrows(data,1)
    plot(B(:,1),B(:,2) ,'r')
    
    
end



end