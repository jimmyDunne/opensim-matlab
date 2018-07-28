function OpenSim_IK

% Outer-layer for running a single or batch IK process for OpenSim.
% Passes Information to IK.m so that a successful IK can take place.
% Adapted by James Dunne (UWA) & Samuel Hamner (Stanford)  
% Version Written: June, 2010

% Select the trials you wish to run a Inverse Kinematic analysis on...
% this will give the file names and directory string.

folder=cd;
%% Determine the OpenSIm model Name
      [OsimFileName,ModelDirectory]=uigetfile('*.osim','Select OSIM FIle to be Altered',folder,'MultiSelect','off');

%% Determine the trials to perform IK on
      [trcName,DataDirectory]=uigetfile('*.trc','Inverse Kinematic Simulatoion(s)',ModelDirectory,'MultiSelect','on');
%% go to the folder with all the setup files
     [setupName,SetupDirectory]=uigetfile('*etup*.xml','SetUp folder?',ModelDirectory,'MultiSelect','off');
     cd(SetupDirectory)
%%
%Point to the directory that has the IK.exe in it
%I fthis is left empty it means the command propt will serach your internal
%path for IK.exe. If you have multiple copies of OpenSim/IK.exe then you
%will fill this in to specific in which directory to use.
FunctionDirectory=['C:\OpenSim2.2\bin'];
%% determine the number of loops to be made
if iscell(trcName)==1
    NumberofTrials=length(trcName);
else
    NumberofTrials=1;
end

%% Set a Specifier to be placed on the output files
Specifier=[];
Specifier= input('what specifier on output files?','s');
%% Write IK set file
 Write_IK_Tasks(SetupDirectory)

%%


for qq=1:NumberofTrials
       %% Determine the Name of the Trial
       if iscell(trcName)==1
           oo=strfind(char(trcName(qq)),'.');
           TrialName=char(trcName(qq));
       else
           oo=strfind(trcName,'.');
           TrialName=trcName;
       end
           TrialName=TrialName(1:oo-1);
       %% Determine the time range of analysis
       [timeRange] = trcTimeRange(DataDirectory,TrialName);    
      %% Run IK on Data
       [OutputStatement]=IK(DataDirectory, FunctionDirectory,TrialName,Specifier,OsimFileName,timeRange,SetupDirectory,setupName);       
end

%% Delete temp files




end
       
       
       
 
       
       
       
       
       
       
       
       
       
       
       
       
       
       