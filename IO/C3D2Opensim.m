function C3D2Opensim()
%% Convert a selected C3D file(s) to TRC and MOT format. 

%% Get the full path to the C3d file
% Open a dialog to select the c3d file
[filenames, path] = uigetfile('.c3d', 'Pick C3D File', 'Multiselect', 'on');

%% Determine the number of selected files
if iscell(filenames)
    nFiles = length(filenames);
else
    nFiles = 1;
end

%% Convert each file.
for i = 1 : nFiles
    % Determine full path name
    if iscell(filenames)
        fullpath = fullfile(path, filenames{i});
        [p filename] = fileparts(fullpath);
    else
        fullpath = fullfile(path, filenames);
        filename = filenames;
    end
    % Instantiate a osimC3D object    
    c3d = osimC3D(fullpath,1);
    % Rotate the c3d data (slow)
    c3d.rotateData('x', -90);
    % Write the Mot and TRC to file
    c3d.writeTRC(); c3d.writeMOT(); 
    % Display result
    disp(['TRC and MOT file for ' filename ' successfully writen'])
end

end