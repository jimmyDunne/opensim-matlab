
modelPath = 'E:\repo\loadedWalkingExperiment\data\LowerBody_scaled_registered.osim' ;


import org.opensim.modeling.*      % Import OpenSim Libraries

%From Handsfields 2014 figure 5a and from Apoorva's muscle properties
%spreadsheet

% Define the specific tension of muscle in N/cm^2(Arnold) 
specificTension = 61
subjectMass = 85
subjectHeight = 1.82


myModel = Model(modelPath)
muscleSet = myModel.getMuscles()

% The numbers below come from Apoorva's spreadsheet.


% the muscle volume of the generic 2392 model
modelVolume   = HansFieldMuscleVolumeRegression(75.337, 1.7)
subjectVolume = muscleVolumeRegression(subjectMass, subjectHeight)

volumeScalingFactor = subjectVolume / modelVolume
print('Scaling all muscle forces by %f.' % scale_factor)

for im in range(muscleSet.getSize()):
muscle = muscleSet.get(im)
generic_force = muscle.getMaxIsometricForce()
scaled_force = generic_force * scale_factor
muscle.setMaxIsometricForce(scaled_force)
h.close()
myModel.printToXML(self.model_output)



muscleVolume = 107.536
fiberLength = 10.31
pennationAngle = 6.1
p = 30







def _scale_muscle_forces_individual_heightmass(self):
% TODO split up add_mag, glut_m, peroneals, ext_hal/dig
linear_fits = {
    'glut_max':           {'b1': 6.01,   'b2': 105.0},
    'add_mag':            {'b1': 3.64,   'b2': 109.0},
    'glut_med':           {'b1': 2.17,   'b2': 54.8},
    'psoas':              {'b1': 2.43,   'b2': -26.3},
    'iliacus':            {'b1': 1.11,   'b2': 39.4},
    'sar':                {'b1': 1.19,   'b2': 15.9},
    'add_long':           {'b1': 1.19,   'b2': 14.3},
    'glut_min':           {'b1': 0.576,  'b2': 33.1},
    'add_brev':           {'b1': 0.622,  'b2': 27.1},
    'grac':               {'b1': 0.580,  'b2': 32.1},
    'pect':               {'b1': 0.481,  'b2': 6.7},
    'tfl':                {'b1': 0.620,  'b2': -11.8},
    'obturator_externus': {'b1': 0.146,  'b2': 35.1}, % unused?
    'peri':               {'b1': 0.137,  'b2': 25.7},
    'quad_fem':           {'b1': 0.228,  'b2': 4.2},
    'obturator_internus': {'b1': 0.120,  'b2': 11.7}, % unused?
    'small_ext_rotators': {'b1': 0.0688, 'b2': 7.56}, % special.
    'vas_lat':            {'b1': 5.89,   'b2': 102.0},
    'vas_med':            {'b1': 3.03,   'b2': 57.6},
    'vas_int':            {'b1': 1.29,   'b2': 111.0},
    'rect_fem':           {'b1': 1.71,   'b2': 56.9},
    'semimem':            {'b1': 1.54,   'b2': 54.5},
    'bifemlh':            {'b1': 1.24,   'b2': 53.0},
    'semiten':            {'b1': 1.27,   'b2': 29.1},
    'bifemsh':            {'b1': 0.738,  'b2': 8.64},
    'popliteus':          {'b1': 0.133,  'b2': 6.84},
    'soleus':             {'b1': 2.57,   'b2': 120.0},
    'med_gas':            {'b1': 1.71,   'b2': 46.2},
    'lat_gas':            {'b1': 1.08,   'b2': 15.7},
    'tib_ant':            {'b1': 0.796,  'b2': 36.7},
    'per_brev':           {'b1': 0.956,  'b2': 12.5},
    'per_long':           {'b1': 0.956,  'b2': 12.5},
    'tib_post':           {'b1': 0.451,  'b2': 48.9},
    'ext_dig':            {'b1': 0.619,  'b2': 25.6},
    'ext_hal':            {'b1': 0.619,  'b2': 25.6},
    'flex_hal':           {'b1': 0.622,  'b2': 1.85},
    'flex_dig':           {'b1': 0.130,  'b2': 13.9},
    }

def muscle_volume_regression(muscle_name):
if muscle_name.endswith('_r') or muscle_name.endswith('_l'):
    trimmed_name = ''.join(
            [i for i in muscle_name[:-2] if not i.isdigit()])
else:
    raise Exception('Muscle name should end with _r or _l.')
b = linear_fits[trimmed_name]
return b['b1'] * subjectMass * subjectHeight + b['b2']

print('Muscle force scaling: individual regressions by height*mass.')
import opensim
h = open_file('../loadedwalking.h5')
myModel = opensim.Model(self.model_output)
muscleSet = myModel.getMuscles()
specific_tension = 30 % N/cm^2; used by Apoorva.
subjectMass = h.get_node_attr('/exp/%s' % self.subj_str, 'mass')
subjectHeight = h.get_node_attr('/exp/%s' % self.subj_str, 'height')
for im in range(muscleSet.getSize()):
muscle = muscleSet.get(im)
muscle_name = muscle.getName()
muscle_volume = muscle_volume_regression(muscle_name)
% Convert length from meters to centimeters.
optimal_fiber_length = muscle.getOptimalFiberLength() * 100
new_force = specific_tension / optimal_fiber_length * muscle_volume
generic_force = muscle.getMaxIsometricForce()
scale_factor = new_force / generic_force
print('Scaling %s force by %f.' % (muscle_name, scale_factor))
muscle.setMaxIsometricForce(new_force)
h.close()
myModel.printToXML(self.model_output)

def scale_muscle_forces(self):
self._scale_muscle_forces_total_muscle_volume()
%self._scale_muscle_forces_individual_heightmass()

def check_tasks(self):
%Lists tasks that are <apply>'d for markers that either
don't exist in the myModel or are not in the TRC file.
Also lists tasks for which there is data, but that are either not in
the myModel or do not have an IK task.
%
from opensim import ScaleTool, Model, MarkerSet
from perimysium.dataman import TRCFile

scale = ScaleTool(self.setup_fpath)
tasks = scale.getMarkerPlacer().getIKTaskSet()
trc = TRCFile(self.trc_fpath)
trc_names = trc.marker_names
myModel = Model(self.model_input)
if self.load.startswith('noload'):
markerset = MarkerSet(self.marker_input_fpath)
else:
markerset = myModel.getMarkerSet()

if self.load.startswith('loaded'):
% Ensure that all tasks related to unfixed markers are not Apply'd.
unfix_loaded = []
for marker_name in markers_moved_when_loaded:
    if (tasks.contains(marker_name) and
            tasks.get(marker_name).getApply()):
        unfix_loaded.append(marker_name)
if unfix_loaded != [] and not self.allow_using_moved_markers:
    raise Exception('There are IK tasks for markers we KNOW '
            'have moved, and these tasks are applied: {}'.format(
                unfix_loaded))

del marker_name
























