function CoordinateCreater(qFile)



import org.opensim.modeling.*      % Import OpenSim Libraries


if nargin < 1
    [filein, pathname] = uigetfile({'*.sto','Coordinates'}, 'Coordinates file...');
    expStates = Storage(fullfile(pathname,filein));
end

expStates.getName









end 