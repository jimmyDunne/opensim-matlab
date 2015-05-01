function compareMotModelCoord(myModel, colheaders)

    import org.opensim.modeling.*      % Import OpenSim Libraries

    nCoords = length(colheaders);
    
    % check that all the given coordinates are in the model
    tempRef = [];
    for i = 1 : myModel.getCoordinateSet.getSize
        % get a list of all the coordinates in the model 
        tempRef = [tempRef {char( myModel.getCoordinateSet.get(i-1).getName )} ];
    end

    for i = 1 : nCoords 
       % compare each motion file colheader against the list of coordinates
       % from the model
       if isempty( strmatch( char(colheaders(i)) , tempRef ) ) 
            error(['coordinate ' char(colheaders(i)) ' isnt in the model'])  
       end
    end
end