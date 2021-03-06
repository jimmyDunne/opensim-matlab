%
% Author: James Dunne






tic
%% Load libraries
import org.opensim.modeling.*

%% get path to file
filepath = 'walking2.c3d';
[path, file, ext] = fileparts(filepath);
if isempty(exist('walking2.c3d', 'file'))
   error('cannot find test file (walking2.c3d) at walking2.c3d');
end

%% Instantiate the file readers
trc = TRCFileAdapter();
sto = STOFileAdapter();

%% Test script for utility function
osimC3Dconverter('filepath', filepath);

%% Test if trc and mot file were printed.
assert( exist(fullfile(path,[file '.trc']), 'file') == 2, 'TRC was not printed ')
assert( exist(fullfile(path,[file '.mot']), 'file') == 2, 'TRC was not printed ')

%% Test rotations
% test if rotations about X, Y, and Z maintain the correct
% components. ie if rotatiing about X, X values remain the same.

%% Get the unrotated reference values
mkr = trc.read(fullfile(path,[file '.trc']));
ana = sto.read(fullfile(path,[file '.mot']));

mkr_Xvalue_ref = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(0);
mkr_Yvalue_ref = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(1);
mkr_Zvalue_ref = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(2);

ana_Xvalue_ref = ana.getDependentColumnAtIndex(0).getElt(238,0);
ana_Yvalue_ref = ana.getDependentColumnAtIndex(1).getElt(238,0);
ana_Zvalue_ref = ana.getDependentColumnAtIndex(2).getElt(238,0);

%% Rotate about X
osimC3Dconverter('filepath', filepath, 'value', -90, 'axis', 'x');
mkr = trc.read(fullfile(path,[file '.trc']));
ana = sto.read(fullfile(path,[file '.mot']));

% Set the new marker and force values
mkr_Xvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(0);
mkr_Yvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(1);
mkr_Zvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(2);
ana_Xvalue = ana.getDependentColumnAtIndex(0).getElt(238,0);
ana_Yvalue = ana.getDependentColumnAtIndex(1).getElt(238,0);
ana_Zvalue = ana.getDependentColumnAtIndex(2).getElt(238,0);
% Assess if the rotation is correct
assert(mkr_Xvalue_ref ==  mkr_Xvalue, 'X axis marker rotation is incorrect ')
assert(mkr_Yvalue_ref ~=  mkr_Yvalue, 'Y axis marker rotation is incorrect ')
assert(mkr_Zvalue_ref ~=  mkr_Zvalue, 'Z axis marker rotation is incorrect ')
assert(abs(round(mkr_Zvalue_ref)) ==  abs(round(mkr_Yvalue)), 'Y axis marker rotation is incorrect')
assert(abs(round(mkr_Yvalue_ref)) ==  abs(round(mkr_Zvalue)), 'Z axis marker rotation is incorrect')
assert(ana_Xvalue_ref ==  ana_Xvalue, 'X axis force rotation is incorrect ')
assert(ana_Yvalue_ref ~=  ana_Yvalue, 'Y axis force rotation is incorrect ')
assert(ana_Zvalue_ref ~=  ana_Zvalue, 'Z axis force rotation is incorrect ')
assert(abs(round(ana_Zvalue_ref)) ==  abs(round(ana_Yvalue)), 'Y axis force rotation is incorrect')
assert(abs(round(ana_Yvalue_ref)) ==  abs(round(ana_Zvalue)), 'Z axis force rotation is incorrect')

%% Rotate about Y
osimC3Dconverter('filepath', filepath, 'value', -90, 'axis', 'y');
mkr = trc.read(fullfile(path,[file '.trc']));
ana = sto().read(fullfile(path,[file '.mot']));
% Set the new marker and force values
mkr_Xvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(0);
mkr_Yvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(1);
mkr_Zvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(2);
ana_Xvalue = ana.getDependentColumnAtIndex(0).getElt(238,0);
ana_Yvalue = ana.getDependentColumnAtIndex(1).getElt(238,0);
ana_Zvalue = ana.getDependentColumnAtIndex(2).getElt(238,0);
% Assess if the rotation is correct
assert(mkr_Yvalue_ref ==  mkr_Yvalue, 'Y axis marker rotation is incorrect ')
assert(mkr_Xvalue_ref ~=  mkr_Xvalue, 'X axis marker rotation is incorrect ')
assert(mkr_Zvalue_ref ~=  mkr_Zvalue, 'Z axis marker rotation is incorrect ')
assert(abs(round(mkr_Zvalue_ref)) ==  abs(round(mkr_Xvalue)), 'X axis marker rotation is incorrect')
assert(abs(round(mkr_Xvalue_ref)) ==  abs(round(mkr_Zvalue)), 'Z axis marker rotation is incorrect')
assert(ana_Yvalue_ref ==  ana_Yvalue, 'Y axis force rotation is incorrect ')
assert(ana_Xvalue_ref ~=  ana_Xvalue, 'X axis force rotation is incorrect ')
assert(ana_Zvalue_ref ~=  ana_Zvalue, 'Z axis force rotation is incorrect ')
assert(abs(round(ana_Zvalue_ref)) ==  abs(round(ana_Xvalue)), 'X axis force rotation is incorrect')
assert(abs(round(ana_Xvalue_ref)) ==  abs(round(ana_Zvalue)), 'Z axis force rotation is incorrect')

%% Rotate about Z
osimC3Dconverter('filepath', filepath, 'value', -90, 'axis', 'z');
mkr = trc.read(fullfile(path,[file '.trc']));
ana = sto().read(fullfile(path,[file '.mot']));
% Set the new marker and force values
mkr_Xvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(0);
mkr_Yvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(1);
mkr_Zvalue = mkr.getDependentColumnAtIndex(0).getElt(238,0).get(2);
ana_Xvalue = ana.getDependentColumnAtIndex(0).getElt(238,0);
ana_Yvalue = ana.getDependentColumnAtIndex(1).getElt(238,0);
ana_Zvalue = ana.getDependentColumnAtIndex(2).getElt(238,0);
% Assess if the rotation is correct
assert(mkr_Zvalue_ref ==  mkr_Zvalue, 'Z axis marker rotation is incorrect ')
assert(mkr_Yvalue_ref ~=  mkr_Yvalue, 'Y axis marker rotation is incorrect ')
assert(mkr_Xvalue_ref ~=  mkr_Xvalue, 'X axis marker rotation is incorrect ')
assert(abs(round(mkr_Xvalue_ref)) ==  abs(round(mkr_Yvalue)), 'Y axis marker rotation is incorrect')
assert(abs(round(mkr_Yvalue_ref)) ==  abs(round(mkr_Xvalue)), 'X axis marker rotation is incorrect')
assert(ana_Zvalue_ref ==  ana_Zvalue, 'Z axis force rotation is incorrect ')
assert(ana_Yvalue_ref ~=  ana_Yvalue, 'Y axis force rotation is incorrect ')
assert(ana_Xvalue_ref ~=  ana_Xvalue, 'X axis force rotation is incorrect ')
assert(abs(round(ana_Xvalue_ref)) ==  abs(round(ana_Yvalue)), 'Y axis force rotation is incorrect')
assert(abs(round(ana_Yvalue_ref)) ==  abs(round(ana_Xvalue)), 'X axis force rotation is incorrect')

%% clean up files
delete(fullfile(path,[file '.trc']));
delete(fullfile(path,[file '.mot']));
toc