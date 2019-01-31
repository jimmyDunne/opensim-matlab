classdef osimTRC < matlab.mixin.SetGet
% osimTRC(filePath)
%  Class for reading and operating on TRC Files. 
   properties (Access = private)
       filepath
       filename
       workingTable
       recoveryTable
    end
    methods
        function obj = osimTRC(path2TRC)
            % Class Constructor
            if nargin ~= 1
                error(['Numner of inputs is ' num2str(nargin) ', expected 1']);
            end
            if exist(path2TRC, 'file') == 0
                error('File does not exist. Check path is correct')
            else
                [obj.filepath, obj.filename, ext] = fileparts(path2TRC);
                if isempty(obj.filepath)
                    error('Input path must be full path to file (C:/data/Walking.mot)')
                end
            end
            % load java libs
            import org.opensim.modeling.*
            % Use a c3dAdapter to read the c3d file
            obj.workingTable = TRCFileAdapter().read(path2TRC);
            % Store a backup Table that can be recovered
            obj.recoveryTable = obj.workingTable;
        end
        function p = getTRCPath(obj)
            p = obj.filepath();
        end
        function n = getTRCName(obj)
            n = obj.filename();
        end 
        function n = getNumRows(obj)
            % Get the number of Rows of Data
            n = obj.workingTable.getNumRows();
        end
        function n = getNumMarkers(obj)
            % Get the number of markers in the c3d file
            n = obj.workingTable.getNumColumns();
        end
        function timecol = getTimeArray(obj)
            % Get the time column
            timecol = zeros(obj.getNumRows() , 1);
            for i = 1 : obj.getNumRows()
                timecol(i) = obj.workingTable.getIndependentColumn().get(i-1);
            end
        end
        function t = getTimeStart(obj)
            % Get the start time of the c3d file
            timeArray = obj.getTimeArray();
            t = timeArray(1);
        end
        function t = getTimeEnd(obj)
            % Get the end time of the c3d file
            timeArray = obj.getTimeArray();
            t = timeArray(end);
        end
        function labels = getMarkerLabels(obj)
            % Get the list of marker labels
            labels = cell(obj.getNumMarkers(),1);
            for i = 1 : obj.getNumMarkers()
                labels(i) = {char(obj.workingTable.getColumnLabel(i-1))};
            end
        end
        function table = getDataTableClone(obj)
            table = obj.workingTable.clone();
        end
        function trcStruct = getDataAsStructs(obj)
            % Convert the OpenSim tables into Matlab Structures
            trcStruct = osimTableToStruct(obj.workingTable);
        end
        function data = getMarkerData(obj, markerName)
            % Get a Matlab array of data points for a specific trajectory
            % Get Index from the markername
            mIndex = find(contains(obj.getMarkerLabels() , markerName))-1;
            % Get the column vector at index 
            cv = obj.workingTable.getDependentColumnAtIndex(mIndex);
            % Convert the colomn vector into a Matlab array
            data = zeros(obj.getNumRows(), 3);
            for i = 0 : obj.getNumRows() - 1
                data(i+1,:) = osimVec3ToArray( cv.get(i)  );
            end
        end
        function addMarkerToTable(obj, markerName, data)
            import org.opensim.modeling.*
            % Validate input data? must have correct number of rows
            [nr,nc] = size(data);
            if nr ~= obj.getNumRows
                error('Input data length ~= target data length')
            elseif nc ~= 3
                error('Input data does not have 3 columns')
            end
            
            % Instantiate an empty Column vector of vec3's
            markerVector = VectorOfVec3();
            % Resize the Vector for the current table size
            markerVector.resize(obj.getNumRows,1);
            % Fill the vector with the input data
            for i = 0 : obj.getNumRows - 1
               markerVector.set(i, osimVec3FromArray( data(i+1,:) ) );
            end
            % Append the vector to the current table 
            obj.workingTable.appendColumn(markerName,markerVector);
            % Update table meta data key for number of markers
            obj.updMetaData('NumMarkers', obj.workingTable.getNumColumns);
            % Display some information to the user
            disp(['Marker ' markerName ' successfully added to the table']);
        end 
        function addMeanOfTwoMarkers(obj, NewMarkerlabel ,mk1, mk2)
            % Compute the new marker vector
            data = (obj.getMarkerData(mk1) + obj.getMarkerData(mk2))/2;
            % Add the New Marker to the Table
            obj.addMarkerToTable(NewMarkerlabel,data)
        end
        function addFootProjectionMarker(obj, mk)
           % Compute the new projected location of the marker
           data = obj.getMarkerData(mk);
           % Zero all Y values. This assumes the data is correctly rotated.
           data(:,2) = zeros(size(data,1),1);
           % Add new marker to the table 
           obj.addMarkerToTable([mk '_proj'],data);
        end
        function recoverOriginalTable(obj)
            % Overrides working table with stored backup copy of table
            answer = questdlg('Any and all changes to the current table will be lost, Continue?', ...
                     'Revert to Original Data Table', ...
                     'Yes','No','');
            % Handle response
            switch answer
                case 'Yes'
                    obj.workingTable = obj.recoveryTable.clone();
                    disp('Current working Table reverted to original table')
                case 'No'
                    disp('No changes made to current table')
            end
        end
        function writeTRC(obj,postfix)
            % Write marker data to trc file.
            import org.opensim.modeling.*
            % validate the postfix so that the original file doesn't get
            % overidden.
            if isempty(postfix) 
                error('Function must have an input char i.e. _edited')
            end
                
            % Compute an output path to use for writing to file
            outputPath = fullfile(obj.filepath,[obj.filename postfix '.trc']);

            % Write to file
            TRCFileAdapter().write( obj.workingTable, outputPath);
            disp(['Marker file written to ' outputPath]);
        end
        function u = getUnits(obj)
            u = char(obj.workingTable.getTableMetaDataAsString('Units'));
        end		
        function updUnits(obj,InputChar)
            if ~ischar(InputChar)
                error('input must by of type string (char)')
            end
            % Get the current Unit value 
            u = obj.getUnits();
            % Update the Unit value
            obj.updMetaData('Units', InputChar)
            % display change to the User
            disp(['Changed Units from ' u ' to ' obj.getUnits()]);
        end
    end
    methods (Access = private, Hidden = true)
        function updMetaData(obj, KeyName, Value)
            % Update a table meta data key value
            if  isnumeric(Value)
                Value = num2str(Value);
            elseif ~ischar(Value)
                error('MetaDataKey value must be a number of a char')
            end
            % Does the meta data key exist?
            obj.workingTable.hasTableMetaDataKey(KeyName);
            % Remove the Key
            obj.workingTable.removeTableMetaDataKey(KeyName);
            % Add the Key back with the updated value
            obj.workingTable.addTableMetaDataString(KeyName, Value);
        end
    end
end
