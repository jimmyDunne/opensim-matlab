function changedirectory(varargin)
% Changes the Matlab current folder from input string


data = [{'opensim'} {'/Users/jimmy/repository/opensim-master/opensim-core/OpenSim/Sandbox/MatlabScripts'};...
        {'walker'} {'/Users/jimmy/repository/opensim-master/opensim-core/Bindings/Java/Matlab/Dynamic_Walker_Example'};...
        {'noise'} {'/Users/jimmy/repository/kinematicNoise'};...
        {'robot'} {'/Users/jimmy/repository/robotData'};...
        {'c3d'} {'/Users/jimmy/repository/c3d2OpenSim'};...
        {'osim-matlab'} {'/Users/jimmy/repository/opensim-matlab'} ];
    
    
    
    
if ~nargin
    display(data(:,1))
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
