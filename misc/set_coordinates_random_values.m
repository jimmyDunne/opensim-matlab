clear all; close all; clc; format long;
import org.opensim.modeling.*


model = Model('Copy_of_Walker_Model.osim');
state = model.initSystem();

%%
sto = STOFileAdapter().readFile('fwd_results.sto');
time = 1.257;
row = sto.getNearestRowIndexForTime(time);
%%
clabels = sto.getColumnLabels();

for i = 0 : model.getCoordinateSet().getSize() - 1
    cname = model.getCoordinateSet().get(i).getName();
    for u = 0 : clabels.size - 1 
        if contains(char(clabels.get(u)),char(cname)) 
            if contains(char(clabels.get(u)),'value')
                if contains(char(model.getCoordinateSet().get(i).getMotionType()),'Rotational')
                    model.getCoordinateSet().get(i).set_default_value(deg2rad(sto.getDependentColumnAtIndex(u).get(row)));
                else
                    model.getCoordinateSet().get(i).set_default_value(sto.getDependentColumnAtIndex(u).get(row))
                end
            elseif contains(char(clabels.get(u)),'speed')
                if contains(char(model.getCoordinateSet().get(i).getMotionType()),'Rotational')
                    model.getCoordinateSet().get(i).set_default_speed_value(deg2rad(sto.getDependentColumnAtIndex(u).get(row)))
                else
                    model.getCoordinateSet().get(i).set_default_speed_value(sto.getDependentColumnAtIndex(u).get(row))
                end
            end
        end
    end
end
    
model.print('Copy_of_Walker_Model_posed.osim')