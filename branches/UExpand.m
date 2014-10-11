function uu=UExpand(p,u,dim);
% UExpand Expand solution u to node points
%
%       U=PDEUXPD(P,U) expands a scalar valued U to node points defined by
%       point matrix P.
%       U can be a scalar or a string describing U as a function of DCS.
%
%       U=PDEUXPD(P,U,N) expands U to node points for a system with
%       dimension N (default is 1).
%
%       PDEUXPD returns the expanded U as a column vector of length
%       N * size(P,2).
global gd
if nargin<3,
  dim=1;
end
np=size(p,2);
if isstr(u),
  %dclist = str2list(gd.FE.DCSList,' ');
  eval(['[' gd.FE.DCSList ']=arrayout(p);'
  u=eval(u,'error(''unable to evaluate u'')');
end
[n,m]=size(u);
if m==np,
  u=u';
end
u=u(:);
n=length(u);
if n==1,
  n=dim*np;
  uu=u*ones(n,1);
else
  uu=u;
end

if rem(n,np)~=0,
  error('u must be a scalar or a vector of N*size(p,2)')
end

