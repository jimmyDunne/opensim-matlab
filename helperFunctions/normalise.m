function [ resampledData ] = normalise(data,pointsnormto)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% pointsnormto=101
 
 [m n]=size(data);   
 resampledData=zeros(pointsnormto,n);

 for ii=1:n
     yy=length(data(:,ii));
     x=[1:yy];
     xx=[1:(yy/pointsnormto):yy];
     data_down=spline(x,data(:,ii),xx);
         if length(data_down)<pointsnormto
                data_down(length(data_down):pointsnormto)=...
                    repmat(data_down(end),(pointsnormto-length(data_down)),1);
         end
     resampledData(:,ii)=data_down';
 end
 
 
 
end




