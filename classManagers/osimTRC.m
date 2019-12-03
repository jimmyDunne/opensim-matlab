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
        function self = osimTRC(path2TRC)
            % Constructor for the osimTRC manager. Takes a path to a trc

            % load java libs
            import org.opensim.modeling.*
            % Use a c3dAdapter to read the c3d file
            self.workingTable = TimeSeriesTableVec3(path2TRC);
            % Store a backup Table that can be recovered
            self.recoveryTable = self.workingTable;
            % Store some path names for the 
            [self.filepath, self.filename, ext] = fileparts(path2TRC);
        end
        function p = getTRCPath(self)
            p = self.filepath();
        end
        function n = getTRCName(self)
            n = self.filename();
        end 
        function n = getNumRows(self)
            % Get the number of Rows of Data
            n = self.workingTable.getNumRows();
        end
        function n = getNumMarkers(self)
            % Get the number of markers in the c3d file
            n = self.workingTable.getNumColumns();
        end
        function timecol = getTimeArray(self)
            % Get the time column
            timecol = zeros(self.getNumRows() , 1);
            for i = 1 : self.getNumRows()
                timecol(i) = self.workingTable.getIndependentColumn().get(i-1);
            end
        end
        function t = getTimeStart(self)
            % Get the start time of the c3d file
            timeArray = self.getTimeArray();
            format long g
            t = timeArray(1);
        end
        function t = getTimeEnd(self)
            % Get the end time of the c3d file
            timeArray = self.getTimeArray();
            format long g
            t = timeArray(end);
        end
        function labels = getMarkerLabels(self)
            % Get the list of marker labels
            labels = strings(self.getNumMarkers(),1);
            for i = 1 : self.getNumMarkers()
                labels(i) = char(self.workingTable.getColumnLabel(i-1));
            end
        end
        function table = getDataTableClone(self)
            table = self.workingTable.clone();
        end
        function trcStruct = getDataAsStructs(self)
            % Convert the OpenSim tables into Matlab Structures
            trcStruct = osimTableToStruct(self.workingTable);
        end
        function data = getMarkerData(self, markerName)
            % Get a Matlab array of data points for a specific trajectory
            % Get Index from the markername
            mIndex = find(contains(self.getMarkerLabels() , markerName))-1;
            if isempty(mIndex)
               error(['Marker label ' markerName ' not found.']);
            end
            % Get the column vector at index 
            cv = self.workingTable.getDependentColumnAtIndex(mIndex);
            % Convert the colomn vector into a Matlab array
            data = zeros(self.getNumRows(), 3);
            for i = 0 : self.getNumRows() - 1
                data(i+1,:) = osimVec3ToArray( cv.get(i)  );
            end
        end
        function addMarker(self, markerName, data)
            import org.opensim.modeling.*
            % Validate input data? must have correct number of rows
            [nr,nc] = size(data);
            if nr ~= self.getNumRows
                error('Input data length ~= target data length')
            elseif nc ~= 3
                error('Input data does not have 3 columns')
            end
            % Instantiate an empty Column vector of vec3's
            markerVector = VectorOfVec3();
            % Resize the Vector for the current table size
            markerVector.resize(self.getNumRows,1);
            % Fill the vector with the input data
            for i = 0 : self.getNumRows - 1
               markerVector.set(i, osimVec3FromArray( data(i+1,:) ) );
            end
            % Append the vector to the current table 
            self.workingTable.appendColumn(markerName,markerVector);
            % Update table meta data key for number of markers
            self.updMetaData('NumMarkers', self.workingTable.getNumColumns);
            % Display some information to the user
            disp(['Marker ' markerName ' successfully added to the table']);
        end 
        function addMeanOfTwoMarkers(self, NewMarkerlabel ,mk1, mk2)
            % Compute the new marker vector
            data = (self.getMarkerData(mk1) + self.getMarkerData(mk2))/2;
            % Add the New Marker to the Table
            self.addMarker(NewMarkerlabel,data)
        end
        function addZeroProjectionMarker(self, mk)
           % Computes a marker projected on the floor of the lab (Y = 0).
           % Adds the marker to the internal table. 
           data = self.getMarkerData(mk);
           % Zero all Y values. This assumes the data is correctly rotated.
           data(:,2) = zeros(size(data,1),1);
           % Add new marker to the table 
           self.addMarker([mk '_proj'],data);
        end
        function recoverOriginalTable(self)
            % Overrides working table with stored backup copy of table
            answer = questdlg('Any and all changes to the current table will be lost, Continue?', ...
                     'Revert to Original Data Table', ...
                     'Yes','No','');
            % Handle response
            switch answer
                case 'Yes'
                    self.workingTable = self.recoveryTable.clone();
                    disp('Current working Table reverted to original table')
                case 'No'
                    disp('No changes made to current table')
            end
        end
        function writeTRC(self,postfix)
            % Write marker data to trc file.
            import org.opensim.modeling.*
            % validate the postfix so that the original file doesn't get
            % overidden.
            if isempty(postfix) 
                error('Function must have a string so original file isnt overwritten')
            end                
            % Compute an output path to use for writing to file
            outputPath = fullfile(self.filepath,[self.filename postfix '.trc']);
            % Write to file
            TRCFileAdapter().write( self.workingTable, outputPath);
            disp(['Marker file written to ' outputPath]);
        end
        function u = getUnits(self)
            u = char(self.workingTable.getTableMetaDataAsString('Units'));
        end		
        function updUnits(self,InputChar)
            if ~ischar(InputChar)
                error('input must by of type string (char)')
            end
            % Get the current Unit value 
            u = self.getUnits();
            % Update the Unit value
            self.updMetaData('Units', InputChar)
            % display change to the User
            disp(['Changed Units from ' u ' to ' self.getUnits()]);
        end
        function t = getTableSlice(self, sTime, eTime)
            t = self.workingTable().clone();
            t.trim(sTime,eTime)
        end
        function writeTableSlice(self, sTime, eTime, filePath)
            import org.opensim.modeling.*
            table = self.getTableSlice(sTime,eTime);
            TRCFileAdapter().write(table, filePath)
        end
    end
    methods (Static)
       function trackableMarkers = getTrackableMarkerList(model, mTable)
            % Determine the trackable markers in the trial
            import org.opensim.modeling.*
            % Get all the marker labels in a table
            labels = mTable.getColumnLabels();
            markerlabels = {};
            for i = 0 : labels.size() - 1
                markerlabels(i+1) = {char(labels.get(i))};
            end
            % Get all the marker labels in a model
            markerset w= model.getMarkerSet();
            modelmarkerlabels = {};
            for i = 0 : markerset.getSize() - 1 
                modelmarkerlabels(i+1) = {char(markerset.get(i).getName())};
            end
            % Generate a list from the intersect of both lists
            trackableMarkers = intersect(markerlabels,modelmarkerlabels);
        end 
    end
    methods (Access = private, Hidden = true)
        function updMetaData(self, KeyName, Value)
            % Update a table meta data key value
            if  isnumeric(Value)
                Value = num2str(Value);
            elseif ~ischar(Value)
                error('MetaDataKey value must be a number of a char')
            end
            % Does the meta data key exist?
            self.workingTable.hasTableMetaDataKey(KeyName);
            % Remove the Key
            self.workingTable.removeTableMetaDataKey(KeyName);
            % Add the Key back with the updated value
            self.workingTable.addTableMetaDataString(KeyName, Value);
        end
    end
end
