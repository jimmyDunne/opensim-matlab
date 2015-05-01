function data = getMotData(filename)



fid = fopen(filename);
c = textscan(fid, '%s','delimiter', '\t');
fclose(fid);


record = 0;
colHeaders = [];

for i = 1:length(c{1,1})
    
    if strcmp(c{1,1}{i},'time')
        record = 1;
    elseif ~isempty( str2num(c{1,1}{i}) )
    break
    end
    
    
    if record == 1
        colHeaders =  [colHeaders { c{1,1}{i} }];
    end
end


temp.colHeaders = colHeaders;
temp.data    = dlmread(filename, '\t', 11, 0);

for i = 1:length(temp.colHeaders)
    data.(temp.colHeaders{i}) = temp.data(:,i);
end