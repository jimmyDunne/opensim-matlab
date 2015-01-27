function runIKtool(varargin)
import org.opensim.modeling.*      % Import OpenSim Libraries

for i = 1 : nargin
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'model'))
            path2Model = char(varargin{i+1});
            
        end
   end
   
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'setup'))
            path2setupFile = char(varargin{i+1});
        end
   end
   
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'data'))
            path2data = char(varargin{i+1});
        end
   end
   
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'time'))
            if ischar(varargin{i+1})
                if ~isempty(strfind(varargin{i+1}, 'all'))
                    timeArray = getTrcTimes(path2data);
                    timeData  = [timeArray(7) timeArray(end)];
                end
            else
                timeData = varargin(i+1);
            end
       end
     end
end

%% ikTool
ikTool = InverseKinematicsTool( path2setupFile );

%% set start and end times
ikTool.setStartTime( timeData(1) )
ikTool.setEndTime( timeData(2) )

%% set model
myModel = Model(path2Model);
ikTool.setModel(myModel)

%% set marker data
ikTool.setMarkerDataFileName(path2data)

%% Set output motion name
[filePath, fileName, ext] = fileparts(path2data);
ikTool.setOutputMotionFileName(fullfile(filePath, [fileName '_ik.mot']))

%% Run CMC
display(['Running IK using ' fileName '.trc']);
ikTool.run();

% Print the setup file encase of error
ikTool.print(fullfile(filePath,'ik_Setup_edited.xml'));


clear ikTool
java.lang.System.gc()






