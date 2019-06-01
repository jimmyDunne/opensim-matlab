cd('/Users/jimmy/repository/optimalModelFitting/010 - Scaling_gait_model')

import org.opensim.modeling.*

model = Model('imuTrackingModel.osim');

%% Remove all muscles
ms = model.getForceSet();

while ms.getSize() > 0
    ms.remove(ms.get(0));
end

%% Remove markers
MarkerList = {};
ms = model.getMarkerSet();
for i = 0 : model.getMarkerSet().getSize() - 1
    MarkerList = [MarkerList; {char(model.getMarkerSet().get(i))}];
end

for i = 1 : length(MarkerList)
    ms.remove(ms.get(MarkerList{i}));
end

%%
s = model.initSystem();

model.print('imuTrackingModel_edited.osim')














   




