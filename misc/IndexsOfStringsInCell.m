function [StringIndex IndexCount] = IndexsOfStringsInCell(cellarray, InputString)
%% Get the Indices of the input string
IndexC = strfind(cellarray, InputString);
%% Get the Index's in the cell Array
StringIndex = find(not(cellfun('isempty', IndexC)));
%% Number of occurances
IndexCount = size(StringIndex,1);
end
