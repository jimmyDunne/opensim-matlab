function [torqueDta coordData] = runCMCtool(mStrength, pathname, filein)

    import org.opensim.modeling.*      % Import OpenSim Libraries

    cmcTool = CMCTool(fullfile(pathname,filein));

%% set the path's for some variables

    controlConstraintsPath  = fullfile(pathname,'gait2392_CMC_ControlConstraints.xml'  );
    tasksPath               = fullfile(pathname,'gait2392_CMC_Tasks.xml' );
    externalLoadFilePath    = fullfile(pathname,'subject01_walk1_grf.xml');
    coordinatesFilePath     = fullfile(pathname,'ResultsRRA', 'subject01_walk1_RRA_Kinematics_q.sto' );
    modelFilePath           = fullfile(pathname,'ResultsCMC', ['myModel_' num2str(mStrength) '.osim']);
    resultsPath             = fullfile(pathname,'ResultsCMC', ['testRun_' num2str(mStrength)]);
    
%% Change the output folder path from CMCSetup

    cmcTool.setModelFilename(modelFilePath);
    cmcTool.setConstraintsFileName(controlConstraintsPath);
    cmcTool.setTaskSetFileName(tasksPath);
    cmcTool.setDesiredKinematicsFileName(coordinatesFilePath);
    cmcTool.setInitialTime(0.53);
    cmcTool.setFinalTime(0.7);
    cmcTool.setResultsDir(resultsPath);
    cmcTool.setExternalLoadsFileName(externalLoadFilePath);
    cmcTool.setName('subject01')
    % Save the settings in a setup file
    cmcTool.print( fullfile(pathname, filein) );
    cmcTool = CMCTool(fullfile(pathname,filein));

%% run cmc
    cmcTool.run()

%% read in results and save to q and t

    torqueDta = importdata( fullfile( pathname, 'ResultsCMC', ['testRun_' num2str(mStrength)], 'subject01_Actuation_force.sto'));
    coordData = importdata( fullfile( pathname, 'ResultsCMC', ['testRun_' num2str(mStrength)], 'subject01_Kinematics_q.sto'   ));

%% Print the Model to the cmc folder

    load chirp 
    sound(y,Fs)
end