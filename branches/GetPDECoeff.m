function varargout = GetPDECoeff( u )
%GETPDECOEFF Summary of this function goes here
%  Detailed explanation goes here
global gd
for ic = 1:gd.PDES.NC
  varargout{ic} = eval(gd.PDES.CVLIST{ic});
end