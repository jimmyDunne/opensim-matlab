function [mPoint]= midpoint(v1,v2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

   vDiff = -diff([v1 v2]);

    mPoint = (vDiff)/2 + v2;
    

end

