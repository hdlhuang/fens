function ut=intrp(p,t,un,gc)
%PDEINTRP Interpolate from node data to triangle midpoint data.
%
%       UT=INTRP(P,T,UN,gc) gives linearly interpolated values
%       at gc triangle points from the values at node points.
%
%       The geometry of the PDE problem is given by the triangle data P
%       and T. Details under INITMESH.
%
%       Let N be the dimension of the PDE system, and NP the number of
%       node points and NT the number of triangles. The components
%       of the node data are stored in UN either as N columns of
%       length NP or as an ordinary solution vector: The first NP values
%       of UN describe the first component, the following NP values
%       of UN describe the second component, and so on.  The components
%       of triangle data are stored in UT as N rows of length NT.
%
global gd

np=size(p,2);
nt=size(t,2);

if size(un,2)==1
  N=size(un,1)/np;
  un=reshape(un,np,N);
end
eval([ '[' gd.FE.GCSList '] = arrayout(gc(:));']);
sflist = list2str(gd.FE.SFStr,';');
sfvec = eval([ '[' sflist '];' ]);
nep = gd.FE.NP;
A = sparse(ones(nep,1)*(1:nt),t(1:nep,:),sfvec*ones(1,nt),nt,np);
ut=(A*un).';

