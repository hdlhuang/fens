function list = genlist( prefix, n, s, nd, options, suffix)
%GENLIST Summary of this function goes here
%  Detailed explanation goes here
if nargin < 2
  error('Too few arguments');
end
if nargin < 3
  s = 1;
end
if nargin < 4
  nd = '';
else
  nd = num2str(nd);
end
if nargin < 5
  options = '';
end
if nargin < 6
  suffix = '';
end
% None pad
formatstr = '%d';
% Pad with zeros.
if strfind(options,'Z')
    formatstr = ['%0' nd 'd'];
end
% Continuous
if strfind(options,'C')
    c = '';
else
    c = ' ';
end
e = s + n - 1;
% Generate string array?
if strfind(options,'A')
    for i = s:e
        list{i} = [prefix sprintf(formatstr,i) suffix];
    end
else
    list = '';
    for i = s:e
        list = [list c prefix sprintf(formatstr,i) suffix];
    end
end
