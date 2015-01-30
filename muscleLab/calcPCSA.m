function [pcsa, muscleForce] = calcPCSA(muscleVolume, fiberLength, pennationAngle, p)

pcsa = ( muscleVolume* cos(deg2rad(pennationAngle)) ) / (fiberLength);
muscleForce = pcsa*p;

end                               