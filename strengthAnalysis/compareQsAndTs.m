function [satisfyQs satisfyTs] = compareQsAndTs(q, q_n, t, t_n);




%% Go through frames
[nFrames nQs] = size(q);

for i = 1 : nFrames
    
   coordDiff = sum(q(i,:) - q_n(i,:)) ;  
    % if any frame of the coordinates has a summed error of 2 then break
    if coordDiff > 2
        satisfyQs = 1;
        break
    end
end

%% Go through the torques

[nFrames nTs] = size(t);






end