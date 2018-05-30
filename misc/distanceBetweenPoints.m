function d = distanceBetweenPoints(p1, p2)
%% distanceBetweenPoints % Compute the distance between two 3D points.
% get the vector between the points
if ~isequal(size(p1), size(p2))
	error('input arrays are of different sizes')
end
% Pre-allocate an array for the distance
d = zeros(size(p1,1),1);
% Calc the vector between the two points
v = p1 - p2;
% Calc the length of the vector
for i = 1 : size(v,1)
   d(i) = norm(v(i,:)); 
end
