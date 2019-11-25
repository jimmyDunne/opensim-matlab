function [data] = TRC2Struct()
%% Read a TRC File into Memory

%% Import the OpenSim Libs
import org.opensim.modeling.*

%% Get the full path to the TRC file
% Open a dialog to select the TRC file
[filename, path] = uigetfile('.trc', 'Pick TRC File', 'Multiselect', 'Off');
% concanenate the strings to give the full path
fullpath = fullfile(path,filename);

%% Use OpenSim's method for generating a trc file
trc = TRCFileAdapter().read(fullpath);

%% Convert to Struct using OpenSim's Matlab function
data = osimTableToStruct(trc);

end
