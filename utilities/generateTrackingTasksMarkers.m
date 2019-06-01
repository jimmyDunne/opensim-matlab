function markerList = generateTrackingTasksMarkers(model, trcpath)
%% generateTrackingTasksMarkers
% Generate a list of Marker labels that can be used to make tracking tasks.
% 

%% Import OpenSim Libs
import org.opensim.modeling.*

%% Get the marker Table
trc = TRCFileAdapter().read(trcpath);

%% get the TRC Marker Names
t = TRCFileAdapter().read(trcpath);
trcNames = [];

for i = 0 : t.getNumColumns() - 1
    label = char(t.getColumnLabels().get(i));
    if ~isempty(strfind(label, ':'))
        label = label(strfind(label, ':')+1:end);
    end
    trcNames = [trcNames; {label}];
end

%% Get Model Marker Names
markerNames = [];
for i = 0 : model.getMarkerSet().getSize()-1;
   markerNames = [markerNames; {char(model.getMarkerSet().get(i).getName() )}];    
end

%% Generate a final list of Markers to track
markerList = intersect(markerNames,trcNames);

end