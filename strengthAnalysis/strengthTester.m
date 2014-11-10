function strengthTester()
% Each muscle group was weakened in isolation. We reduced the maximum
% isometric force until the CMC algorithm could no longer determine a set of muscle
% excitations that would recreate the subject's dynamics with an error less than 2 degrees for all
% degrees of freedom and torques from the reserve actuators that were less than 10% of
% the maximum joint moment at each degree of freedom.
%
% We used the bisection method (Burden and Faires, 1985) to determine how much the maximum isometric
% force of each muscle group could be reduced. This method searches through the space
% of all possible values for the maximum isometric force by iteratively taking the middle
% of an interval representing the maximum and minimum possible values from previous
% iterations until it converges upon the minimum value that could recreate the subject's
% dynamics. This point was termed the required muscle strength for each muscle group
% and was expressed as a percent of the muscle group's maximum isometric force.

import org.opensim.modeling.*      % Import OpenSim Libraries

%% get the path to the model and cmc setup file

% get the path to the model
[modelName, homeFolder] = uigetfile('*.osim', 'OSIM model file...');
[cmcSetupName, homeFolder]   = uigetfile({'*.xml'}, 'CMC setup file...',homeFolder);
cd(homeFolder);

% Inverse Dynamics
%m = importdata(fullfile(pathname3,idName));


%% get muscle ans exclusion names
[muscGroups excludeNames] = readGroupNames;

%%
groupNames = fieldnames(muscGroups);
nGroups    = length(groupNames);

for i = 1 : nGroups

    % Results folder name
    workingFolder = fullfile(homeFolder,[ 'ResultsCMC_' char(groupNames{i})]) ;

    % if the folder doesnt already exist, create it. This is due to CMC
    % having issues with printing to a folder that doesnt exist. 
    if exist(workingFolder)
        continue
    else
        mkdir(workingFolder)
    end

    
    maxValue        = 100;
    lowestValue     = 1;
    stepSize        = 5;
    currentValue    = midpoint(maxValue, lowestValue);
    nSteps          = 1;
    stepSize        =[maxValue currentValue];
    muscleNames     = muscGroups.(groupNames{i});

    % Scale the muscle strength (none, in this case) and print a copy of 
    % the model
    display(['mCapacity; ' num2str(100)]);
    % Get the path to the original model
    modelPath = fullfile(homeFolder, modelName);
    % Copy, scale the muscles, and print Model to the working Folder
    modelOutputPath = strengthScaler(modelPath,muscleNames,100,workingFolder);
    % Run CMC on the new copied model, printing the results to a
    % sub-directory of the working folder. 
    [t q] = runCMCtool(homeFolder,cmcSetupName,modelOutputPath);


    % Run more CMC trials, using a biesection method. Method will end when the
      % step size, as a percentage of max strength, is less than 1.
    while abs(stepSize(1)-stepSize(2)) > 1

        if nSteps == 1
            display(['mCapacity; ' num2str(currentValue)]);
            [t_n q_n] = runCMCtool(homeFolder,workingFolder,muscleNames,currentValue,cmcSetupName,modelName);
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
        % run again
        [t_n q_n] = runCMCtool(homeFolder,workingFolder,muscleNames,currentValue,cmcSetupName,modelName);
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);


        stepSize(2) = currentValue;


        nSteps = nSteps+1;
        if nSteps == 10
            break
        end
    end

end

load Handel
sound(y,Fs)
