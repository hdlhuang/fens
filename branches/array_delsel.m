function array = array_delsel(array,sel)
%ARRAY_DELSEL Summary of this function goes here
%  Detailed explanation goes here
n = size(array(:),1);
ii = find(sel>=1&sel<=n);
sel = sel(ii);
ii = 1:n;
ii(sel) = 0;
jj = find(ii>0);
ii = ii(jj);
array = array(ii);
