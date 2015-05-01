function muscles = getfLfromMot_draft(varargin)
%% Uses a ss file to get the fLfV curves for each muscle. 
%
%
% 
% Author: James Dunne.  Date: August 2014
% muscles = getfLfromMot(myModel, muscles )
% 
% 
% g = getfLfromMot('model','c:/opensim/models/gait2392/gait2392.osim',...
%                  'motion','c:/opensim/models/gait2392/trial1.mot',...
%                  'muscles',{'rec_fem' 'vast_int_r'});

% muscleNames = {'glut_max2_l' 'soleus_r' 'tib_post_r'}

import org.opensim.modeling.*      % Import OpenSim Libraries

% staticData = varargin;
% return

for i = 1 : nargin
    
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'model'))
            modelPath = varargin{i+1};
            myModel = Model(char(modelPath));
            s =  myModel.initSystem();
        end
    end
    
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'motion'))
            motionPath = varargin{i+1};
        end
   end

   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'muscles'))
            muscleNames = varargin{i+1};
        end
   end
end


if ~exist('modelPath', 'var')
    [filein, pathname] = uigetfile({'*.osim','osim'}, 'OSIM model file...');
    myModel = Model(fullfile(pathname,filein));
    s =  myModel.initSystem();
end

if ~exist('motionPath', 'var')
    [colheaders,data,path2motion] = getCoordinateData;
    if ~isempty(data)
        compareMotModelCoord(myModel, colheaders);
    end
else exist('motionPath', 'var')
    [colheaders,data] = getCoordinateData(motionPath);
    compareMotModelCoord(myModel, colheaders);
end


modelMuscles = getCoord4Musc( myModel , s);
modelMuscleNames = fieldnames(modelMuscles);
if exist('muscleNames', 'var')
    muscleIndex = [];
    for i = 1 : length(muscleNames);
        if ~isempty(strmatch(muscleNames{i}, modelMuscleNames))
            muscleIndex = [muscleIndex strmatch(muscleNames{i}, modelMuscleNames)];
        end
    end
     musclesList = modelMuscleNames(muscleIndex);
else
    musclesList = modelMuscleNames;
end



%% get the basline curves
muscleCoordinates = getForceLength(myModel, s, musclesList);

% zero matrix for dumping data


%% For each muscle and each row of data, set the coordinates values 
  % of the model, run equilibrateMuscles.  

for i = 1 : length(musclesList)

   % Get the muscle that is needed 
   myForce = myModel.getMuscles().get(musclesList(i));
   % Get the muscleType of that myForce 
   muscleType = char(myForce.getConcreteClassName);
   % Get a reference to the concrete muscle class in the model
   eval(['myMuscle =' muscleType '.safeDownCast(myForce);'])
   % Display the muscle name
   display(char(myMuscle))
   

   for k = 1 : length(data)
     
           % Loop through and updated the model coordinate value's
           for j = 1 : myModel.updCoordinateSet.getSize
                updCoord = myModel.updCoordinateSet.get( j-1 );
                updCoord.setValue(s,  deg2rad(data(k, j )) );
                updCoord.setSpeedValue(s, 0 );
           end
                
                % Set the activation and fiber length
                myMuscle.setActivation( s, 1 )
                myMuscle.setDefaultFiberLength( 0.01 )
                myMuscle.setFiberLength( s, 0.01 )
                
                % Equilibrate the forces from the activation 
                myModel.equilibrateMuscles( s )

                % Store all the data in the zero matrix
                storageData(k,:) = [...
                    myMuscle.getNormalizedFiberLength(s) ...  % Normalized Fibre Length  
                    myMuscle.getActiveFiberForce(s) ...       % active fiber force  
                    myMuscle.getPassiveFiberForce(s) ...      % passive fibre forces  
                    myMuscle.getTendonLength(s) ...           % tendon lengths  
                    myMuscle.getTendonForce(s) ...            % tendon force's  
                    ];         
                
   end

   % store the data in the output struct
   muscleCoordinates.(musclesList{i}).motion.data = storageData;
end

%% print/plot the force length relationships 


[pathStr,name,ext] = fileparts(path2motion);

for i = 1 : length(musclesList) 

    normalisedFiberlength = muscleCoordinates.(musclesList{i}).motion.data(:,1);
    
    if min(normalisedFiberlength) < 0.6 | max(normalisedFiberlength) > 1.3
        display(['Warning, ' musclesList{i} ' may have issues, check output plots']);
    end

    referenceData = sortrows(muscleCoordinates.(musclesList{i}).forceLength,1);
    p = polyfit(referenceData(:,1),referenceData(:,2),4); 
    referencCurve = polyval(p,referenceData(:,1));
    
    motionData = sortrows(muscleCoordinates.(musclesList{i}).motion.data,1);
    p = polyfit(motionData(:,1),motionData(:,2),4); 
    motionCurve = polyval(p,motionData(:,1));
    
    
    f = figure;
    
    hold on
    h = plot(referenceData(:,1), referencCurve,'b' );
    q = plot(motionData(:,1), motionCurve, 'r' );
            
    xlabel('Normalised fiber length');
    ylabel('Active fiber force');
    title([musclesList{i} ' force-length relationship']);
    legend('Total force-length curve', 'Movement force-length curve', 'Location', 'NorthWest');
   
    set(h, 'Linewidth', 4) ;
    set(q, 'Linewidth', 7);
    
    
    if ~exist(fullfile(pathStr,[name '_muscleCurves']),'file' )    
           mkdir(fullfile(pathStr,[name '_muscleCurves']));
    end
    
    filename = fullfile(pathStr,[name '_muscleCurves'],musclesList{i});
    
    print(filename,'-dpng');
    
    close(f)
end



data = [];
for i = 1 : length(musclesList) 

referenceFiberlength = muscleCoordinates.(musclesList{i}).forceLength(:,1);
normalisedFiberlength = muscleCoordinates.(musclesList{i}).motion.data(:,1);


data = [data [[min(referenceFiberlength);max(referenceFiberlength)]; [min(normalisedFiberlength); max(normalisedFiberlength)]]];



% referenceLengths(i,:) = [min(referenceFiberlength) max(referenceFiberlength)];
% motionLengths(i,:) = [min(normalisedFiberlength) max(normalisedFiberlength)];


end


%FLOATING CLUSTERED BAR CHART: 
bar2(data, 'XLABEL', musclesList') 
legend({'A','B'},'SPACING', 0.1, 'XLABEL', musclesList') 



























