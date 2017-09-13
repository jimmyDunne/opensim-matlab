classdef writeMOT < matlab.mixin.SetGet
    properties
        table
        filename
        directory
    end
    methods
        function obj = writeMOT(osimtable)
           
            import org.opensim.modeling.*
            
            if isempty(strfind(osimtable.getClass, 'TimeSeriesTable'))
               disp('Input is not an OpenSim Times Series Table') 
            end
            
            if ~isempty(strfind(osimtable.getClass, 'Vec3'))
                postfix = StdVectorString(); 
                postfix.add('_x');
                postfix.add('_y');
                postfix.add('_z');
                osimtable = osimtable.flatten(postfix);
                disp('TimesSeriesVec3 converted to TimesSeriesTable')
            end
                
            obj.table = osimtable;
            
            
            
        end
        
        function setFileName(obj,filename)
            obj.filename = filename;
        end
        
        function setFileDirectory(obj, directory)
            obj.directory = directory;
        end
        
        function write(obj)
            if isempty(obj.filename)
                error('filename property has not been set')
            end
            if isempty(obj.directory)
                error('directory property has not been set')
            end
            
            import org.opensim.modeling.*

            fullpath = fullfile(obj.directory,[obj.filename '.mot']);
            
            STOFileAdapter().write(obj.table,fullpath);
            display([[obj.filename '.mot'] ' written to dir: ' fullpath]);
        end
%         function convertToMeters(obj, 
%         
%             
%         end

    end
    methods (Access = private, Hidden = true)    
        
        
    end
end
    
    
    
    