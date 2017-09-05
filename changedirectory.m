function changedirectory(varargin)
% Changes the Matlab current folder from input string


data = [{'sandbox-scripts'} {'/Users/jimmy/repository/opensim-master/opensim-core/OpenSim/Sandbox/MatlabScripts'};...
        {'apl'} {'/Users/jimmy/Dropbox/amjr_consulting/johnhopkins-apl/work'};...
        {'opensim-matlab'} {'/Users/jimmy/repository/opensim-master/opensim-core/Bindings/Java/Matlab/'};...
        {'noise'} {'/Users/jimmy/repository/kinematicNoise'};...
        {'robot'} {'/Users/jimmy/repository/robotData'};...
        {'c3d'} {'/Users/jimmy/repository/c3d2OpenSim'};...
        {'hop'} {'/Users/jimmy/repository/opensim-master/opensim-core/Bindings/Java/Matlab/Hopper_Device'};...
        {'osim-matlab'} {'/Users/jimmy/repository/opensim-matlab'};...
        {'muscle-scale'} {'/Users/jimmy/repository/muscle-scaling'};...
        {'scaling'} {'/Users/jimmy/repository/scaling_registration'};...
        {'autolabel'} {'/Users/jimmy/repository/mocap-labeling-opensim/scripts'}];
        
    
    
    
    
    
if ~nargin
    display(data(:,1))
    return
elseif nargin
    name = char(varargin{1});
end


if strcmp(name, 'list')
    display(data(:,1))
else
    
    Index = find(not(cellfun('isempty', strfind(data(:,1), name))));
    disp(['Changing working directory to ' char(data(Index, 2)) ]);
    cd(char(data(Index, 2)))
end
