function table_rotated = osimRotateTableData(table, axisString, value)
% Utility function for for rotating Vec3 TableData elements
% about an axisString by value (in degrees). 
% table         Vec3 dataTable
% axisString    string 'x', 'y', or 'z'
% value         double, in degrees
%  
% Example: rotate all (Vec3) elements in t by 90 degrees about the x axisString.                                     
% t_r = rotateTableData(t, 'x', -90) 

% Author: James Dunne

%% import java libraries
import org.opensim.modeling.*

%% set up the transform
if strcmp(axisString, 'x')
    axis = CoordinateAxis(0);
elseif strcmp(axisString, 'y')
    axis = CoordinateAxis(1);
elseif strcmp(axisString, 'z')
    axis = CoordinateAxis(2);
else
    error(['Axis must be either x,y or z'])
end

%% instantiate a transform object
R = Rotation( deg2rad(value) , axis ) ;

%% rotate the elements in each row
% clone the table.
table_rotated = table.clone();

for iRow = 0 : table_rotated.getNumRows() - 1
    % get a row from the table
    rowVec = table_rotated.getRowAtIndex(iRow);
    % rotate each Vec3 element of row vector, rowVec, at once
    rowVec_rotated = R.multiply(rowVec);
    % overwrite row with rotated row
    table_rotated.setRowAtIndex(iRow,rowVec_rotated)
end

end







