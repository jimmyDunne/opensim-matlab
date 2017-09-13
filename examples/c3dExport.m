c3dfile = '/Users/jimmy/repository/opensim-matlab/tests/shared/walking2.c3d';
%%
import org.opensim.modeling.*
%% Construct an opensimC3D object with input c3d path
c3d = opensimC3D(c3dfile);
%% Rotate the data 
c3d.rotateData('x',-90)
%% Write the tables to file 
c3d.write2file()
















