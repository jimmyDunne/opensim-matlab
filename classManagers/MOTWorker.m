classdef MOTWorker < matlab.mixin.SetGet
    properties
        table
        name
        path
    end
    methods
        function writeMOT(obj)
            import org.opensim.modeling.*
            if isempty(obj.name)
                error('name not set. use setName() to set a file name')
            elseif isempty(obj.path)
                error('path not set. use setPath() to set a file path')
            end
            % Update the label names 
            obj.updateLabelNames()
            % Update the header info to inclde 'nCol' and 'nRows'
            table_clone = obj.updateheaderinfo();
            % define the absolute path to the file
            fullfilepath = fullfile(obj.path, [obj.name '.mot']);
            % use  OpenSim file adapter to print the table to file
            STOFileAdapter().write(table_clone, fullfilepath );
            display(['MOT file written: ' fullfilepath ]);
        end
        function setTable(obj, osimTable)
            % Flatten Table if Vec3
            osimTable = obj.flattenTable(osimTable);
            % Set the table 
            obj.table = osimTable;
        end
        function setName(obj,name)
            obj.name = name;
        end
        function setPath(obj, path)
            obj.path = path;
        end
        function point2mm(obj)
            table_clone = obj.table.clone();
            % Get a vector of column labels
            labels = table_clone.getColumnLabels();
            for i = 0 : labels.size() - 1
                % Get the Current Label
                label = char(labels.get(i));
                if ~isempty(strfind(label,'p'))
                    % if the label is a point (designated with 'p')
                    for u = 0 : table_clone.getNumRows()-1
                        % Get the point data
                        point = table_clone.getDependentColumnAtIndex(i).get(u);
                        % Divide the point by 1000 and set.
                        table_clone.getDependentColumnAtIndex(i).set(u,point/1000);
                    end
                end
            end 
            % override the internal table
            obj.setTable(table_clone)
            disp('Internal table point converted to mm')
        end
    end
    methods (Static)
       function osimTable = flattenTable(osimTable)
            % Flattens a Vec3 table into a table of doubles
            import org.opensim.modeling.*
            % Check that the input table is a TimesSeriesTable
            if isempty(strfind(osimTable.getClass, 'TimeSeriesTable'))
               disp('Input is not an OpenSim Times Series Table') 
            end
            % Check that the input table is of Vec3 type
            if ~isempty(strfind(osimTable.getClass, 'Vec3'))
                postfix = StdVectorString(); 
                postfix.add('_x');
                postfix.add('_y');
                postfix.add('_z');
                osimTable = osimTable.flatten(postfix);
                disp('TimesSeriesVec3 converted to TimesSeriesTable')
            end
       end 
    end
    
    methods (Access = private, Hidden = true)    
        function table_clone = updateheaderinfo(obj)
            table_clone = obj.table.clone();
            if table_clone.getTableMetaDataKeys().size() > 0
                for i = 0 : table_clone.getTableMetaDataKeys().size() - 1
                    % get the metakey string at index zero. Since the array gets smaller on
                    % each loop, we just need to keep taking the first one in the array. 
                    metakey = char(table_clone.getTableMetaDataKeys().get(0));
                    % remove the key from the meta data
                    table_clone.removeTableMetaDataKey(metakey)
                end
            end
            % Add the column and row data to the meta key    
            table_clone.addTableMetaDataString('nColumns',num2str(table_clone.getNumColumns()+1))
            table_clone.addTableMetaDataString('nRows',num2str(table_clone.getNumRows()));
        end
        function updateLabelNames(obj)
            table_clone = obj.table.clone();
            labels = table_clone.getColumnLabels();
            for i = 0 : labels.size() - 1
                label = char(labels.get(i));

                if i < 9
                    n = '1';
                elseif  8 < i < 18;
                    n = '2';
                elseif 17 < i < 27;
                   n = '3';
                end

               if ~isempty(strfind(label,'f'))
                    s = ['ground_force_' n '_v'];
                elseif ~isempty(strfind(label,'p'))
                    s = ['ground_force_' n '_p'];
                elseif ~isempty(strfind(label,'m'))
                    s = ['ground_torque_' n '_m'];
                else
                    error(['Column name ' label ' isnt recognized as a force, point, or moment'])
                end
                    % Get the index for the underscore
                    % in = strfind(label,'_');
                    % add the specifier (f,p,or m) to the label name. 
                    %label_new = [label(1:in) s label(in+1:end)];
                    label_new = [s label(end)];

                    % update the label name 
                    labels.set(i,label_new);
            end
            % set the column labels
            table_clone().setColumnLabels(labels)
            obj.setTable(table_clone)
        end
    end
end
    
    
    
    