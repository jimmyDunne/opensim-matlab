function subSetData = getDataFromFiles(topLevelDir,fileNames)





[muscGroups, excludeList] = readGroupNames(topLevelDir);

muscGroups.reserves = {'reserve_hip_flexion_r' 'reserve_hip_adduction_r'...
                        'reserve_hip_rotation_r' 'reserve_knee_angle_r'...
                        'reserve_ankle_angle_r' 'FX' 'FY' 'FZ' 'MX' 'MY' 'MZ'}';

groupNames = fieldnames(muscGroups);


for ii = 1 : length(fileNames)

    
    [PATHSTR,name,EXT] = fileparts(fullfile(topLevelDir,fileNames{ii}));
    [PATHSTR,name,EXT] = fileparts(PATHSTR);
    
    sIndex =   name(strfind(name,'_')+1 : end);
    
        
    
    data = importdata(fullfile(topLevelDir,fileNames{ii}));



    for i = 1:length(groupNames)
        dataIndex = [];
        for u = 1 : length(muscGroups.(groupNames{i}))

                dataIndex = [dataIndex;strmatch(muscGroups.(groupNames{i}){u}, data.colheaders )];
        end

        subSetData.(groupNames{i}).(['strength_' sIndex]) = data.data(:,dataIndex');
    end
    
end

