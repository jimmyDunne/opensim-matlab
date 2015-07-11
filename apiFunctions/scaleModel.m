function tempvarargin = scaleModel(varargin)

tempvarargin = varargin;
return

import org.opensim.modeling.*

modelFilePath =  [];
staticFilePath = [];
outputModelPath =[];
setupFileName  = [];
subjectMass =    [];

for i = 1 : nargin
     % if input string is rotation, next value will be a rotation cell array
    if ischar(tempvarargin{i})
        if ~isempty(strfind(tempvarargin{i}, 'model'))
            modelFilePath = char(tempvarargin{i+1});
        end
    end
    % if input string is rotation, next value will be a rotation cell array
    if ischar(tempvarargin{i})
        if ~isempty(strfind(tempvarargin{i}, 'staticData'))
               staticFilePath = char(tempvarargin{i+1});
        end
    end
    % if input string is filter, next value will be a filter cell array
    if ischar(tempvarargin{i})
        if ~isempty(strfind(tempvarargin{i}, 'outputModel'))
               outputModelPath = char(tempvarargin{i+1});
        end
    end
    % if input string is body, next value will be a body structure
    if ischar(tempvarargin{i})
        if ~isempty(strfind(tempvarargin{i}, 'setupFile'))
              setupFileName = char(tempvarargin{i+1});
        end
    end

    if ischar(tempvarargin{i})
        if ~isempty(strfind(tempvarargin{i}, 'mass'))
              subjectMass = double(tempvarargin{i+1});
        end
    end
end

%% generate an instance of the scale tool object from file
if isempty(staticFilePath)
      [ staticFileName,folderPath] = uigetfile('*.xml', 'Select Scale Setup File', cd);
      staticFilePath = fullfile(folderPath,staticFileName);
end

scaleTool = ScaleTool(staticFilePath)

%% if variables aren't given, create new ones
if ~isempty(modelFilePath)

end

if ~isempty(staticFilePath)
    scaleTool.getModelScaler.
    scaleTool.getModelScaler.
end

if isempty(outputModelPath)
    [path,file,ext] = fileparts(modelFilePath)
    outputModelPath = fullfile(path,[file '_scaled'],ext);
end

if isempty(subjectMass)
    subjectMass		=	scaleTool.getSubjectMass
end



% Define some of the subject measurements


%% ModelScaler-
%Name of OpenSim model file (.osim) to write when done scaling.
scaleTool.getModelScaler().setOutputModelFileName(scaledModelName)
% Filename to write scale factors that were applied to the unscaled model (optional)
scaleTool.getModelScaler().setOutputScaleFileName(appliedscaleSet)
% Get the path to the subject
path2subject = scaleTool.getPathToSubject()
% Run model scaler Tool
scaleTool.getModelScaler().processModel(myState,myModel,path2subject,subjectMass);









end
