clear all; close all; clc; format long;
import org.opensim.modeling.*

model = Model('Copy_of_Walker_Model_posed.osim');
state = model.initSystem();

%%

for i = 0 : model.getCoordinateSet().getSize() - 1
    coordinate = model.getCoordinateSet().get(i);
    if contains(char(coordinate.getName()), 'Pelvis')
       continue 
    end
    
    new_value = coordinate.getDefaultValue()    + (0.2*rand-0.2);
    new_Speed = coordinate.getDefaultSpeedValue + (0.2*rand-0.2);
    
    coordinate.set_default_value(new_value);
    coordinate.set_default_speed_value(new_Speed)
end
    
model.print('Copy_of_Walker_Model_posed_noise.osim')