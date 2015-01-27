function ModelOutputPath =  runScaletool(varargin)
%
% varargin{1} = path2setupfile
% varargin{2} = path2modelfile
% varargin{3} = scaleOutputName
% varargin{4} = registeredOutputName
% varargin{5} = trcFileName

import org.opensim.modeling.*      % Import OpenSim Libraries

myModel = Model(varargin{2});
myState = myModel.initSystem();
modelName = char( myModel.getName() );


%scaleTool = ScaleTool(varargin{1});
scaleTool = ScaleTool(path2setupFile);

modelMaker   = scaleTool.getGenericModelMaker();
modelScaler  = scaleTool.getModelScaler();
markerPlacer = scaleTool.getMarkerPlacer();

%% Generic Model Maker

% if there is no modelfile name given in the Generic model Maker
if isempty( strfind(char(modelMaker.getModelFileName), '.osim') )
   modelMaker.setModelFileName(varargin{2});
end
    
%% ModelScaler 
% set/get marker file
if nargin == 5 
    modelScaler.setMarkerFileName(varargin{5}) 
end
% set the output Model name
modelScaler.getOutputModelFileName
if naragin > 2
    modelScaler.setOutputModelFileName = varagin{3};
else
    modelScaler.setOutputModelFileName([modelName 'Scaled.osim']);
end
% set the outputScaleFilename
modelScaler.setOutputScaleFileName('outputScaleFile')
path2subject = scaleTool.getPathToSubject()
modelScaler.processModel(myState,myModel,path2subject,subjectMass);





%% MarkerPlacer




