function [elapsedTime]= strengthTester_para(homeFolder, modelName, cmcSetupName, idName, c)
% Each muscle group was weakened in isolation. We reduced the maximum
% isometric force until the CMC algorithm could no longer determine a set of muscle
% excitations that would recreate the subject's dynamics with an error less than 2 degrees for all
% degrees of freedom and torques from the reserve actuators that were less than 10% of
% the maximum joint moment at each degree of freedom.
%
% We used the bisection method (Burden and Faires, 1985) to determine how much the maximum isometric
% force of each muscle group could be reduced. This method searches through the space
% of all possible values for the maximum isometric force by iteratively taking the middle
% of an interval representing the maximum and minimum possible values from previous
% iterations until it converges upon the minimum value that could recreate the subject's
% dynamics. This point was termed the required muscle strength for each muscle group
% and was expressed as a percent of the muscle group's maximum isometric force.

import org.opensim.modeling.*      % Import OpenSim Libraries

%% get the path to the model and cmc setup file

% get the path to the model
if ~nargin 
    [modelName, homeFolder] = uigetfile('*.osim', 'OSIM model file...');
    [cmcSetupName, homeFolder]   = uigetfile({'*.xml'}, 'CMC setup file...',homeFolder);
    [idName, homeFolder]   = uigetfile({'*.sto'}, 'Inverse Dynamics...',homeFolder);
    cd(homeFolder);
    c = 1;
end
% Inverse Dynamics

m = importdata(fullfile(homeFolder,idName));

cd(homeFolder)
%% get muscle ans exclusion names
[muscGroups, excludeList] = readGroupNames;

%%
groupNames = fieldnames(muscGroups);
nGroups    = length(groupNames);
percentageStrength = fliplr([5:5:100]); 

startLoop = tic;

parfor i = 1 : nGroups
    display( char(groupNames{i}) );
    % Results folder name
    workingFolder = fullfile(homeFolder,[ 'ResultsCMC_' char(groupNames{i})]) ;

    % if the folder doesnt already exist, create it. This is due to CMC
    % having issues with printing to a folder that doesnt exist. 
    if exist(workingFolder)
        continue
    else
        mkdir(workingFolder)
    end
    
   % Define the muscles to reduce  
   muscleNames  =    muscGroups.(groupNames{i});

   for u = 1 : length(percentageStrength)
      opensimComputation(homeFolder,workingFolder,cmcSetupName,modelName,muscleNames,char(groupNames{i}),percentageStrength(u) );
   end
   
end

elapsedTime = toc(startLoop);

gmailEmail('The beast has finished her simulations',...
            'simulation is finished')


end

