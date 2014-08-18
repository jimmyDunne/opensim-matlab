function [t q] = runCMCtool(pathname,resultsFolder,muscles,n,cmcName,modelName)

    import org.opensim.modeling.*      % Import OpenSim Libraries
%% Model
    % get the paths to the model and setup files
    modelPath = fullfile(pathname, modelName);
    % create instance of the model 
    myModel = Model(modelPath);
    myModel.initSystem();
    % make the scaling factor a decimal (if 100% then 1, if 50% then 0.5
    scalingFactor = n/100;
    % multiply all muscles in the model by the scaling factor n
    for ii = 1 : length(muscles)
        b = myModel.getMuscles.get( muscles{ii} ).getMaxIsometricForce ;
        myModel.getMuscles.get( muscles{ii} ).setMaxIsometricForce( b*scalingFactor ) ;
    end
    % Print the model out to the results file, ready to be used by the
    % cmcTool
    modelOutputPath = fullfile(pathname, resultsFolder, ['myModel_' num2str(round(n)) '.osim']) ;
    myModel.print(modelOutputPath);
    
%% CMC Tool 
    cmcPath   = fullfile(pathname, cmcName );
    % create an instance of the cmcTool
    cmcTool = CMCTool(cmcPath);

    % set the path's for some variables
    %controlConstraintsPath  = fullfile(pathname,'gait2392_CMC_ControlConstraints.xml'  );
    forceSetFiles           = fullfile(pathname,'cmc_actuators_gait_23dofs_92muscles_patella.xml' );
    tasksPath               = fullfile(pathname,'tasks.xml' );
    externalLoadFilePath    = fullfile(pathname,'external_loads.xml');
    coordinatesFilePath     = fullfile(pathname,'loadedwalking_subject07_noload_free_trial01_rrakin_Kinematics_q.sto' );
    resultsPath             = fullfile(pathname,resultsFolder, ['testRun_' num2str(n)]);
    
%% Change the output folder path from CMCSetup

    cmcTool.setModelFilename(modelOutputPath);
    %cmcTool.setConstraintsFileName(controlConstraintsPath);
    cmcTool.setTaskSetFileName(tasksPath);
    cmcTool.setDesiredKinematicsFileName(coordinatesFilePath);
    %cmcTool.setForceSetFiles(forceSetFiles)
    cmcTool.setInitialTime(0.500);
    cmcTool.setFinalTime(1.6);
    cmcTool.setResultsDir(resultsPath);
    cmcTool.setExternalLoadsFileName(externalLoadFilePath);
    cmcTool.setName('subject01')
    %Save the settings in a setup file
    cmcTool.print( fullfile(pathname, resultsFolder, cmcName));
    cmcTool = CMCTool(fullfile(pathname, resultsFolder, cmcName));

%% run cmc
    cmcTool.run();

%% read in results and save to q and t

    t = importdata( fullfile( pathname, resultsFolder, ['testRun_' num2str(n)], 'subject01_Actuation_force.sto'));
    q = importdata( fullfile( pathname, resultsFolder, ['testRun_' num2str(n)], 'subject01_Kinematics_q.sto'   ));

%% Print the Model to the cmc folder

    load chirp 
    sound(y,Fs)


end