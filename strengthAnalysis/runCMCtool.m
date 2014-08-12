function [torqueDta coordData] = runCMCtool(mStrength, myModel, cmcTool, muscles, pathname)

import org.opensim.modeling.*      % Import OpenSim Libraries


%% change the muscle strength
    myModel.getMuscles().get( char(muscles) ).setMaxIsometricForce(mStrength)
    myModel.initSystem();

%% set the path's for some variables

    controlConstraintsPath  = fullfile(pathname,'gait2392_CMC_ControlConstraints.xml'  );
    tasksPath               = fullfile(pathname,'gait2392_CMC_Tasks.xml' );
    externalLoadFilePath    = fullfile(pathname,'subject01_walk1_grf.xml');
    coordinatesFilePath     = fullfile(pathname,'ResultsRRA', 'subject01_walk1_RRA_Kinematics_q.sto' );
    modelFilePath           = fullfile(pathname,'subject01_simbody_adjusted.osim');
    resultsPath             = fullfile(pathname,'ResultsCMC', ['testRun_' num2str(mStrength)]);
    
%% Change the output folder path from CMCSetup

    cmcTool.setModelFilename(modelFilePath);
    cmcTool.setConstraintsFileName(controlConstraintsPath);
    cmcTool.setTaskSetFileName(tasksPath);
    cmcTool.setDesiredKinematicsFileName(coordinatesFilePath);
    cmcTool.setInitialTime(0.53);
    cmcTool.setFinalTime(0.74);
    cmcTool.setResultsDir(resultsPath);
    cmcTool.setExternalLoadsFileName(externalLoadFilePath);

    % Save the settings in a setup file
    % outfile = ['setup_CMC_new5.xml'];
    % cmcTool.print([pathname outfile]);


%% run cmc
    cmcTool.run()

%% read in results and save to q and t

    torqueDta = importdata( fullfile( pathname, 'ResultsCMC', ['testRun_' num2str(mStrength)], 'subject01_Actuation_force.sto'));
    torqueDta = torqueDta.data;
    coordData = importdata( fullfile( pathname, 'ResultsCMC', ['testRun_' num2str(mStrength)], 'subject01_Kinematics_q.sto'   ));
    coordData = coordData.data;

%% Print the Model to the cmc folder

    myModel.print(fullfile( pathname, 'ResultsCMC', ['testRun_' num2str(mStrength)], 'myModel.osim'   ))
    
    
end