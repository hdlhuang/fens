function list = str2list( str,seperator,n )
% str2list Summary of this function goes here
%   Convert string seperated by seperator to string cell array 
str = [str seperator];
i = strfind(str,seperator);
if nargin < 3
  n = size(i,2);
end
s = 1;
l = length(seperator);
t = 1;
list = {};
for j = 1:n
  if s < i(j)
    list{t} = str(s:i(j)-1);
    t = t + 1;
  end
  s = i(j) + l;
end