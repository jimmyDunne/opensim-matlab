
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

%% get the path to the model and cmc setup file
[filein1, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
cd(pathname)
[filein2, pathname2] = uigetfile({'*.xml','xml'}, 'CMC setup file...');
[filein3, pathname3] = uigetfile({'*.sto','sto'}, 'ID results file...');

% Model
myModel = Model(fullfile(pathname,filein1));
myModel.initSystem();
% CMC Tool
cmcTool = CMCTool(fullfile(pathname2,filein2));
% Inverse Dynamics
m = importdata(fullfile(pathname3,filein3));

%%
for ii = 1 : length(muscles)
    % change the musle strength of the model
    a(ii) = myModel.getMuscles.get( muscles{ii} ).getMaxIsometricForce ;
end

    myModel.print(fullfile(pathname,'ResultsCMC', ['myModel_' num2str(a) '.osim']) )

    b = a/2;
    c = a;
    % run the max and min CMC results
    [t q] = runCMCtool(100, pathname, filein2);

    stepsize = 1;
    satisfyQs  = 1;
    satisfyTs  = 1;
    
    while stepsize > 1 
        
        currentStepSize = a/2;
           
        if satisfyQs == 0 && satisfyTs == 0

            b = a + currentStepSize;
            
        elseif satisfyQs == 1 && satisfyTs == 1

            b = a - currentStepSize;

        end
        display( num2str(a) );
        
        % calculate the the step size
        stepsize = mean( abs(a - b) );
        % caluclate the percentage of max
        mCapacity = (b(1)/c(1))*100;
        % change the muscle strength of the model
        for ii = 1 : length(muscles)
            myModel.getMuscles.get( muscles{ii} ).setMaxIsometricForce( b(ii) ) ;
        end
        myModel.print(fullfile(pathname,'ResultsCMC', ['myModel_' num2str(b) '.osim']) );

        % run CMC with new strength
        [t_n q_n] = runCMCtool(mCapacity, pathname, filein2 );
        % do the comparisons
        [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t_n, excludeList);
        
        a = b;
        currentStepSize = stepSize;
    end
   

 load Handel 
 sound(y,Fs)
%%