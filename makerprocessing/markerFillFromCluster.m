function markerFillFromCluster(data, inputString)

inputString = 'Torso_IMU'


% Get the field names of the structure
markerLabels = fieldnames(data)
% Get the Indexs of the grouped markers
[I,nI] = IndexsOfStringsInCell(markerLabels, inputString);



% Make a substructure
ss = struct()
for i = 1 : nI
    ss.(markerLabels{I(i)}) = data.(markerLabels{I(i)});
end
% Get the number of rows
nRows = length(ss.(markerLabels{I(i)}))

%% Find when all four markers exist and define the transforms for each.
for i = 1 : nI
    ss_f(:,i) = ~isnan(ss.(markerLabels{I(i)})(:,1))
end

mk1_e = find(ss_f(:,1));
mk2_e = find(ss_f(:,2));
mk3_e = find(ss_f(:,3));
mk4_e = find(ss_f(:,4));

% Get the frames when all markers are visible
af = intersect( intersect(mk1_e,mk4_e), intersect(mk2_e,mk3_e) );

%% Dump the marker data out into individual variables for easy reading
mk1 = ss.(markerLabels{I(1)});
mk2 = ss.(markerLabels{I(2)});
mk3 = ss.(markerLabels{I(3)});
mk4 = ss.(markerLabels{I(4)});

%% Define the location of each marker in the frame of the other three
% mkr1
origin = (mk2(af,:) + mk3(af,:) + mk4(af,:))/3;
v1 = origin - mk2(af,:)  ;
v3 = origin - mk4(af,:);
p = moveToFrame('V1V3',origin,v1,v3, mk1(af,:));

range(opens(mk2, mk3))

% mkr2

% mkr3

% mkr4





end











