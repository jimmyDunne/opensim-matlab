function q = read_trcFile(fname)
% read_trcFile() uses Matlab methods ONLY
%   Reads data from a trc file. Does not require OpenSim Libraries

fin = fopen(fname, 'r');	
if fin == -1								
	error(['unable to open ', fname])		
end

nextline = fgetl(fin);
trcversion = sscanf(nextline, 'PathFileType %d');
if trcversion ~= 4
	disp('trc PathFileType is not 4, aborting');
	return;
end

nextline = fgetl(fin);

nextline = fgetl(fin);
values = sscanf(nextline, '%f %f %f %f');
numframes = values(3);
q.nummarkers = values(4);
numcolumns=3*q.nummarkers+2;

nextline = fgetl(fin);
q.labels = cell(1, numcolumns);
[q.labels{1}, nextline] = strtok(nextline); % should be Frame#
[q.labels{2}, nextline] = strtok(nextline); % should be Time
for i = 1 : q.nummarkers
	[markername, nextline] = strtok(nextline);
	q.labels{2+i} = markername;
end

nextline = fgetl(fin);
if isspace(nextline(1))
    while true
        nextline = fgetl(fin);
        if ~isspace(nextline(1))
            break
        end
    end
end
        
columns_in_table = length(sscanf(nextline, '%f'));
markers_in_table = (columns_in_table - 2) /3;
if markers_in_table ~= q.nummarkers
    warning(['Number of Marker labels in file (' num2str(q.nummarkers) ') doesnt equal number of columns of marker data (' num2str(markers_in_table) '). '])
end
% Update the number of markers
q.nummarkers = markers_in_table;
% Put the data in an array
data = zeros(numframes,columns_in_table);
for i = 1 : numframes
    data(i,:) = sscanf(nextline, '%f')';
    nextline = fgetl(fin);
end
q.time = data(:,2);
q.data = data(:,3:end);
q.labels = q.labels(3:end);
q.datarate = 1/(q.time(2) - q.time(1));
end