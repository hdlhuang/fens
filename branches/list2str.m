function  str = list2str( list,seperator,n )
% list2str Summary of this function goes here
%   Convert string cell array to one string to 
%   one string seperated by seperator
if nargin < 2
    seperator = ' ';
end

if nargin < 3
    n = size(list(:),1);
end
str = '';
if ~n,return;end
str = list{1};
for i = 2:n
    str = [str seperator list{i}];
end