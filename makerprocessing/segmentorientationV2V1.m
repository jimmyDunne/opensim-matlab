function frame = segmentorientationv2v1(v2,v1)
%% segmentorientationv2v1 calculates an orthoganal coordinate system
%   from the crossproduct of unit vectors 2 and 1 to find vector 3. It then
%   calculates the crossproduct of Vector 2 and Vector 3 to find Vector 1. 

if ~isequal(size(v1), size(v2));
	error('Input Vector arrays are not of equal size')
end

% Get the size of the array. 
[m n] = size(v1);

% create empty Unit Vector Arrays 
e3 = nan(m,3);e2=e3;e1=e3;

% Unit Vec for v1 and V3 
for i=1:m
   e1(i,:)=v1(i,:)/norm(v1(i,:));
   e2(i,:)=v2(i,:)/norm(v2(i,:));
end

% Crossproduct of e3 and e2 and transform to a unit vector (e1)
for i=1:m
   e3(i,:) = cross(e2(i,:),e1(i,:));
   e3(i,:) = e3(i,:)/norm(e3(i,:)); 
end

% Crossproduct of e2 and e1 and to recalculate e3
for i=1:m
   e1(i,:) = cross(e3(i,:),e2(i,:));
   e1(i,:) = e1(i,:)/norm(e1(i,:)); 
end

% frame = [e3 e2 e1];
frame = {};
for i=1:m
	frame{i} = x;
end
