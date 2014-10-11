function varargout = arrayout( array )
%ARRAYOUT Summary of this function goes here
%  Detailed explanation goes here
n = size(array,1);
for i=1:n
  varargout{i} = array(i,:);
end