function [data] = getStoData(filename)

tempData = csvread(filename,7,0);
[m n] = size(tempData);

% get the header names
fid = fopen(filename,'r');
for i = 1:7
    remain = fgetl(fid);
end
fclose(fid);

for i = 1: n
    [s{i}, remain] = strtok(remain);
end

for i = 1 : n 
    data.(strrep(s{i}, '.', '_')) = tempData(:,i);     
end



