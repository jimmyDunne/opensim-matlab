function C3D2Opensim()
%% Convert a single C3D file to TRC and MOT format. 

%% Import the OpenSim Libs
import org.opensim.modeling.*

%% Get the full path to the C3d file
% Open a dialog to select the c3d file
[filename, path] = uigetfile('.c3d', 'Pick C3D File', 'Multiselect', 'Off');
% concanenate the strings to give the full path
fullpath = fullfile(path,filename);
%% Instantiate a osimC3D object
c3d = osimC3D(fullpath);
% Rotate the c3d data (slow)
c3d.rotateData('x', -90);
% Print the trc to file
c3d.printTRC();

end