function p = moveFromFrame(type,origin,v1,vn,point);

% Check for the length of the input Vectors and Point
if size(v1,1) ~= size(point,1) || size(vn,1) ~= size(point,1)
    error(' Input Vectors are not all the same length')
end    

% Create a local frame from the input vectors
if strcmp(type,'V1V3')
    frame = segmentorientationV1V3(v1,vn);
elseif strcmp(type,'V2V1')
    frame = segmentorientationV2V1(vn,v1);
end

% Pre allocate an output array
p = zeros( size(point,1), 3);

% Rotate the point (b = Ax)
for i = 1 : length(frame)
    p(i,:) = (inv(cell2mat(frame(i)))  * point(i,:)') + origin(i,:)' ;
end

end


