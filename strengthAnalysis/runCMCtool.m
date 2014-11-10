function [t q] = runCMCtool(pathName, cmcSetupName, modelOutputPath)

import org.opensim.modeling.*      % Import OpenSim Libraries
 

   
[workingFolder, fname, ext ] = fileparts(modelOutputPath);


%% CMC Tool 
cmcPath   = fullfile(pathName, cmcSetupName );
% create an instance of the cmcTool
cmcTool = CMCTool(cmcPath);

%%  Change some things  

%Set the model file name path
cmcTool.setModelFilename(modelOutputPath);

% Set the results path
resultsPath = fullfile(workingFolder, strrep(fname,'myModel','cmc' ));
cmcTool.setResultsDir(resultsPath);
% set the subject name
cmcTool.setName('')

%% run cmc
cmcTool.run();

%% read in results and save to q and t

t = importdata( fullfile( pathName, resultsFolder, ['testRun_' num2str(n)], 'subject01_Actuation_force.sto'));
q = importdata( fullfile( pathName, resultsFolder, ['testRun_' num2str(n)], 'subject01_Kinematics_q.sto'   ));

%% Print the Model to the cmc folder

load chirp 
sound(y,Fs)


end