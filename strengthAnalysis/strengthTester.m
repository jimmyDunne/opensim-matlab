import org.opensim.modeling.*      % Import OpenSim Libraries

% Each muscle group was weakened in isolation. We reduced the maximum
% isometric force until the CMC algorithm could no longer determine a set of muscle
% excitations that would recreate the subject’s dynamics with an error less than 2 degrees for all
% degrees of freedom and torques from the reserve actuators that were less than 10% of
% the maximum joint moment at each degree of freedom.

% We used the bisection method (Burden and Faires, 1985) to determine how much the maximum isometric
% force of each muscle group could be reduced. This method searches through the space
% of all possible values for the maximum isometric force by iteratively taking the middle
% of an interval representing the maximum and minimum possible values from previous
% iterations until it converges upon the minimum value that could recreate the subject’s
% dynamics. This point was termed the required muscle strength for each muscle group
% and was expressed as a percent of the muscle group’s maximum isometric force.


%%
%muscles = {'vas_med_r' 'rect_fem_r' 'vas_int_r' 'vas_lat_r'};

%muscles = {'glut_max1_r'...
%            'glut_med1_r' 'glut_med2_r' 'glut_med3_r'...
%            'glut_min1_r' 'glut_min2_r' 'glut_min3_r'...
%            'peri_r' 'sar_r' 'tfl_r'};

% muscles = {'flex_dig_r' 'flex_hal_r'...
%             'lat_gas_r' 'med_gas_r' ...
%             'per_brev_r' 'per_long_r'...
%             'soleus_r' 'tib_post_r'};

% muscles = {'ext_dig_r' 'ext_hal_r'...
%            'per_tert_r' 'tib_ant_r'};
       
muscles = {'bifemsh_r' 'bifemlh_r'...
           'semiten_r' 'semimem_r'};
       

excludeList = {'reserve_arm_flex_r','reserve_arm_add_r','reserve_arm_rot_r','reserve_elbow_flex_r','reserve_arm_flex_l','reserve_arm_add_l','reserve_arm_rot_l','reserve_elbow_flex_l','reserve_lumbar_extension','reserve_lumbar_bending','reserve_lumbar_rotation','reserve_pro_sup_r','reserve_pro_sup_l';};
resultsFolder = 'ResultsCMC';
workingDir = cd;

%% get the path to the model and cmc setup file
[modelName, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
cd(pathname)
[cmcName, pathname] = uigetfile({'*.xml','xml'}, 'CMC setup file...');
[idName, pathname3] = uigetfile({'*.sto','sto'}, 'ID results file...');
cd(workingDir);

% Inverse Dynamics
m = importdata(fullfile(pathname3,idName));
% Results folder name
resultsFolder = 'ResultsCMC';

%% run the 100% trial
display(['mCapacity; ' num2str(100)]);
[t q] = runCMCtool(pathname,resultsFolder,muscles,100,cmcName,modelName);

maxValue        = 100;
lowestValue     = 1;
stepSize        = 5;
currentValue    = midpoint(maxValue, lowestValue);
nSteps          = 1;
stepSize        =[maxValue currentValue];

%% Run more CMC trials, using a biesection method. Method will end when the 
  % step size, as a percentage of max strength, is less than 1. 
while abs(stepSize(1)-stepSize(2)) > 1 

    if nSteps == 1
        display(['mCapacity; ' num2str(currentValue)]);
        [t_n q_n] = runCMCtool(pathname,resultsFolder,muscles,currentValue,cmcName,modelName);
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);
    end
    
    stepSize(1) = currentValue;
    
    if satisfyQs == 1 && satisfyTs == 1
        maxValue = currentValue;
        currentValue = midpoint(currentValue, lowestValue );
    elseif satisfyQs == 0 || satisfyTs == 0 
        lowestValue  = currentValue;
        currentValue = midpoint(maxValue,currentValue );
    end

    % Send some of the results to the display
    display(['mCapacity; ' num2str(currentValue)]);
    [t_n q_n] = runCMCtool(pathname,resultsFolder,muscles,currentValue,cmcName,modelName);
    [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);

    
    stepSize(2) = currentValue;
    
    
    nSteps = nSteps+1;
    if nSteps == 10
        break
    end
end
   
load Handel 
sound(y,Fs)
%%