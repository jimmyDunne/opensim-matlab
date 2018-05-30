function C3DFolder2Opensim()
%% Convert a folder of C3D files to TRC and MOT format. 

%% Import the OpenSim Libs
import org.opensim.modeling.*

%% Get the full path to the C3d file
% Open a dialog to select the c3d file
[path] = uigetdir();
% Get Current dir
currentDir = cd;
% Move to c3d directory
cd(path);
% get all c3ds in directory
c3ds = dir('*.c3d');
% Move back to previous directory
cd(currentDir);

%% If no c3ds then exit function
if length(c3ds) == 0
    warning('No C3Ds in folder, exiting without return')
    return
end

%% Convert C3Ds
for i = 1 : length(c3ds)
    
    if length(c3ds) == 1
        fullpath = fullfile(path, c3ds.name);
    else 
        fullpath = fullfile(path, c3ds(i).name);
    end

    % Instantiate a osimC3D object    
    c3d = osimC3D(fullpath);
    % Rotate the c3d data (slow)
    c3d.rotateData('x', -90);
    % Print the trc to file
    c3d.printTRC();    
end
    
end