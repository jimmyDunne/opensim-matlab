classdef ScalingHelper
   properties (Access = private)
       filepath
       filename
       scaletool
       modelscaler
       markerplacer
       measurementset
       genericmodelmaker
   end
   methods
       function obj = ScalingHelper(filePath)
           % Get the path and file name of the input file
           [obj.filepath, ohj.filename, ext] = fileparts(filePath);
           
           import org.opensim.modeling.*
           % Instantiate a ScaleTool and store in the object properties
           obj.scaletool = ScaleTool(filePath);
           % Instantiate a ModelScaler() object from the scaletool
           obj.modelscaler = obj.scaletool.getModelScaler();
           % markerplacer
           obj.markerplacer = obj.scaletool.getMarkerPlacer();
           % measurement set
           obj.measurementset = obj.modelscaler.getMeasurementSet();
           % Generic Model Maker
           obj.genericmodelmaker = obj.scaletool.getGenericModelMaker()
           
           % Check that a model path is assigned
           gmm = obj.genericmodelmaker;
           % Get the model name 
           model_file = char(gmm.getModelFileName);
           % Check that the model name exists
           if ~exist(model_file, 'file')
               % If it doesn't exist, give a warning to set the model name.
               disp('WARNING: Model is unassigned, update model name with full path')
           else
               obj.markerplacer.setOutputModelFileName( strrep(model_file,'.osim','_registered.osim'));
               obj.modelscaler.setOutputModelFileName(strrep(model_file,'.osim','_scaled.osim'));
           end
       end
       function updModel(obj,modelpath)
           if ~exist(modelpath, 'file')
               % If it doesn't exist, give a warning to set the model name.
               warning('Model cant be found, check input path')
           else
               [filepath, name, ext] = fileparts(modelpath);
               obj.genericmodelmaker.setModelFileName([name ext])
               obj.markerplacer.setOutputModelFileName( strrep([name ext],'_Generic.osim','_registered.osim'));
               obj.modelscaler.setOutputModelFileName(strrep([name ext],'_Generic.osim','_scaled.osim'));
           end           
       end
       function updMarkerFile(obj,markerpath)
           if ~exist(markerpath, 'file')
               % If it doesn't exist, give a warning to set the model name.
               warning('Model cant be found, check input path')
           else
                [filepath, name, ext] = fileparts(markerpath);
               obj.markerplacer.setMarkerFileName( [name ext] );
               obj.modelscaler.setMarkerFileName( [name ext] ); 
           end   
           
       end
       function dispModelPaths(obj)
           disp(['Input Model is: ' char(obj.genericmodelmaker.getModelFileName()) ]);
           disp(['Scaled Model  : ' char(obj.modelscaler.getOutputModelFileName()) ]);
           disp(['moved Model   : ' char(obj.markerplacer.getOutputModelFileName())]);
       end
       function labels = getMeasurementSetNames(obj)
           % Get a cell array of label names
           nM = obj.measurementset.getSize;
           % Go through the list and get the names
           labels = strings(19,1);
           for i = 0 : nM - 1
               labels(i+1) = char(obj.measurementset().get(i).getName);
           end
       end
       function m = getMeasurement(obj, mName)
           % Get a reference to a MeasurementSet
           mIndex = find(contains(obj.getMeasurementSetNames() , mName))-1;
           m = obj.measurementset.get(mIndex);
       end
       function markerlabels = getMeasurementMarkerNames(obj,mName)
           % Get an array of makerNames for the measurement
           m = obj.getMeasurement(mName);
           % For each marker pair, get the markers and print into a cell
           % array
           nmpairs = m.getNumMarkerPairs;
           markerlabels = strings(nmpairs,2);
           for i = 0 : nmpairs  - 1
               markerlabels(i+1,1) = char(m.getMarkerPair(i).getMarkerName(0));
               markerlabels(i+1,2) = char(m.getMarkerPair(i).getMarkerName(1));
           end
       end
       function displayMeasurementSetInformation(obj)
           labels = getMeasurementSetNames(obj);
           
           for i = 0 : length(labels) - 1
               markerLabels = obj.getMeasurementMarkerNames(labels{i+1});
               disp([num2str(size(markerLabels,1)) ' Marker pairs for Measurement ' labels{i+1} ':']);
               disp(markerLabels)
           end
       end
       function replaceMeasurement(obj,measurementName, mkname1, mkname2)
            % Get the measurement object
            m = obj.getMeasurement(measurementName); 
            % Get the MarkerPairSet for the Measurement
            mps = m.getMarkerPairSet();
            % Update the first pair of markers in the set
            mps.get(0).setMarkerName(0,mkname1);
            mps.get(0).setMarkerName(1,mkname2);                            
            % Remove any additional marker pairs from the measurement
            nmps = mps.getSize();
            if nmps > 1
               for i = 1 : nmps - 1
                   mps.remove(1);
               end
            end
            % Display the new measurement's marker pair
            markerlabels = obj.getMeasurementMarkerNames(measurementName);
            disp([num2str(size(markerlabels,1)) ' Marker pairs for Measurement ' measurementName ':']);
            disp(markerlabels);
       end
       function filepath = getModelScalerTRCFilePath(obj)
           filepath = obj.modelscaler.getMarkerFileName();
       end
       function setTRCFilePath(obj,filepath)
           obj.modelscaler.setMarkerFileName(filepath);
           obj.markerplacer.setMarkerFileName(filepath);
       end
       function printScaleTool(obj, filepath)
           obj.scaletool.print(filepath);
       end  
       function displayIKTasks(obj)
           % Display the IK Coordinates Tasks in the command window
           ikts = obj.markerplacer().getIKTaskSet();
           % Get the Number of Tasks
           nikts = ikts.getSize();
           % Build a strings array of task names, weights, and if the tasks
           % are applied. 
           tasks = strings(nikts, 4);
           for i = 0 : nikts - 1
               tasks(i+1,1) = num2str(i);
               tasks(i+1,2) = char(ikts.get(i).getName());
               tasks(i+1,3) = char(num2str(ikts.get(i).getWeight()));
               if ikts.get(i).getApply
                   tasks(i+1,4) = "True";
               else
                   tasks(i+1,4) = "False";
               end
           end
           % Display the results in the Matlab command window as a make
           % shift table. 
           disp( ["Index", "Task","Weight","Applied";"---","---", "---", "---"; tasks]  )
       end
       function updTaskWeight(obj,taskName, weight)
           if ischar(taskName) || isstring(taskName)
               obj.markerplacer().getIKTaskSet().get(taskName).setWeight(weight);
           elseif isnumeric(taskName)
               [r,c] = size(taskName);
               for i = taskName
                   obj.markerplacer().getIKTaskSet().get(i).setWeight(weight);
               end
           end
        end
       function updTaskApply(obj,taskName, apply)
          obj.markerplacer().getIKTaskSet().get(taskName).setApply(apply);
       end
       function saveTaskSet(obj,filepath)
           % Display the IK Coordinates Tasks in the command window
           ikts = obj.markerplacer().getIKTaskSet().print(filepath);
       end
       
%        function filepath = getModelScalerOutputModelFile(obj)
%            ms = obj.modelscaler;
%        end
%        function setModelScalerOutputModelFile(obj)
%            filepath = obj.modelscaler;
%        end
        
   end
end
