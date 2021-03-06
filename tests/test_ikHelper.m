%% test_ikHelper.m
dataFolder = 'test_data';
model_name = 'single_leg.osim';
markerFile_name = 'subject01_walk1.trc';

%% Instantiate a helper
ik = ikHelper(fullfile(dataFolder,model_name),fullfile(dataFolder,markerFile_name));

%% Get a copy of the markerweightSet that you can print to file
mws = ik.getMarkerWeightSet();

%% Get a cell array of character labels
ml = ik.getMarkerLabels();

%% Change the weights of some markers
ik.setMarkerWeight('R.ASIS', 10);
ik.setMarkerWeight('L.ASIS', 10);
ik.setMarkerWeight(ml{end}, 10);

%% 
ik.run()

e = ik.getErrors();
a = ik.getAngles();

ik.printMot(fullfile(dataFolder,'output.mot'))

%%
markerFile_name = 'subject01_static.trc';
ik = ikHelper(fullfile(dataFolder,model_name),fullfile(dataFolder,markerFile_name));
ik.run();
e = sum(ik.getErrors());
ik.printMot(fullfile(dataFolder,'subject01_static.mot'))
