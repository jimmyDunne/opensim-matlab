function torqueProfile = calculateTorqueFailure(topLevelDir, conditions, subSetData)


%% need to get the time array for this data
fileList = getAllFiles(topLevelDir);
for i = 1 : length(fileList)
    fileList{i}(1:length(topLevelDir)) = [];
end
fileNames = getPath2Files(fileList,conditions);

%% Get the joint torque data

% import the data from the inverse dyanamics trial. 
Jt = importdata(fullfile(topLevelDir, conditions{1},conditions{2},conditions{3},'inverse_dynamics.sto'));
% turn that into a timeseries object. 
Jt_timeseries = timeseries(Jt.data(:,2:end),Jt.data(:,1));

%% get the grf data 

% import the data from the inverse dyanamics trial. 
grf = importdata(fullfile(topLevelDir, conditions{1},conditions{2},conditions{3},'ground_reaction.mot'));
% turn that into a timeseries object. 
grf_timeseries = timeseries(grf.data(:,2:end),grf.data(:,1));


%% loop through all the simulations and compare the Jt/grf with Rt

% first, set the Reserve names
Rt.names = {'reserve_hip_flexion_r' 'reserve_hip_adduction_r'...
                        'reserve_hip_rotation_r' 'reserve_knee_angle_r'...
                        'reserve_ankle_angle_r'}';

% get the reserve data for all simulations
Rt.data = subSetData.reserves;
trialNames = fieldnames(Rt.data);
nTrials    = length(trialNames);
                    
                    
% for each one of the simulations (100-5% strength), get the reserve torque
% at each coordinate as a percentage of the total joint moment. 
for i = 1 : nTrials                  
                    
      forceFile = importdata(fullfile(topLevelDir,fileNames{i}));
      initialTime = forceFile.data(1,1);
      finalTime   = forceFile.data(end,1);
      timeArray   = forceFile.data(:,1);
              
      Rt_timeseries = timeseries(Rt.data.(trialNames{i}),timeArray);

      % sync the joint and reserve torques
      [Rt_sync Jt_sync] = synchronize(Rt_timeseries,Jt_timeseries, 'Uniform','Interval',0.01); 
      
      [f grf_sync] = synchronize(Rt_timeseries,grf_timeseries, 'Uniform','Interval',0.01);
      
      
            
      for u = 1 : length(Rt.names)
          
              jtIndex = find(cellfun(@isempty,strfind(Jt.colheaders,[strrep(Rt.names{u},'reserve_','') '_moment'])) == 0); 
                
%               hold
%               plot(Rt_sync.data(:, u))
%               plot(Jt_sync.data(:, jtIndex-1),'r')
%               
              [ Rt_sync101 ] = normalise(Rt_sync.data,50);
              [ Jt_sync101 ] = normalise(Jt_sync.data,50);
           
              [ grf_sync101 ] = normalise(grf_sync.data,50);
              
              
              perTorque = abs(Rt_sync101(:, u))./abs(Jt_sync101(:, jtIndex-1)) ;
          
              %  plot(perTorque);
              torqueProfile.(strrep(Rt.names{u},'reserve_','')).reservePercentage(:,i)      = perTorque;
              torqueProfile.(strrep(Rt.names{u},'reserve_','')).reserves(:,i)              =  Rt_sync101(:, u);
      end
      
      
      
      
end


end