function [muscNames excludeNames] = readGroupNames

currentFolder    = cd;
existMusclesFile = [];
existExcludeFile = [];

while isempty(existMusclesFile) == 1 && isempty(existExcludeFile) == 1

    existMusclesFile = dir('*.muscles');
    existExcludeFile = dir('*.excludeList');
    tempFolder = cd;
    
    cd(fileparts(tempFolder))
end

%% Read the muscle file
% get the full path to the file
fileName = fullfile(tempFolder, existMusclesFile.name);
% create a structure of names
muscNames = readMuscleFile(fileName);

%% Read the exclude file
% get the full path to the file
fileName = fullfile(tempFolder, existExcludeFile.name);
% create a structure of names
excludeNames = readExcludeFile(fileName);
 
cd(currentFolder)

end



function muscles = readMuscleFile(fileName);

rawData = importdata(fileName);
addValues = 0;

for i = 1 : length(rawData)

    if strcmp(char(rawData(i)),'{')
       addValues = 1;
       groupName = i-1;
       eval(['muscles.' char(rawData(groupName)) '={};']); 
       continue
    elseif strcmp(char(rawData(i)),'}')
       addValues = 0;
    end
    
    if addValues 
        eval(['nMusc = length(muscles.' char(rawData(groupName)) '); ']);
        eval(['muscles.' char(rawData(groupName)) '(nMusc+1,1) = [{ char(rawData(i)) } ] ;    ']);
    end
end
end


function exclude = readExcludeFile(fileName)
    exclude = importdata(fileName);
end
