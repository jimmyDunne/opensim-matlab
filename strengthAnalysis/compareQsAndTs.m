function [satisfyQs satisfyTs] = compareQsAndTs(q, m, q_n, t, excludeList)

% original coordinates 
qData = q.data;
qHeaders = q.colheaders;
% new coordinates
q_nData = q_n.data;
q_nHeaders = q_n.colheaders;
% new torques
tData = t.data;
tHeaders = t.colheaders;
% joint moments from ID
mData = m.data;
mHeaders = m.colheaders;


satisfyQs = 1;
satisfyTs = 1;

%% Create time series objects from both data sources and synchronize


% coordinate data
oCoordTimeSeries = timeseries(qData(:,2:end),qData(:,1),'Name','coodsO');
nCoordTimeSeries = timeseries(q_nData(:,2:end),q_nData(:,1),'Name','coordsN');
[oTimeSeries nTimeSeries] = synchronize(nCoordTimeSeries,oCoordTimeSeries,'Uniform','Interval',0.0001);

qData = oTimeSeries.data;
q_nData = nTimeSeries.data;

% torque/moment data
momentTimeSeries = timeseries(mData(:,2:end),mData(:,1),'Name','Moments');
torqueTimeSeries = timeseries(tData(:,2:end),tData(:,1),'Name','Torques');
[tTimeSeries mTimeSeries] = synchronize(torqueTimeSeries,momentTimeSeries,'Uniform','Interval',0.0001);

tData = tTimeSeries.data;
mData = mTimeSeries.data;
mHeaders(1) =[];
tHeaders(1) =[];

%% Go through frames
[nFrames nQs] = size(qData);
for i = 1 : nFrames
    coordDiff = sum(qData(i,:) - q_nData(i,:)) ;  
    % if any frame of the coordinates has a summed error of 2 then break
    if coordDiff > 2
        satisfyQs = 0;
        break
    end
end


%% compare reserve torques to required joint moments.

for i = 1 : length(mHeaders)
    % get the index for '_'
    k = strfind(mHeaders{i}, '_');
    % get teh component of the header name
    if length(k) == 2
        s = mHeaders{i}(1:k(2)-1);
    elseif length(k) == 3
        s = mHeaders{i}(1:k(3)-1);
    end
    % find the reference to that name in the torque headers
    g = strmatch(s, tHeaders);
    tHeaders{g};
    if isempty(g)
       continue
    end
    
    % Compare to exclude list
    if strmatch(tHeaders{g}, char(excludeList))
       continue 
    end
    % get the joint moment and reserve toque for that coordinate
    jointMoment   = mData(:,i);
    reserveTorque = tData(:,g); 
    % determine the percentage of the jointtorque to required joint moment
    % for each frame
    %     torquePercentage = abs((reserveTorque./jointMoment)*100);
    %     if ~isempty( find(torquePercentage > 10) )
    %         if jointMoment( find(torquePercentage > 10) ) > abs(2)
    %             satisfyTs = 1;
    %             display(tHeaders{g})
    %             break
    %         end
    %     end
    
    if (max(abs(reserveTorque))/max(abs(jointMoment)) )*100 > 10
        satisfyTs = 0;
        display([ tHeaders{g} ' Max reserve is ' num2str(max(reserveTorque)) ' and the Max Joint Moment is ' num2str(max(jointMoment)) ])
        break
    end
    
end

end