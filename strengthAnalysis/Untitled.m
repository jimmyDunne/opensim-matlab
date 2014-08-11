


import org.opensim.modeling.*      % Import OpenSim Libraries


ikSetupFile = 'C:\Users\vWin7\Documents\GitHub\stackJimmy\strengthAnalysis\Gait2392_Simbody\subject01_Setup_IK.xml'



% get the path to the model and cmc setup file
[filein, pathname1] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
myModel = Model(fullfile(pathname1,filein));

myState = myModel.initSystem()


ikTool = InverseKinematicsTool(ikSetupFile)
ikTool.setModel(myModel)




ikTool.run()
% # Load a motion
loadMotion(ikMotionFilePath)
% #initialize
myState = myModel.initSystem()



[filein, pathname] = uigetfile({'*.xml','xml'}, 'Setup model file...');
cmcTool = CMCTool(fullfile(pathname,filein));

cmcTool.setModel(myModel)
cmcTool.run()











