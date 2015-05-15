function outputMatrix = generateCoordinateMatrix(muscleCoordinates)

coordNames = fieldnames(muscleCoordinates);

nCoords = length( coordNames ); 

outputMatrix = [];

for i = 1 : nCoords
    
    coordNames = fieldnames(muscleCoordinates);

    coordRange = muscleCoordinates.(coordNames{i}).coordValue;
    
    zeroMatrix = zeros(length(coordRange),nCoords);
    
    zeroMatrix(:,i) = coordRange;
    
    outputMatrix = [outputMatrix;zeroMatrix];
end

































