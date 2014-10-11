function array = DelSame( array,bchar )
%DELSAME Summary of this function goes here
%  Detailed explanation goes here
if ~all(size(array))
  return;
end
if nargin < 2
  bchar = 0;
end
array = sort(array(:));
if bchar
  ii = find(strcmp(array(1:end-1),array(2:end))==0);
else
  ii = find(diff(array,1));
end
array = array([1;ii(:)+1]);