function [p,e,t] = AdjustMesh( p,e,t,dim,nep)
%ADJUSTMESH Summary of this function goes here
%  Detailed explanation goes here
it1 = t(1,:);
it2 = t(2,:);
it3 = t(3,:);
np = size(p,2);
nt = size(t,2);
if nep == 6
  sd = [it2 it3 it1;it3 it1 it2];
  sd = sort(sd,1);
  A = sparse(sd(1,:),sd(2,:),1,np,np);
  i = find(A);
  n = size(i(:),1);
  A(i) = [1:n] + np;
  it = A((sd(2,:)-1)*np + sd(1,:));
  it = reshape(it,nt,3)';
  t = [t(1:3,:);it;t(4:end,:)];
  sd1 = mod(i-1,np)+1;
  sd2 = (i - sd1)/np+1;
  p = [p,(p(:,sd1)+p(:,sd2))/2];
end