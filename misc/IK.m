function [OutputStatement,OsimFileName]=IK(DataDirectory, FunctionDirectory,TrialName,Specifier,OsimFileName,timeRange,SetupDirectory,setupName)
    % Run an Inverse Kinematic analysis using OpenSim's IK.exe.

    % 
    % DataDirectory           Directory which contains raw data (.trc & .mot) and setup files (.xml)
    % FunctionDirectory       Directory that contains IK.exe; Make =[] if in internal Path
    % TrialName               name of the trial eg. 'James_Running1'
    % Specifier               places a string at the front of output name
    % OsimFileName            Name of the Osim file that will be used 
    % timeRange               matrix with time valuse ie [initial Final]
    % 
    % Written by: Jeff Reinbolt
    % Adapted by Samuel Hamner (Stanford) & James Dunne (UWA)
    % Version Written: June, 2010

    MatlabDirectory=cd;
    %%
    % Create IK directory for results to be ptrinted too
    OutPutFolder = [DataDirectory 'IK_Results'];
    
    % Check if working directory already exists
    checkFolder = exist(OutPutFolder,'dir');
    if(checkFolder ~= 7)
        mkdir(OutPutFolder);
    end
    cd(DataDirectory)
    %% Find IK Setup File and Read XML in
    xmlDoc = xmlread([SetupDirectory setupName]);
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Edit the information within in the tags of this xml so that IK.exe runs
    % a simulation on the correct file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set the Model to use
       xmlDoc.getElementsByTagName('model_file').item(0).getFirstChild.setNodeValue(char(OsimFileName))     
    %% Set IKTrial Name
       xmlDoc.getElementsByTagName('IKTrialSet').item(0).getAttributes.item(0).setValue('Default name')
    %% Specify the IK Tasks to be used(IK_Tasks.xml)
       xmlDoc.getElementsByTagName('IKTaskSet').item(0).getAttributes.item(0).setValue('IK_Tasks.xml')
    %% Name of .trc file with Marker trajectories
       xmlDoc.getElementsByTagName('marker_file').item(0).getFirstChild.setNodeValue([TrialName '.trc'])
    %% Name of .mot file with GRF's
    %   xmlDoc.getElementsByTagName('coordinate_file').item(0).getFirstChild.setNodeValue([TrialName '.mot'])
    %% Name of the .mot file where results will be printed out
       ResultsFileName=[Specifier TrialName '_IK_Results.mot'];
       xmlDoc.getElementsByTagName('output_motion_file').item(0).getFirstChild.setNodeValue(ResultsFileName)
    %% Set Time range of analysis
       xmlDoc.getElementsByTagName('time_range').item(0).getFirstChild.setNodeValue(num2str(timeRange))
    %% Overwrite the IK setup file with the new settings
       xmlwrite('Setup_IK.xml', xmlDoc);
    
    %% Set the command string before execution   
    if isempty(FunctionDirectory)==1
         Command = ['IK -S' ' ' setupName]; %IK.exe is in the system path
    else
         Command = [FunctionDirectory 'IK -S' ' ' setupName]; %Ik.exe is not in the system path or you wish to specify which one
    end
    %% Run IK.exe
    system(Command);
    %% Move one copy to the results folder
    copyfile([DataDirectory ResultsFileName], [OutPutFolder '\' ResultsFileName]);
    delete([DataDirectory ResultsFileName])
    %%
    OutputStatement='Simulation performed';
    cd(MatlabDirectory);
end









