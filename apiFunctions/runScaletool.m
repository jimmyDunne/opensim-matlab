function ModelOutputPath =  runScaletool(varargin)
%
% varargin{1} = path2setupfile
% varargin{2} = path2modelfile
% varargin{3} = scaleOutputName
% varargin{4} = registeredOutputName
% varargin{5} = trcFileName


ModelOutputPath =  runScaletool(...
                    'setupFile', {setupFilePath},...
                    'subjectFolder', {folderName},...
                    'modelFilePath', {modelpath},...
                    'markerFilePath', {markerPath},...
                    'scaledModelName', {scaledModelName},...
                    'registeredModelName', {registeredModelName},...
                    'subjectMass',{subjectMass} )
                

%%
                
for i = 1: nargin
   
   % Define the setup path  
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'setupFile'))
             setupFilePath = varargin{i+1};
        end
   end
   
    % Define the setup path  
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'modelFilePath'))
             modelFilePath = varargin{i+1};
        end
   end
   
    % Define the setup path  
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'markerFilePath'))
             markerFilePath = varargin{i+1};
        end
   end
end

%% Get some info off the model. 


import org.opensim.modeling.*      % Import OpenSim Libraries

% Load model 
if exist('modelFilePath','var') 
    myModel = Model(modelFilePath);
    myState = myModel.initSystem();
    modelName = char( myModel.getName() );
end

%scaleTool = ScaleTool(varargin{1});
scaleTool = ScaleTool(setupFilePath);




%% Generic Model Maker
modelMaker   = scaleTool.getGenericModelMaker();
% if there is no modelfile name given in the Generic model Maker
if isempty( strfind(char(modelMaker.getModelFileName), '.osim') )
   modelMaker.setModelFileName(modelFilePath);
end

if exist('markerSetFilePath','var') 
    modelScaler.setMarkerFileName(markerSetFilePath) 
end


%% ModelScaler 
modelScaler  = scaleTool.getModelScaler();
% set/get marker file
% set the output Model name
if exist('scaledModelName','var')
    modelScaler.setOutputModelFileName(fullfile(subjectFolder, scaledModelName));
else
    modelScaler.setOutputModelFileName([modelName 'Scaled.osim']);
end

if exist('markerDataFileName','var')
    modelScaler.setMarkerFileName(fullfile(subjectFolder, markerDataFileName)) 
end
% set the outputScaleFilename
modelScaler.setOutputScaleFileName([subjectFolder '\outputScaleFile.xml'])
path2subject = scaleTool.getPathToSubject();
modelScaler.processModel(myState,myModel,'',subjectMass);

%% ModelPlacer 
loadModel(fullfile(subjectFolder, scaledModelName))
myModel = Model(modelFilePath);
myState = myModel.initSystem();


markerPlacer = scaleTool.getMarkerPlacer();

markerPlacer.setStaticPoseFileName(fullfile(subjectFolder, markerDataFileName))

% need to fix this. The time range has to be entered as a simbody matrix
% markerPlacer.setTimeRange()

markerPlacer.setOutputMotionFileName('')
markerPlacer.setOutputMarkerFileName('')


markerPlacer.setOutputModelFileName(fullfile(subjectFolder, registeredModelName))

MarkerPlacer().processModel(myState,myModel,'')





end





%% MarkerPlacer




