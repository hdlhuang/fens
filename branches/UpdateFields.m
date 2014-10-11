function a = UpdateFields( a,b )
%UPDATEFIELDS Summary of this function goes here
%  Detailed explanation goes here
fieldstr = fields(b);
nf = size(fieldstr(:),1);
na = size(a(:),1);
for i = 1:na
  for f = 1:nf
    eval(['a(i).' fieldstr{f} '=b.' fieldstr{f} ';']);
  end
end