function changedirectory(name)
% Changes the Matlab current folder from input string

if isempty(name)
    error('need an input string')
end

%% opensim-core sandbox/Matlab scripts directory
if stcmp(name, 'opensim')
    cd('/Users/jimmy/repository/opensim-master/opensim-core/OpenSim/Sandbox/MatlabScripts')
end

%% opensim-core dynamic walker directory
if stcmp(name, 'walker')
    cd('/Users/jimmy/repository/opensim-master/opensim-core/Bindings/Java/Matlab/Dynamic_Walker_Example')
end

%% noise data set
if stcmp(name, 'noise')
    cd('/Users/jimmy/repository/kinematicNoise')
end

%% robot data set
if stcmp(name, 'robot')
    cd('/Users/jimmy/repository/robotData')
end

%% scripts o converting c3d data to opensim
if stcmp(name, 'c3d')
    cd('/Users/jimmy/repository/c3d2OpenSim')
end

%% james dunnes scripts for opensim
if stcmp(name, 'c3d')
    cd('/Users/jimmy/repository/opensim-matlab')
end