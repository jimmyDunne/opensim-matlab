function [OsimFileName] = FindOsim(DataDirectory,OsimFileName)
%Search function for OSIM Files

% This if loop searches determines if the variable OsimFileName exists. If
% YES then it does nothing If NO then it will search the directory given to find a osim file.

%Written by James Dunne
%June 2010

CurrentDirectory=cd;
if isempty(OsimFileName)==1
        cd(DataDirectory)
        ModelFile=dir('*.osim')   ;
        if isempty(ModelFile)==1
            [OsimFileName]=uigetfile('*.osim','Model File',DataDirectory,'MultiSelect','off');
        elseif length(ModelFile)==1
            OsimFileName=char(ModelFile.name);
        elseif length(ModelFile)>1
            [OsimFileName]=uigetfile('*.osim','Model File',DataDirectory,'MultiSelect','off');
        end
else
        OsimFileName=OsimFileName;
end
       
cd(CurrentDirectory)
end
