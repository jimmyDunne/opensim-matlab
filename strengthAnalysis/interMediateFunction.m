function subSetData = interMediateFunction(topLevelDir, conditions)



%% get a list of ALL of the functions in every subfolder of 'topLevelDir'


fileList = getAllFiles(topLevelDir);
for i = 1 : length(fileList)
    fileList{i}(1:length(topLevelDir)) = [];
end


%%

fileNames = getPath2Files(fileList,conditions);




subSetData = getDataFromFiles(topLevelDir,fileNames);





