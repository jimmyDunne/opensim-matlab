classdef osimIK < matlab.mixin.SetGet
%% ikManager Manages OpenSim IK analysis for muliple trc files.
%       Class that instantiates an IKSolver and manages which files,
%       and for which times, the solver performs IK. The IK Solver also
%       calculates and tracks summed marker error. The ikManager takes a
%       trcManager on construction. A trcManager holds all of the trc data
%       and has functions specifically for editing and sampling trc files.
%       
%              
    properties
        model
        trcm
        data
        trackableMarkerList
        ik
        weights
        markerrefs
        startTime
        endTime 
        timeArray 
        errors
        coordinateTable
    end
    methods
        function self = osimIK(model, trcm)
            import org.opensim.modeling.*
            % Determine the trackable markers
            trackableMarkers = osimTRC.getTrackableMarkerList(model, trcm.getDataTableClone());
            % Make an OpenSim makerWeightsSet with default MarkerWeights.
            markerWeightSet = SetMarkerWeights();
            for i = 1 : length(trackableMarkers)
                markerWeightSet.cloneAndAppend( MarkerWeight(trackableMarkers{i}, 1));
            end
            markerWeightSet.setName('default_markerWeightSet');
            % Generate a Marker Reference Object
            markerref = MarkersReference(trcm.getDataTableClone(),...
            markerWeightSet, Units('m'));
            % Set Values for internal properties. 
            self.model = model;
            self.trcm = trcm;
            self.data = trcm.getDataTableClone();
            self.trackableMarkerList = trackableMarkers;
            self.weights = markerWeightSet;
            self.markerrefs = markerref;
            self.startTime = trcm.getTimeStart();
            self.endTime = trcm.getTimeEnd();
            self.timeArray = trcm.getTimeArray;
        end
        function mweights = getMarkerWeights(self)
            mweights = self.weights.clone();
        end
        function setMarkerWeights(self, mweights)
            import org.opensim.modeling.*
            % Set the internal marker weights object
            self.weights = mweights();
            % update the marker ref object with the new weights. 
            markerref = MarkersReference(self.data,...
                                         mweights, Units('m'));
            self.markerrefs = markerref;
        end
        function setStartTime(self, stime)
            if stime < self.startTime || stime > self.endTime
               error('Start time is out of bounds.') 
            else
               self.startTime = stime;
            end
        end
        function setEndTime(self, etime)
            if etime > self.endTime || etime < self.startTime
               error('End time is out of bounds.') 
            else
                self.endTime = etime;
            end
        end
        function stime = getStartTime(self)
            stime = self.startTime;
        end
        function etime = getEndTime(self)
            etime = self.endTime;
        end
        function run(self)
            import org.opensim.modeling.*
            % Clone model components
            model = self.model.clone();
            % Add a reporter to the model
            ikReporter = TableReporter();
            ikReporter.setName("ik_reporter");
            coordinates = model.getCoordinateSet();
            for i = 0 : model.getNumCoordinates() - 1
                coord = coordinates.get(i);
                ikReporter.updInput('inputs').connect(coord.getOutput('value'), coord.getName());
            end
            model.addComponent(ikReporter);
            s = model.initSystem();
            % Instantiate the ikSolver 
            ik = InverseKinematicsSolver(model,...
                                               self.markerrefs,...
                                               SimTKArrayCoordinateReference(),...
                                               Inf);
             
            % Set ikSolver accuracy
            accuracy = 1e-5;
            ik.setAccuracy(accuracy);
            % Assemble the model
            s.setTime(self.startTime());
            ik.assemble(s);

            % Get the coordinate Set
            errors = [];
            currentTime = self.timeArray(1);
            for i = 1 : length( self.timeArray() )
                disp(['Running IK for time ' num2str(self.timeArray(i))])
                s.setTime( self.timeArray(i) );
                % Perform tracking
                ik.track(s);
                % get the marker errors
                for u = 0 : ik.getNumMarkersInUse() - 1
                    errors(i, u+1) =  ik.computeCurrentMarkerError(u);
                end
                model.realizeReport(s)
            end
            self.coordinateTable = ikReporter.getTable().clone();
            self.errors = errors;
        end
        function writeMot(self, outputFileName)
            import org.opensim.modeling.*
            % Build a TimeSeriesTable for angles
            data = self.coordinateTable;
            % Update rotational coordinates into degrees
            tst = self.updateDegrees(data);
            % Add meta data
            tst.addTableMetaDataString('inDegrees', 'yes');
            % Write to file
            STOFileAdapter.write(tst, outputFileName);
            disp([outputFileName ' written to file. ']);
        end
        function writeMarkerErrors(self, outputFileName)
            
        end
        function total_error = getTotalError(self)
            % Compute the sum of all the marker errors
            total_error = sum(sum(self.errors));
        end
    end
    methods (Access = private, Hidden = true)
        function tst = buildTimeSeriesTable(self, data, labels, timeArray)
            import org.opensim.modeling.*
            
            times = self.data.getIndependentColumn();
            
            [nt, nc] = size(data);
            matrix = Matrix(nt,nc);
            
            for i = 0 : times.size() - 1
                for j = 0 : nc - 1
                    matrix.set(i, j, data(i+1,j+1) );
                end
            end
            % Generate a Table of rotations using the new Matrix
            tst = TimeSeriesTable(times, matrix, labels);
        end
        function tst = updateDegrees(self, tst)
           import org.opensim.modeling.*
           disp('Converting Radians to Degrees')
           cs = self.model.getCoordinateSet();
           for i = 0 : cs.getSize() - 1
               if strcmp('Rotational', char(cs.get(i).getMotionType())) 
                  for u = 0 : tst.getNumRows() - 1
                        r = tst.getRowAtIndex(u);
                        r.set(i, rad2deg(r.getElt(0,i)));
                  end
               end
           end
        end
    end
end
