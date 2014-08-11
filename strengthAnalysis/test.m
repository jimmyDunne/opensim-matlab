%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%                 B A T C H for multiple COMPUTER MUSCLE CONTROL         %
%                                                                        %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% setupAndRunCMCBatch.m                                                 
% Author: SCHNEIDER G¸nter

clc;
close all;
clear all;

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

% move to directory where this subject's files are kept
subjectDir = uigetdir('C:\OpenSim 3.1\Models\', 'Select the folder that contains the current subject data');

% Go to the folder in the subject's folder where .mot files are
motion_data_folder = uigetdir(subjectDir, 'Select the folder that contains the motion data files in .mot format.');

% specify where results will be printed.
results_folder = uigetdir(subjectDir, 'Select the folder where the CMC Results will be printed.');

% Get and operate on the files
% Choose a generic setup file to work from
[genericSetupForCMC,genericSetupPath,FilterIndex] = ...
    uigetfile([subjectDir '\*.xml'],'Pick the/a generic setup file to/for this subject/model as a basis for changes.');
cmcTool = CMCTool([genericSetupPath genericSetupForCMC]);

% specify the folder where the external loads file are 
extLoad_folder = ... 
    uigetdir(subjectDir ,'Select the folder where the external loads files are located.');

% Get the model
[modelFile,modelFilePath,FilterIndex] = ...
    uigetfile([subjectDir '\*.osim'],'Pick the the model file to be used.');

% Load the model and initialize
model = Model([modelFilePath modelFile]);
model.initSystem();

% Tell Tool to use the loaded model
cmcTool.setModel(model);

trialsForCMC = dir(fullfile(motion_data_folder, 'subject01_walk1_ik.mot'));
nTrialsMotion = size(trialsForCMC);

% Loop through the trials of .mot files 
for trial_motion = 1:nTrialsMotion;
    
    % Get the name of the file for this trial
    motionFile = trialsForCMC(trial_motion).name;
    
    % Loop through the trails of div. external load files
   externalLoadFilePath    = f
   
   
%       name = regexprep(motionFile,'.mot','');
        fullpath_extLoad = fullfile(motion_data_folder,'subject01_walk1_grf.xml');

        % Get .mot data to determine time range
        ImportMotionData = importdata(fullfile(motion_data_folder, 'subject01_walk1_ik.mot'));
        motionData = ImportMotionData.data;
    %     motionData = motionData(fullfile(motion_data_folder, 'subject01_walk1_ik.mot'));

        % Get initial and intial time 
    %     initial_time = motionData.getStartFrameTime();
          initial_time = motionData(1,3);
    %     final_time = motionData.getLastFrameTime();
          final_time = motionData(end,20);

        % Setup the cmcTool for this trial
        cmcTool.setName('dick');
        cmcTool.setDesiredKinematicsFileName(fullfile(motion_data_folder, 'subject01_walk1_ik.mot'));
        cmcTool.setInitialTime(initial_time);
        cmcTool.setFinalTime(final_time);
        cmcTool.setResultsDir(results_folder);
        cmcTool.setExternalLoadsFileName(fullpath_extLoad);

         % Save the settings in a setup file
        outfile = ['setup_CMC' extLoadFile(trial_force).forceFile(17:end-4)  '.xml'];
        cmcTool.print([genericSetupPath outfile]);

        fprintf(['Performing CMC: cycle #' num2str(trial_motion) ...
            ' of ' num2str(nTrialsMotion(1,1)) '(motion) / #' num2str(trial_force) ...
            ' of ' num2str(length(extLoadFile)) '(force) \n ... [' outfile ']\n ... [' extLoadFile(trial_force).forceFile ']\n']);
     
        % Run CMC
        cmcTool.run();
        
        fprintf([' ... [' name '_ ... .sto]\n']);
     
        % keep def. files and folders, clear all other
        keep subjectDir motion_data_folder results_folder genericSetupForCMC ... 
            genericSetupPath FilterIndex cmcTool extLoad_folder modelFile modelFilePath ... 
            model trialsForCMC nTrialsMotion trial_motion motionFile extLoadFile

    end
end
display('*** *** *** Computer Muscle Control(CMC) - D O N E *** *** ***');