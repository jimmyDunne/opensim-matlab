


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
muscles = {'vas_med_r'};

%% get the path to the model and cmc setup file
[filein1, pathname1] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
[filein, pathname] = uigetfile({'*.xml','xml'}, 'Setup model file...');

% Model
myModel = Model(fullfile(pathname1,filein1));
myModel.initSystem();
% CMC Tool
cmcTool = CMCTool(fullfile(pathname,filein));



for ii = 1 : length(muscles)

    %% change the musle strength of the model
    a = myModel.getMuscles.get( char(muscles(ii)) ).getMaxIsometricForce ;
    b = a/2;
    % run the max and min CMC results
    [t_n q_n] = runCMCtool(a, myModel, cmcTool, char(muscles(ii)) , pathname);

    stepsize = 1;
    satisfyQs  = 0;
    satisfyTs  = 0;
    
    %%
    while stepsize > 0.5 || satisfyQs == 1 && satisfyTs == 1

           c = b;


        if satisfyQs == 0 && satisfyTs == 0

            a = a;
            b = c;

        elseif satisfyQs == 1 && satisfyTs == 1

            a = b;
            b = b/2;

        end

        % calculate the the step size
        stepsize = abs(a - b);
        % run CMC with new strength
        [t_n q_n] = runCMCtool(b, myModel, mySetupFile, muscle);
        % do the comparisons
        satisfyQs = compareCoodinates(q, q_n);
        satisfyTs = compareTorques(t, t_n);
    
    end
    %%
end