function [S C] = FindOsim(varargin)
% Returns a Struct of osim files anywhere in (or below) an input path. If
% no input, will search the current directory. 

if nargin == 0
    path = cd;
elseif nargin == 1
    path = varargin{1};
end

currentDir = cd;

% Change Dir to input Dir
cd(path)
% Return a struct of osim files
S = dir('**/*.osim');
cd(currentDir);

% Output as a cell array with full paths
C = {};
for i = 1 : length(S)
    C(i) =  {fullfile(S(i).folder, S(i).name)};
end

end
