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
muscles = {'vas_med_r' 'rect_fem_r' 'vas_int_r' 'vas_lat_r'};
excludeList = {'subtalar_angle_r_reserve' 'mtp_angle_r_reserve' 'subtalar_angle_l_reserve' 'mtp_angle_l_reserve'};
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
[t q] = runCMCtool(pathname,resultsFolder,muscles,100,cmcName,modelName);
display(['mCapacity; ' num2str(100)]);

maxValue        = 100;
lowestValue     = 1;
stepsize        = 5;
currentValue    = midpoint(maxValue, lowestValue);
nSteps          = 1;
stepsize        =[maxValue currentValue];

while abs(stepsize(1)-stepsize(2)) > 1 

    if nSteps == 1
        [t_n q_n] = runCMCtool(pathname,resultsFolder,muscles,currentValue,cmcName,modelName);
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);
        display(['mCapacity; ' num2str(currentValue)]);
    end
    
    stepsize(1) = currentValue;
    
    if satisfyQs == 1 && satisfyTs == 1
        maxValue = currentValue;
        currentValue = midpoint(currentValue, lowestValue );
    elseif satisfyQs == 0 || satisfyTs == 0 
        lowestValue  = currentValue;
        currentValue = midpoint(maxValue,currentValue );
    end

    [t_n q_n] = runCMCtool(pathname,resultsFolder,muscles,currentValue,cmcName,modelName);
    [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);

    % Send some of the results to the display
    display(['mCapacity; ' num2str(currentValue)]);
    
    stepSize(2) = currentValue;
    
    
    nSteps = nSteps+1;
    if nSteps == 10
        break
    end
end
   
load Handel 
sound(y,Fs)
%%