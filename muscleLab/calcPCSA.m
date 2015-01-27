function [pcsa, muscleForce] = calcPCSA(muscleVolume, fiberLength,pennationAngle, p)

pcsa = ( muscleVolume*cos(pennationAngle) ) / (fiberLength);

muscleForce = pcsa*p;



end