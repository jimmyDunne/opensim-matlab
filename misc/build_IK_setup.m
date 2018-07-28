time_LFS = [0.0617 0.7467 1.4317 2.1267 2.8217 3.515 4.2133 4.90 5.5933 6.2883 6.9683 7.640 8.335 9.0183 9.67];

cd('C:\samuel\samsim\lateral_stability\RunningSimulation_subtalarUnlocked\IK');

for cycleNum=1:(length(time_LFS)-1)
    
    xmlDoc = xmlread(['subject02_Setup_IK_generic.xml']);

    xmlDoc.getElementsByTagName('IKTool').item(0).getAttributes.item(0).setValue(['subject02_cycle' num2str(cycleNum)])
    xmlDoc.getElementsByTagName('IKTrial').item(0).getAttributes.item(0).setValue(['subject02_cycle' num2str(cycleNum)])
    xmlDoc.getElementsByTagName('output_motion_file').item(0).getFirstChild.setNodeValue(['subject02' '_running_IK' num2str(cycleNum) '.mot'])
    xmlDoc.getElementsByTagName('time_range').item(0).getFirstChild.setNodeValue([num2str(time_LFS(cycleNum)-.05) ' ' num2str(time_LFS(cycleNum+1))])
    xmlwrite(['subject02_Setup_IK_cycle' num2str(cycleNum) '.xml'], xmlDoc);
    Command = ['IK -S ' 'subject02_Setup_IK_cycle' num2str(cycleNum) '.xml'];
    system(Command);
    fprintf(['Performing IK on cycle # ' num2str(cycleNum)]);
end