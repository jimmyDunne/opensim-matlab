
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
workingDir = cd

%% get the path to the model and cmc setup file
[filein1, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
cd(pathname)
[filein2, pathname2] = uigetfile({'*.xml','xml'}, 'CMC setup file...');
[filein3, pathname3] = uigetfile({'*.sto','sto'}, 'ID results file...');
cd(workingDir);

% Model
myModel = Model(fullfile(pathname,filein1));
myModel.initSystem();
% CMC Tool
cmcTool = CMCTool(fullfile(pathname2,filein2));
% Inverse Dynamics
m = importdata(fullfile(pathname3,filein3));

%% run the 100% trial
for ii = 1 : length(muscles)
    % change the musle strength of the model
    a(ii) = myModel.getMuscles.get( muscles{ii} ).getMaxIsometricForce ;
end

    myModel.print(fullfile(pathname, resultsFolder, ['myModel_' num2str(100) '.osim']) );
    cmcTool.print( fullfile(pathname, resultsFolder, filein2 ));
    modelFilePath = fullfile(pathname,pathname);
    % Initial CMC run
    [t q] = runCMCtool(100, pathname, [] ,filein2 );
    
    b = a/2;
    c = a;
    % run the max and min CMC results
    % [t q] = runCMCtool(100, pathname,resultsFolder, filein2);

%%
maxValue = 100;
lowestValue = 1;
stepsize = 5;
[currentValue]= midpoint(maxValue,lowestValue );
nSteps = 1;


while stepsize > 1 

    if nSteps == 1
       % run a 50% trial 
        for ii = 1 : length(muscles)
            myModel.getMuscles.get( muscles{ii} ).setMaxIsometricForce( b(ii) ) ;
        end
        myModel.print(fullfile(pathname,resultsFolder, ['myModel_' num2str(mCapacity) '.osim']) );
        % run CMC with new strength
        [t_n q_n] = runCMCtool(50, pathname, resultsFolder ,filein2 );
        % do the comparisons
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);
    end
    
    
    if satisfyQs == 1 && satisfyTs == 1
        maxValue = currentValue;
        currentValue = midpoint(currentValue, lowestValue );
    elseif satisfyQs == 0 || satisfyTs == 0 
        lowestValue  = currentValue;
        currentValue = midpoint(maxValue,currentValue );
    end


    c = b*(currentValue/100);

    % calculate the the step size
    stepsize = mean( abs(b - c) );
    % caluclate the percentage of max
    mCapacity = round((c(1)/b(1))*100) ;

    c = a*(currentValue/100);

        % Change the muscle MaxIsoForce and run again
        for ii = 1 : length(muscles)
            myModel.getMuscles.get( muscles{ii} ).setMaxIsometricForce( b(ii) ) ;
        end
        myModel.print(fullfile(pathname,resultsFolder, ['myModel_' num2str(mCapacity) '.osim']) );
        % run CMC with new strength
        [t_n q_n] = runCMCtool(mCapacity, pathname, resultsFolder ,filein2 );
        % do the comparisons
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);

    b = c;

    display(['stepsize; ' num2str(stepsize) ' || mCapacity; ' num2str(mCapacity) ' || recFemStrength; ' num2str(b(1)) ]  );
    nSteps = nSteps+1;
    
    if nSteps == 4
        break
    end
end
   
% load Handel 
%sound(y,Fs)
%%