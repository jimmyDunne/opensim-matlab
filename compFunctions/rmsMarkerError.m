function [MarkerError, rmsError] = rmsMarkerError(trcfilepath, ikMarkerFilePath)


expData = getTrcData(trcfilepath, 4,7);

ikMarkerData = getStoData(ikMarkerFilePath);


markerNames = fieldnames(expData.markers);

nFrames = length(ikMarkerData.('time'));

modelMarkerNames = fieldnames(ikMarkerData);

for i = 1: length(markerNames) 

    if isempty(find(cellfun(@isempty,strfind(modelMarkerNames,markerNames{i}))==0))
       continue
    end
        
    for u = 1: nFrames
    MarkerError.(markerNames{i})(u,:) = norm(expData.markers.(markerNames{i})(u,:) - ...
                                  [ikMarkerData.([ markerNames{i} '_tx' ])(u,:)...
                                    ikMarkerData.([ markerNames{i} '_ty' ])(u,:)...
                                    ikMarkerData.([ markerNames{i} '_tz' ])(u,:)]*1000);

    end

    rmsError.(markerNames{i}) =  sqrt( mean( MarkerError.(markerNames{i}).^2 )  );
        
end
