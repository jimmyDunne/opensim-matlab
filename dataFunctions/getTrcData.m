function data = getTrcData(filename, headerLine, DataLine)


% get all the data
tempData = csvread(filename,DataLine-1,0)
[m n] = size(tempData);
nMarkers = (n-2)/3;
% get the header names
fid = fopen(filename,'r');
for i = 1:headerLine
    remain = fgetl(fid);
end
fclose(fid);

for i = 1: ((n-2)/3)+2
    [s{i}, remain] = strtok(remain);
end

data.frames = tempData(:,1);
data.time   = tempData(:,2);

tempData(:,1:2) = [];
s(1:2) = [];


for i = 1 : nMarkers 
    data.markers.(strrep(s{i}, '.', '_')) = tempData(:,i*3-2:i*3);     
end

end