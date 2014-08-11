





import org.opensim.modeling.*      % Import OpenSim Libraries



cd('C:\Users\vWin7\Documents\GitHub\stackJimmy\strengthAnalysis')


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


% get the path to the model and cmc setup file
[filein, pathname1] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
myModel = Model(fullfile(pathname1,filein));

[filein, pathname] = uigetfile({'*.xml','xml'}, 'Setup model file...');
cmcTool = CMCTool(fullfile(pathname,filein));


muscle = {'vas_med_r'};
startingStrength = [1294 500];

t = []; % matrix of joint torques
q = []; % a matrix of all the coordinate values

%% Use bisection method to converge on criteria
eps_abs = 1e-5;
eps_step = 1e-5;
a = startingStrength(1);
b = startingStrength(2);

% run the max and min CMC results
[t_n q_n] = runCMCtool(a, myModel, mySetup, muscle, pathname);

%% do the comparisons
satisfyQs = compareCoodinates(q, q_n);
satisfyTs = compareTorques(t,t_n);

while stepsize > 0.5 || satisfyQs == 1 && satisfyTs == 1

       c = (a - b)/2;
    
    
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
