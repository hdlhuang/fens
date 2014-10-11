function MESH = CreateMesh( dim, nep )
%CREATEMESH Summary of this function goes here
%  Detailed explanation goes here
if nargin < 1
    dim = 2;
end
if nargin < 2
    nep = 6;
end
gd1 = gdpoly([
    -1 -1;
     1 -1;
     1  0;
    -1  0]);
gd2 = gdcircle([0,0],1);
MESH.gd = expandgd(gd2,gd1);
MESH.dl=decsg(MESH.gd);
wgeom(MESH.dl,'meshgeom');
[MESH.p,MESH.e,MESH.t]=initmesh('meshgeom','Hmax',0.4);

MESH = AdjustMesh(MESH,dim,nep);
% myplot(MESH.p, MESH.e, MESH.t,'shownodelbl','on','showtrilbl','on');

function col = gdpoly(xy)
x=xy(:,1);
y=xy(:,2);
n = size(x,1);
col = [2;n;x;y];

% center radius
function col = gdcircle(c,r)
col = [1;c(:);r];

% center a,b rotational angle 
function col = gdellipse(c,a,angle)
col = [4;c(:);a(:);angle];

function gd = expandgd(gd,gd1)
sz  = size(gd,1);
sz1 = size(gd1,1);
if sz < sz1
    gd(end+1:sz1,:) = 0;
elseif sz > sz1
    gd1(end+1:sz,:) = 0;
end
gd = [gd gd1];



