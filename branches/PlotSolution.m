function PlotSolution(u,iv)
%PLOTSOLUTION Summary of this function goes here
%  Detailed explanation goes here
global gd;
if nargin < 1
  u = gd.SOL.U;
end
if nargin < 2
  iv = gd.ARGIN.PLOTIV;
end

nu = size(u(:),1);
nvar = gd.PDES.NV;
u = reshape(u,nvar,[]);
pdetool('plotu',u(iv,:));
