%%

topLevelDir = 'E:\experiments\loadedWalking\loadedWalking_gait2392_thelen';

[muscGroups, excludeList] = readGroupNames(topLevelDir);

muscleGNames = fieldnames(muscGroups)';


%

for i = 1 : length(muscleGNames)

    conditions = {'subject05' 'loaded' 'trial06' muscleGNames{i} 'force'};
    
    subSetData = interMediateFunction(topLevelDir,conditions);
    
    eval([ 'torqueProfile_' muscleGNames{i} '= calculateTorqueFailure(topLevelDir, conditions, subSetData)']);

end


 







% conditions = {'subject05' 'loaded' 'trial01' 'dorsiFlex' 'force'};
% subSetData = interMediateFunction(topLevelDir,conditions);
% 
% conditions = {'subject05' 'loaded' 'trial01' 'planterFlex' 'force'};
% subSetData = interMediateFunction(topLevelDir,conditions);
% 
% conditions = {'subject05' 'loaded' 'trial01' 'quad' 'force'};
% subSetData = interMediateFunction(topLevelDir,conditions);








mgroups   = fieldnames(subSetData);


for i = 1 : length(mgroups)
trialName = fieldnames(subSetData.(mgroups{i}));

    figCell = [];
    for u = 1 : length(trialName)

        figure(i)
           eval([ 'ax' num2str(u) '= subplot(4,5,length(trialName)+1 - u) ;']);
           x = subSetData.(mgroups{i}).(trialName{u});
           area(x)
            
           axis([0 2400 0 4000])
            
           title(strrep(trialName{u},'strength_hipabd_','') )


            xlabel('time')
            ylabel('force') 
           
    end
    
       
end






















