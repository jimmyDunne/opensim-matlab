function trials = readOpenSimBatchProcessingFile(fileName)
% Reads andreports the contents of a .batosim file. This file contains
% trial names that will be used in batch simulation. Each 'type' of trial
% has a group name and then trial names in brackets. Contents would
% something like;
% walking
% {
% walking_1
% walking_2
% walking_3
% }
% 
% running
% {
% running_1
% running_2
% running_3
% }


rawData = importdata(fileName);
addValues = 0;

for i = 1 : length(rawData)

    if strcmp(char(rawData(i)),'{')
       addValues = 1;
       groupName = i-1;
       eval(['trials.' char(rawData(groupName)) '={};']); 
       continue
    elseif strcmp(char(rawData(i)),'}')
       addValues = 0;
    end
    
    if addValues 
        eval(['nTrials = length(trials.' char(rawData(groupName)) '); ']);
        eval(['trials.' char(rawData(groupName)) '(nTrials+1,1) = [{ char(rawData(i)) } ] ;    ']);
    end
end
end