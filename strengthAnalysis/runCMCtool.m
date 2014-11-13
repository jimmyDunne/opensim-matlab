function resultsFolderPath =  runCMCtool(path2setupFile, modelOutputPath, resultsFolder)


import org.opensim.modeling.*      % Import OpenSim Libraries

%% cmcTool
cmcTool = CMCTool( path2setupFile );

%% Change some variables

if nargin > 1 
    %Set the model file name path
    cmcTool.setModelFilename(modelOutputPath);
    % get output path from the model path
    [workingFolder, fname, ext ] = fileparts(modelOutputPath);
end

% Change the results folder
resultsFolderPath = fullfile(resultsFolder,fname);
cmcTool.setResultsDir(resultsFolderPath);
% set the subject name
cmcTool.setName('')

display('Running CMC....')
%% Run CMC
cmcTool.print([workingFolder '\testSetup.xml'] );
cmcTool = CMCTool( [workingFolder '\testSetup.xml'] );
cmcTool.run();

close all
%% Success noise
load chirp 
sound(y,Fs)


end