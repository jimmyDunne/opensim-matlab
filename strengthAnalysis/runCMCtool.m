function [t q] = runCMCtool(mStrength, myModel, mySetupFile, muscle, pathname)





import org.opensim.modeling.*      % Import OpenSim Libraries

cd('C:\Users\vWin7\Documents\GitHub\stackJimmy\strengthAnalysis')




% get the path to the model and cmc setup file
[filein1, pathname1] = uigetfile({'*.osim','osim'}, 'OSIM model file...');

[filein, pathname] = uigetfile({'*.xml','xml'}, 'Setup model file...');



cmcTool = CMCTool(fullfile(pathname,filein));
myModel = Model(fullfile(pathname1,filein1));
myModel.initSystem();




%% change the musle strength of the model
mStrength = 1000
%myModel.getMuscles().get( char(muscle) ).setMaxIsometricForce(mStrength)


%% set the path's for some variables

    controlConstraintsPath  = fullfile(pathname,'gait2392_CMC_ControlConstraints.xml'  );
    tasksPath               = fullfile(pathname,'gait2392_CMC_Tasks.xml' );
    externalLoadFilePath    = fullfile(pathname,'subject01_walk1_grf.xml');
    coordinatesFilePath     = fullfile(pathname,'ResultsRRA', 'subject01_walk1_RRA_Kinematics_q.sto' );
    modelFilePath           = fullfile(pathname,'subject01_simbody_adjusted.osim');
    resultsPath             = fullfile(pathname,'ResultsCMC', ['testRun_' num2str(mStrength)]);
    name                    = 'comeON';
    
%% Change the output folder path from CMCSetup


    cmcTool.setModel( myModel )
    cmcTool.setModelFilename(modelFilePath);
    cmcTool.setConstraintsFileName(controlConstraintsPath);
    cmcTool.setTaskSetFileName(tasksPath);
    
    
    cmcTool.setName(name);
    cmcTool.setDesiredKinematicsFileName(coordinatesFilePath);
    cmcTool.setInitialTime(0.53);
    cmcTool.setFinalTime(0.74);
    cmcTool.setResultsDir(resultsPath);
    cmcTool.setExternalLoadsFileName(externalLoadFilePath);

    % Save the settings in a setup file
    outfile = ['setup_CMC_new2.xml'];
    cmcTool.print([pathname outfile]);


%% run cmc
cmcTool.run()

%% read in results and save to q and t





 
    % Get initial and intial time 
    initial_time = markerData.getStartFrameTime();
    final_time = markerData.getLastFrameTime();
    
    % Setup the ikTool for this trial
    cmcTool.setName(name);
    cmcTool.setMarkerDataFileName(fullpath);
    cmcTool.setStartTime(initial_time);
    cmcTool.setEndTime(final_time);
    ikTool.setOutputMotionFileName([results_folder '\' name '_ik.mot']);
    
    % Save the settings in a setup file
    outfile = ['Setup_IK_' name '.xml'];
    ikTool.print([genericSetupPath '\' outfile]);
    
    fprintf(['Performing IK on cycle # ' num2str(trial) '\n']);
    % Run IK
    cmcTool.run();












end