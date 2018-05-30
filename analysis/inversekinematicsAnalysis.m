function inversekinematicsAnalysis
import org.opensim.modeling.*

%% Select a Model 
disp('Select Model')
[filename, path] = uigetfile('.osim', 'Pick C3D File', 'Multiselect', 'Off');
modelFilePath = fullfile(path, filename);
model = Model(modelFilePath);

%% Select .trc trials
disp('Select files to run IK')
[filenames, path] = uigetfile('.trc', 'Pick TRC File', 'Multiselect', 'on');


%% Run IK on Available trials
for u = 1 : length(filenames)
    % Set the Path for the TRC File 
    if length(filenames) == 1 
        trcpath = fullfile(path,filenames);
    else
        trcpath = fullfile(path,filenames{u});        
    end
    % Get the input marker table
    trc = TRCFileAdapter().read(trcpath);
    % Get Model Marker Names
    markerNames = [];
    for i = 0 : model.getMarkerSet().getSize()-1;
       markerNames = [markerNames; {char(model.getMarkerSet().get(i).getName() )}];    
    end
    % Get the TRC Marker Names
    t = TRCFileAdapter().read(trcpath);
    trcNames = [];
    for i = 0 : t.getNumColumns() - 1
        label = char(t.getColumnLabels().get(i));
        if ~isempty(strfind(label, ':'))
            label = label(strfind(label, ':')+1:end);
        end
        trcNames = [trcNames; {label}];
    end
    % Generate a final list of Markers to track
    markerList = intersect(markerNames,trcNames);
    % Generale a list of input marker weights for the IKSolver()
    weights = ones(length(markerList),1) ;
    % Run the IK solver
    [locations, errors, angles, anglesPacked] = solverIK(model, trcpath, markerList, weights);
    % Convert anglespacked from struct to OpenSim Table
    motTable = osimTableFromStruct(anglesPacked);
    % Add some Metadata to the MotTable
    motTable.addTableMetaDataString('nColumns', num2str(motTable.getNumColumns()+1));
    motTable.addTableMetaDataString('nRows', num2str(motTable.getNumRows()));
    motTable.addTableMetaDataString('inDegrees', 'yes');
    % Make the output name
    [a,filename,ext] = fileparts(trcpath);
    outputFilePath   = fullfile(path,[filename '_coordinates.mot']);
    % Print to File
    STOFileAdapter().write(motTable,outputFilePath);
end





