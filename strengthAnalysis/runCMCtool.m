function resultsFolderPath =  runCMCtool(path2setupFile, modelOutputPath)


import org.opensim.modeling.*      % Import OpenSim Libraries

%% cmcTool
cmcTool = CMCTool( path2setupFile );

%% Change some variables

if nargin == 2
    %Set the model file name path
    cmcTool.setModelFilename(modelOutputPath);
    % get output path from the model path
    [workingFolder, fname, ext ] = fileparts(modelOutputPath);
    % Set the results path
    resultsFolderPath = fullfile(workingFolder, strrep(fname,'myModel','cmc' ));
end


% Change the results folder
cmcTool.setResultsDir(resultsFolderPath);
% set the subject name
cmcTool.setName('')

display('Running CMC....')
%% Run CMC
cmcTool.run();


%% Success noise
load chirp 
sound(y,Fs)


end