function PDES = PDECreate(PDES)
%PDECREATE Summary of this function goes here
%  Detailed explanation goes here

%  Local variable have prefix 'l_'
%  Reversed name gd nvec g{i} d{i} g{i_j} d{i_j} i=1 2.. j=1 2..
%  Do not use these names in PDES
if nargin==0
  % variable symbols seperated by space
  PDES.VSTR = 'V Nu';
  % coeffecient symbols seperated by space
  PDES.VLIST = {'V','Nu'};
  PDES.CNAME = {'a','b'};
  PDES.CLIST = {'a=1;','b=2;'};
  % pdes seperated by ;
  PDES.PDEVLIST = {
    'dot(a*grad(V),grad(SF))+(b*V+2)*SF',
    '(Nu+V)*SF'};
  PDES.PDEBLIST = {
    'dot(nvec,a*grad(V))*SF',
    ''};
end
PDES = PDEAddin(PDES);

function PDES = PDEAddin(PDES)
PDES.NV = size(PDES.VLIST(:),1);
PDES.NC = size(PDES.CLIST(:),1);
PDES.NPDE = PDES.NV;

PDES.VSTR = list2str(PDES.VLIST,' ');
PDES.CSTR = list2str(PDES.CNAME,' ');
