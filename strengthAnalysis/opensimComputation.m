function [t q] = opensimComputation(homeFolder,workingFolder,cmcSetupName,modelName,muscleNames,currentValue )

    modelPath = fullfile(homeFolder, modelName);
    scaledModelPath = strengthScaler(modelPath,muscleNames,currentValue,workingFolder);
    cmcSetupPath = fullfile(homeFolder,cmcSetupName);
    % the the CMC tool 
    resultsFolderPath =runCMCtool(cmcSetupPath,scaledModelPath);
    % read in results and save to q and t
    t = importdata( fullfile( resultsFolderPath, '_Actuation_force.sto'));
    q = importdata( fullfile( resultsFolderPath, '_Kinematics_q.sto'   ));
 
end
