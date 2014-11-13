function [t q] = opensimComputation(homeFolder,workingFolder,cmcSetupName,modelName,muscleNames,currentValue )

    modelPath = fullfile(homeFolder, modelName);
    scaledModelPath = strengthScaler(modelPath,muscleNames,currentValue,homeFolder);
    
    % need to get the new model name for moving later
    [tempFolder, modelName, ext ] = fileparts(scaledModelPath);
 
    cmcSetupPath= fullfile(homeFolder,cmcSetupName);
    
    % the the CMC tool 
    display(['mCapacity; ' num2str(currentValue)]);
    resultsFolderPath = runCMCtool(cmcSetupPath,scaledModelPath,workingFolder);

    [workingFolder, extName, ext ] = fileparts(resultsFolderPath);
    % read in results and save to q and t
    t = importdata( fullfile( resultsFolderPath, '_Actuation_force.sto'));
    q = importdata( fullfile( resultsFolderPath, '_Kinematics_q.sto'   ));
 
    % move the model out of the current folder into the workking folder
    movefile( scaledModelPath, fullfile(resultsFolderPath,[modelName ext]) )
                 
end
