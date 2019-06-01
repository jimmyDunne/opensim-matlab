classdef ikHelper < matlab.mixin.SetGet
    properties (Access = private)
        modelFileName
        markerFileName
        model
        markerdata
        markerLabels
        markerWeightSet
        stime
        etime
        dt
        errors 
        locations
        angles
    end
    methods 
        function obj = ikHelper(modelFileName, markerFileName)
            import org.opensim.modeling.*

            modelFileName = modelFileName;
            markerFileName = markerFileName;

            model = Model(modelFileName);
            markerdata = TRCFileAdapter().readFile(markerFileName);

            % Get a list of all the trackable markers in the model and the
            % data. 
            markerLabelsInModel = {};
            for i = 0 :model.getMarkerSet().getSize() - 1 
                markerLabelsInModel = [markerLabelsInModel ; {char(model.getMarkerSet().get(i).getName)}];
            end

            markerLabelsInData = {};
            for i = 0 :markerdata.getNumColumns() - 1
                markerLabelsInData = [markerLabelsInData ; {char(markerdata.getColumnLabels().get(i))}];
            end

            % Get the list markers that have data to track. 
            MarkersInBoth = intersect(markerLabelsInData,markerLabelsInModel);

            % Edit Model to remove all markers not in both
            markerLabels = {};
            for i = 1 : length(markerLabelsInModel)
                if ~sum(ismember(MarkersInBoth, markerLabelsInModel{i}))
                    m =model.getMarkerSet().get(markerLabelsInModel{i});
                   model.getMarkerSet().remove(m);
                else
                    markerLabels = [markerLabels;markerLabelsInModel(i)];
                end
            end

            % Make an OpenSim makerWeightsSet with default MarkerWeights. 
            markerWeightSet = SetMarkerWeights();
            for i = 1 : length(markerLabels) 
                markerWeightSet.cloneAndAppend( MarkerWeight(markerLabels{i}, 1 ) );
            end
            markerWeightSet = markerWeightSet;


            % Make default start and end times from the markerdata
            stime =markerdata.getIndependentColumn().get(0);
            etime =markerdata.getIndependentColumn().get(...
                           markerdata.getIndependentColumn().size()-1);
            % Get the dataRate
            dataRate = str2num(markerdata.getTableMetaDataAsString('DataRate'));
            
            obj.modelFileName = modelFileName;
            obj.markerFileName = markerFileName;
            obj.model = model;
            obj.markerdata = markerdata;
            obj.markerLabels = markerLabels;
            obj.markerWeightSet = markerWeightSet;
            obj.stime = stime;
            obj.etime = etime;
            obj.dt = 1/dataRate;
            obj.errors = [];
            obj.locations = [];
            obj.angles = [];
        end
        function o = getStartTime(obj)
            o = obj.stime;
        end
        function o = getEndTime(obj)
            o = obj.etime;
        end
        function o = getMarkerLabels(obj)
            o = obj.markerLabels;
        end
        function o = getMarkerWeightSet(obj)
            import org.opensim.modeling.*
            o = obj.markerWeightSet.clone();
        end
        function setMarkerWeight(obj,markerName,weight)
            for i = 0 : obj.markerWeightSet.getSize - 1
                if contains(char(obj.markerWeightSet.get(i).getName()),markerName)
                    obj.markerWeightSet.get(i).setWeight(weight);
                    break
                elseif i == obj.markerWeightSet.getSize - 1
                    error(['Marker Name, ' markerName ', not found in Marker Set'])
                end
            end
        end
        function o = getErrors(obj)
            o = obj.errors;
        end
        function o = getAngles(obj)
            o = obj.angles;
        end
        function printErrors(obj, filename)
            
        end
        function printMot(obj,filename)
            import org.opensim.modeling.*
            
            
            dataTable = DataTable();
            [nRows, nCols] = size(obj.angles);
            
            cLables = StdVectorString();
            for i = 0 : obj.model.getCoordinateSet().getSize() - 1
                cLables.add(char(obj.model.getCoordinateSet().get(i).getName()))
            end
            dataTable.setColumnLabels(cLables);

            row = RowVector(obj.model.getCoordinateSet().getSize());
            for u = 1 : nRows
                for i = 0 :  obj.model.getCoordinateSet().getSize() - 1
                    
                    if contains(char(obj.model.getCoordinateSet().get(i).getMotionType),'Rotational')
                        % Convert from Rad to Deg if rotational
                        row.set(i, rad2deg(obj.angles(u,i+1)));
                    else
                        row.set(i, obj.angles(u,i+1));
                    end
                end
                t = obj.stime + (u-1)*obj.dt; 
                dataTable.appendRow( t   , row);
            end
            
            % Add Meta Data Key
            dataTable.addTableMetaDataString('Coordinates','');
            dataTable.addTableMetaDataString('DataRate',num2str(fix(1/obj.dt)));
            dataTable.addTableMetaDataString('inDegrees','yes');

            % Convert to a time series table
            tst = TimeSeriesTable(dataTable);
            % Write table to file
            STOFileAdapter().write(tst,filename)
        end
        function run(obj)
            
            import org.opensim.modeling.*
            
            markerref = MarkersReference( obj.markerdata,...
                                          obj.markerWeightSet,...
                                          Units('m'));
            
            % Instantiate the ikSolver and set some values. 
            ikSolver = InverseKinematicsSolver(obj.model,...
                                               markerref,...
                                               SimTKArrayCoordinateReference(),...
                                               Inf);
            % Set ikSolver accuracy
            accuracy = 1e-5;
            ikSolver.setAccuracy(accuracy);
             
            s = obj.model.initSystem();
            s.setTime(obj.stime);
            
            ikSolver.assemble(s);
            
            errors = [];
            angles = [];
            locations = [];
            currentTime = obj.stime;
            while currentTime < obj.etime
                s.setTime(currentTime);
                % Perform tracking
                ikSolver.track(s);
                % get the marker errors
                nRow = size(errors,1);
                for u = 0 : ikSolver.getNumMarkersInUse() - 1
                       errors(nRow+1, u+1) =  ikSolver.computeCurrentMarkerError(u);
                end
                % Get the Model Marker Locations
                for u = 0 : ikSolver.getNumMarkersInUse() - 1
                        location =  ikSolver.computeCurrentMarkerLocation(u);
                        locations(nRow+1,(u+1)*3-2:(u+1)*3) = [location.get(0) location.get(1) location.get(2)]; 
                end
                % Get the Coordinates Values
                obj.model.realizeVelocity(s);
                % Get the coordinate Set
                cs = obj.model.getCoordinateSet();
                nvalues = cs.getSize();
                for u = 0 : nvalues - 1
                    angles(nRow+1,u+1) = cs().get(u).getValue(s);
                end
                % Move ahead in time and repeat. 
                currentTime = currentTime + obj.dt;
            end
            
            % Update the objects properties with these new values
            obj.errors = errors;
            obj.locations = locations;
            obj.angles = angles;
        end
    end
end