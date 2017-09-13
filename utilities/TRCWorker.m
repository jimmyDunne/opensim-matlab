classdef TRCWorker  < matlab.mixin.SetGet
    properties
        table 
        name
        path
    end
    methods
        function readTRC(obj)
            import org.opensim.modeling.*
            if isempty(obj.name)
                error('name not set. use setName() to set a file name')
            elseif isempty(obj.path)
                error('path not set. use setPath() to set a file path')
            end
            % define the absolute path to the file
            fullfilepath = fullfile(obj.path, [obj.name '.trc']);
            % Use the OpenSim adapter to read the file
            table = TRCFileAdapter().read(fullfilepath)
            % set the objects table
            obj.setTable(table)
        end
        function writeTRC(obj)
            import org.opensim.modeling.*
            if isempty(obj.name)
                error('name not set. use setName() to set a file name')
            elseif isempty(obj.path)
                error('path not set. use setPath() to set a file path')
            end
            
            % define the absolute path to the file
            fullfilepath = fullfile(obj.path, [obj.name '.trc']);
            
            % use OpenSim file adapter to print the table to file
            TRCFileAdapter().write(obj.table, fullfilepath );
            
            display(['TRC file written: ' fullfilepath ]);
        end
        function setTable(obj,osimtable)
            % Sets the internal table to a new table
            
            % check that the input class is correct
            obj.tablecheck(osimtable)
            % update the internal table
            obj.table = osimtable;
        end 
        function setName(obj,name)
            % Set the filename 
            obj.name = name;
        end
        function setPath(obj, path)
            % set the directory path
            obj.path = path;
        end
   end
    methods (Access = private, Hidden = true)
        function tablecheck(obj,osimtable)
            
            if isempty(strfind(osimtable.getClass, 'TimeSeriesTable'))
               error('Input is not an OpenSim Times Series Table') 
            end

            if isempty(strfind(osimtable.getClass, 'Vec3'))
                error('Input is not an OpenSim Vec3 Times Series Table') 
            end    
        end  
    end
end