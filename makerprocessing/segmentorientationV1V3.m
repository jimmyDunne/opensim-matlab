function frame = segmentorientationV1V3(V1,V3)
%% segmentorientationV1V3 calculates an orthoganal coordinate system
%   from the crossproduct of unit vectors 1 and 3 to find vector 2. It then
%   calculates the crossproduct of Vector 1 and Vector 2 to find Vector 3. 

% Check for size
if ~isequal(size(V1), size(V3));
	error('Input Vector arrays are not of equal size')
end

% Get the size of the array. 
[m n] = size(V1);

% create empty Unit Vector Arrays 
e1 = nan(m,3); e2 = e1; e3 = e1;

% Unit Vec for V1 and V3 
for i=1:m
   e1(i,:)=V1(i,:)/norm(V1(i,:));
   e3(i,:)=V3(i,:)/norm(V3(i,:));
end

% Crossproduct of e3 and e1 and transform to a unit vector (e2)
for i=1:m
   e2(i,:) = cross(e3(i,:),e1(i,:));
   e2(i,:) = e2(i,:)/norm(e2(i,:));
end

% Crossproduct of e1 and e2 and to recalculate e3
for i=1:m
   e3(i,:) = cross(e1(i,:),e2(i,:));
   e3(i,:) = e3(i,:)/norm(e3(i,:));
end

% frame = [e1;e2;e3];

frame = {};
for i=1:m
	frame{i} = [e1(i,:);e2(i,:);e3(i,:)];
end

