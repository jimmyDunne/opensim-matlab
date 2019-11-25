classdef externalLoadsBuilder < matlab.mixin.SetGet
% Class for building a external loads .xml
% 
%   External loads file require the allocation of forces to bodies. In this
%   class we find which foot of a standard OpenSim gait model is closest to
%   forces from a forceplate, then use that information to write an
%   external loads file for use in Inverse Dynamics. 
    properties (Access = private)
        NumCoordinates 
        coordinateLabels 
        times
        times_forces
        motion 
        forces
        forcelocationIndex
        ForceRow
        forceStruct
        forceslabels
        model 
        state
        datafile
        outputFileName
    end
    methods
        function obj = externalLoadsBuilder(modelPath, path2MotionFile, Path2GRFFile)
            import org.opensim.modeling.*
            % Get motioin data into a table
            motion = STOFileAdapter().read(path2MotionFile);
            % Generate an array with times
            nRows       = motion.getNumRows();
            timeCol     = motion.getIndependentColumn();
            dt          = timeCol.get(1) - timeCol.get(0);
            times       = [timeCol.get(0):dt:timeCol.get(nRows-1)]';
            
            % Get the coordinate names
            coordinatelabels = {};
            tableLabels = motion.getColumnLabels;
            for i = 0 : motion.getNumColumns() -1 
                coordinatelabels{i+1,1} = char(tableLabels.get(i));
            end
            
            % Get the location of the forces from the input file
            forces = STOFileAdapter().read(Path2GRFFile);
            nCols = forces.getNumColumns();
            nForces = nCols/9;
            forceslabels = {};
            tableLabels = forces.getColumnLabels();
            for i = 0 : nCols - 1 
                forceslabels{i+1,1} = char(tableLabels.get(i));
            end
            
            locationIndex = [];
            for i = 1 : nCols
                if contains(forceslabels{i},'px')
                    locationIndex = [locationIndex i];
                end
            end
            % Generate an array with times
            nRows       = forces.getNumRows();
            timeCol     = forces.getIndependentColumn();
            dt          = timeCol.get(1) - timeCol.get(0);
            times_forces= [timeCol.get(0):dt:timeCol.get(nRows-1)]';
            
            % Get the marker and force data as Structs
            forceStruct = osimTableToStruct(forces);
            
            % Create the output name, which can be used later
            [path,name,ext] = fileparts(Path2GRFFile);
            if isempty(path)
                path = cd;
            end
            outputFileName = fullfile(path,[name '_ExternalLoads.xml']);
            
            % Instantiat a model
            model = Model(modelPath);
            state = model.initSystem();
            
            % Set the properties of the class
            obj.NumCoordinates = length(coordinatelabels);
            obj.coordinateLabels = coordinatelabels;
            obj.times = times;
            obj.times_forces = times_forces;
            obj.motion = motion;
            obj.forces  = forces;
            obj.forceStruct = forceStruct;
            obj.ForceRow = 0;
            obj.forcelocationIndex = locationIndex;
            obj.forceslabels = forceslabels;
            obj.model = model;
            obj.state = state;
            obj.datafile = Path2GRFFile;
            obj.outputFileName = outputFileName;
        end
        function run(obj)
            import org.opensim.modeling.*
            disp('Building External Loads file ...')
            % For each force; when do they peak?. Find the
            % closest foot at peak?
            feetAllocation = {};
            fpUsed = [];
            % For each force, find the time of peak force
            for i = 1 : length(obj.forcelocationIndex)
                eval(['[M I] = max(obj.forceStruct.ground_force_' num2str(i) '_vy());']);
                if M < 100
                    continue
                end
                fpUsed = [fpUsed i];
                time = obj.times_forces(I);
                obj.ForceRow = I;

                % At the peak, find which foot is closest to the force point
                % Posiiton the model from the coordinate
                obj.motionBuilder(time);
                % Determine which foot is closest to the force
                feetAllocation = [feetAllocation {obj.forces2bodies(i,I)}];
            end

            % Allocate the force an External load object
            el = ExternalLoads();

            for i = 1 : length(feetAllocation)
                % Build an external force
                ef = ExternalForce();
                ef.setName([ feetAllocation{i} '_ExternalForce']);
                ef.set_applied_to_body( feetAllocation{i} );
                ef.set_force_expressed_in_body('ground');
                ef.set_point_expressed_in_body('ground');
                % Get the force, point, and torque colomn identifiers
                forceIDIndex = find( contains(obj.forceslabels,[num2str(fpUsed(i)) '_vx']));
                pointIDIndex = find( contains(obj.forceslabels,[num2str(fpUsed(i)) '_px']));
                torqueIDIndex = find( contains(obj.forceslabels,[num2str(fpUsed(i)) '_mx']));
                % Set the identifiers on the the external force
                ef.set_force_identifier( strrep(obj.forceslabels{forceIDIndex},'x',''));
                ef.set_point_identifier(strrep(obj.forceslabels{pointIDIndex},'x','') );
                ef.set_torque_identifier(strrep(obj.forceslabels{torqueIDIndex},'x',''));
                % Clone and append the external force to the external load
                el.cloneAndAppend(ef);
            end
            % Set the Datafile Path
            el.setDataFileName(obj.datafile);
            % Write the .XML to file
            el.print(obj.outputFileName());
            disp(['External Loads written to ' obj.outputFileName()]);
        end
        function motionBuilder(obj, time)
            import org.opensim.modeling.*
            % Set the pose of the model from the motion file

            % Check that motion file and model are consistent
            if obj.NumCoordinates ~=  obj.motion.getNumColumns()
                error('Number of Coordinates in motion file dont match model')
            end
            % 
            dataRow = find(time == obj.times);
            % Get the index for the row of data whose time value is closest
            % from the coordinate data
            [c dataRow] = min(abs(obj.times-time));

            % Get the data as a Row Vector
            data = obj.motion.getRowAtIndex(dataRow - 1);
            % Set the pose of the model from the Row Data
            for i = 0 : obj.NumCoordinates - 1
                % Get the label
                coordLabel = obj.coordinateLabels{i+1};
                % set the coordinate value.
                obj.model.getCoordinateSet().get(coordLabel).setValue(obj.state,data.get(i));
            end
            disp(['Model coordinate values set from time = ' num2str(time)]);
        end
        function closestFoot = forces2bodies(obj,forcePlateIndex,I)
            import org.opensim.modeling.*
            % Get the Calcaneous positions in Ground
            cr_position = osimVec3ToArray(obj.model.getBodySet.get('calcn_r').getPositionInGround(obj.state));
            cl_position = osimVec3ToArray(obj.model.getBodySet.get('calcn_l').getPositionInGround(obj.state));

            % Get the point column number in the force timesseries table.
            u = obj.forcelocationIndex(forcePlateIndex) - 1;
            % Get the XYZ value of the point
            p = [obj.forces.getDependentColumnAtIndex(u  ).get(I-1) ...
                 obj.forces.getDependentColumnAtIndex(u+1).get(I-1) ...
                 obj.forces.getDependentColumnAtIndex(u+2).get(I-1)];
           if obj.dbp(cr_position,p) < obj.dbp(cl_position,p) 
               closestFoot = 'calcn_r';
           else
               closestFoot = 'calcn_l';
           end
        end
        function d = dbp(obj,p1,p2)
            % distanceBetweenPoints 
            % Compute the distance between two 3D points.
            % get the vector between the points
            if ~isequal(size(p1), size(p2))
                error('input arrays are of different sizes')
            end
            % Pre-allocate an array for the distance
            d = zeros(size(p1,1),1);
            % Calc the vector between the two points
            v = p1 - p2;
            % Calc the length of the vector
            for i = 1 : size(v,1)
               d(i) = norm(v(i,:)); 
            end
        end
        function datafilepath = getOutputFileName(obj)
            datafilepath = obj.outputFileName();
        end
        function startTime = getMotionStartTime(obj)
            startTime = obj.times(1);
        end
        function endTime = getMotionEndTime(obj)
            endTime = obj.times(end);
        end
    end
end





