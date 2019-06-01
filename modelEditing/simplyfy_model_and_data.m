cd('/Users/jimmy/repository/optimalModelFitting/010 - Scaling_gait_model')

import org.opensim.modeling.*

model = Model('gait2392_simbody.osim');

%% Remove all muscles
ms = model.getForceSet();

while ms.getSize() > 0
    ms.remove(ms.get(0));
end

%% Remove the bodies
bodyList = {};
bs = model.getBodySet();
for i = 0 : model.getBodySet().getSize() - 1
    bodyList = [bodyList; {char(model.getBodySet().get(i))}]
end
deleteBodies = [{'torso'} {'femur_l'} {'tibia_l'} {'talus_l'} {'calcn_l'} {'toes_l'}];

for i = 1 : length(deleteBodies)
    bs.remove(bs.get(deleteBodies{i}));
end

bodyList = {};
bs = model.getBodySet();
for i = 0 : model.getBodySet().getSize() - 1
    bodyList = [bodyList; {char(model.getBodySet().get(i))}];
end
%% Remove joints
jointList = {};
js = model.getJointSet();
for i = 0 : model.getJointSet().getSize() - 1
    jointList = [jointList; {char(model.getJointSet().get(i))}];
end
deleteJoints = [{'hip_l'} {'knee_l'} {'ankle_l'} {'subtalar_l'} {'mtp_l'} {'back'}];

for i = 1 : length(deleteJoints)
    js.remove(js.get(deleteJoints{i}));
end

%% Remove markers
MarkerList = {};
ms = model.getMarkerSet();
for i = 0 : model.getMarkerSet().getSize() - 1
    MarkerList = [MarkerList; {char(model.getMarkerSet().get(i))}];
end

ms_b = ms.clone();
ms = ms_b.clone;

MarkerList = {};
ms = model.getMarkerSet();
for i = 0 : model.getMarkerSet().getSize() - 1
    parentBodyName = strrep(char(ms.get(i).getParentFrameName), '/bodyset/','');
    if sum(contains(bodyList, parentBodyName)) ~= 1
        MarkerList = [MarkerList; {char(ms.get(i))} ]; 
    end
end

for i = 1 : length(MarkerList)
    ms.remove(ms.get(MarkerList{i}));
end

%%
s = model.initSystem();

model.print('single_leg.osim')














   




