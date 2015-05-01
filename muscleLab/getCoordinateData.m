function [colheaders,data,motionFilePath] = getCoordinateData(varargin)

if nargin == 0
        [motFile, pathname] = uigetfile({'*.mot','mot'}, 'Motion file...');
        if motFile == 0
            data = [];
            colheaders = [];
            return
        end
elseif nargin == 1 
    if ischar(varargin{1})
        [pathname,name,ext] = fileparts(varargin{1});
        motFile = [name ext];
    end
end
        
    motionFilePath = fullfile(pathname,motFile);
    newData1 = importdata(motionFilePath);
    colheaders = newData1.colheaders;
    data = newData1.data;
    % Take out the time colomn from the data
    [nFrames nCoord] = size(data);
    if ~isempty( strmatch( 'time', char(colheaders(1)) ) )
        colheaders(:,1) = [];
        data(:,1) = [];
    end
    [nFrames nCoords] = size(data);

end