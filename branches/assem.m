function [l_KK,l_FF,l_HH,l_RR]=assem(l_u0)
%ASSEM Summary of this function goes here
%  Detailed explanation goes here
global gd
l_point = gd.MESH.p;
l_edge = gd.MESH.e;
l_tri = gd.MESH.t;
l_np = size(l_point,2);
l_nt = size(l_tri,2);

l_nvar = gd.PDES.NV;
l_nep = gd.FE.NP;

if size(l_u0(:),1)==1
  l_u0 = zeros(l_nvar,l_np);
end
[l_varlist,l_varval] = GetVarval(l_point,l_edge,l_tri,l_u0);
eval(['[' l_varlist ']=arrayout(l_varval);']);
l_l_eVolstr = Op2ArrayOp(char(gd.FE.eVol));
eVol = eval(l_l_eVolstr);
% eval(['[' gd.PDES.CSTR ']=GetPDECoel_FF(l_u0);']);

l_njac = l_nvar*l_nep;
l_ksize = l_nvar*l_np;
l_KK = sparse(l_ksize,l_ksize);
l_FF = sparse(l_ksize,1);
l_HH = l_KK;
l_RR = l_FF;
l_va = [1:l_nvar]'*ones(1,l_nep);
l_pa = ones(l_nvar,1)*[1:l_nep];
% 体积分项
for l_i = 1:l_njac
  l_iv = l_va(l_i);
  l_ip = l_pa(l_i);
  l_fvstr = gd.PDES.FVSTR{l_i};
  l_row = (l_tri(l_ip,:)-1)*l_nvar + l_iv;
  l_FF = l_FF + sparse(l_row,1,2*eval(l_fvstr).*eVol,l_ksize,1);
  for l_j = 1:l_njac
    l_jac = gd.PDES.JACVSTR{l_i,l_j};
    if length(l_jac) ~= 0
      l_jv = l_va(l_j);
      l_jp = l_pa(l_j);
      l_col = (l_tri(l_jp,:)-1)*l_nvar + l_jv;
      l_KK = l_KK + sparse(l_row,l_col,2*eval(l_jac).*eVol,l_ksize,l_ksize);
    end
  end
end

% 边界积分项
l_ie = pdesde(l_edge);
% Get rid of unwal_nted l_edges
l_edge = l_edge(:,l_ie);
l_ne=size(l_edge,2); % Number of l_edges

% l_edge related unit vectors
l_ls=find(l_edge(6,:)==0 & l_edge(7,:)>0); % External region to the left
l_rs=find(l_edge(7,:)==0 & l_edge(6,:)>0); % External region to the right
% l_tri l_is couter clockwise,so set all l_edge external region to the right
l_edge([1 2 6 7],l_ls) = l_edge([2 1 7 6],l_ls);
l_edgep = zeros(1,l_np);

% all l_edge l_is couter clockwise
% l_edgep(l_edge([1 2],:)) = 1;
l_edgep(l_edge(1,:)) = 1;
l_trsd = [1 2 3;2 3 1;3 1 2];
tmp = sparse(l_tri(l_trsd(1,:),:),l_tri(l_trsd(2,:),:), ones(3,1)*[1:l_nt], l_np,l_np);
itr = full(tmp(l_edge(1,:)+l_edge(2,:)*l_np - l_np));
l_etr = l_tri(1:l_nep,itr);
% tmp = sparse(l_tri(l_trsd(1,:),:),l_tri(l_trsd(2,:),:),[1:3]'*ones(1,l_nt), l_np,l_np);
% isd = full(tmp(l_edge(1,:)+l_edge(2,:)*l_np - l_np));
% 设置每条边界为所在三角元的第一条边
if l_nep == 6,  l_trsd = [l_trsd;l_trsd+3]; end
l_is = find(~any( l_etr([2 3],:)-l_edge([1 2],:) ));
l_etr(:,l_is) = l_etr(l_trsd(:,2),l_is);
l_is = find(~any( l_etr([3 1],:)-l_edge([1 2],:) ));
l_etr(:,l_is) = l_etr(l_trsd(:,3),l_is);
%l_is = find(isd==3);

% 设置变量
[l_varlist,l_varval] = GetVarval(l_point,l_edge,l_etr,l_u0);
eval(['[' l_varlist ']=arrayout(l_varval);']);
eVol = eVol(itr);
eLenstr = Op2ArrayOp(char(gd.FE.eLen));
eLen = eval(eLenstr);
l_varlist = [l_varlist ' eVol eLen'];
l_varval =[l_varval;eVol;eLen];
% nVec
for ic = 1:gd.FE.DIM
  l_varlist = [l_varlist ' ' char(gd.FE.nVec(ic))];
  l_val = eval(gd.FE.nVecStr{ic});
  l_varval = [l_varval; l_val];
end

l_nbdj = size(gd.PDES.JACBDSTR,2);
l_nbnj = size(gd.PDES.JACBNSTR,2);
l_bdc = gd.PDES.BDCLIST;
l_bdt = gd.PDES.BDTLIST;
l_nbs = size(l_bdc,2);
for l_ibs = 1:l_nbs
  l_ie = find(l_edge(5,:)==l_ibs);
  eval(['[' l_varlist ']=arrayout(l_varval(:,l_ie));']);
  %l_edgep = DelSame(l_edge(1:2,l_ie),0);
  l_ep1row = (l_edge(1,l_ie)-1)*l_nvar;
  l_ep2row = (l_edge(2,l_ie)-1)*l_nvar;
  for l_iv = 1:l_nvar
    if l_bdt(l_iv,l_ibs) % 第一类边界条件
      l_bdcpos = strmatch(l_bdc{l_iv,l_ibs},gd.PDES.BDSTR,'exact');
      l_fvstr = gd.PDES.FBDSTR{l_bdcpos};
      if length(l_fvstr) ~= 0
        l_val = eval(l_fvstr);
        l_RR = l_RR + sparse(l_ep1row+l_iv,1,l_val,l_ksize,1);
        l_RR = l_RR + sparse(l_ep2row+l_iv,1,l_val,l_ksize,1);
      end
      l_jacstr = gd.PDES.JACBDSTR(l_bdcpos,:);
      for l_j=1:l_nbdj
        l_jac = l_jacstr{l_j};
        if length(l_jac) ~= 0
          l_jv = l_va(l_j);
          l_jp = l_pa(l_j);
          l_col = (l_etr(l_jp,l_ie)-1)*l_nvar + l_jv;
          l_val = eval(l_jac);
          l_HH = l_HH + sparse(l_ep1row+l_iv,l_col,l_val,l_ksize,l_ksize);
          l_HH = l_HH + sparse(l_ep2row+l_iv,l_col,l_val,l_ksize,l_ksize);
        end
      end
    else
      l_bdcpos = strmatch(l_bdc{l_iv,l_ibs},gd.PDES.BNSTR,'exact');
      l_bdcpos = l_bdcpos*l_nep - l_nep + [1:l_nep];
      l_fbnstr = gd.PDES.FBNSTR(l_bdcpos);
      l_jacstr = gd.PDES.JACBNSTR(l_bdcpos,:);
      for l_ip = 1:l_nep
        l_row = (l_etr(l_ip,l_ie)-1)*l_nvar + l_iv;
        l_fvstr = l_fbnstr{l_ip};
        if length(l_fvstr) ~= 0
          l_FF = l_FF + sparse(l_row,1,eval(l_fvstr).*eLen,l_ksize,1);
        end
        for l_j = 1:l_nbnj
          l_jac = l_jacstr{l_j,l_ip};
          if length(l_jac) ~= 0
            l_jv = l_iv(l_j);
            l_jp = l_ip(l_j);
            l_col = (l_etr(l_jp,l_ie)-1)*l_nvar + l_jv;
            l_KK = l_KK + sparse(l_row,l_col,eval(l_jac).*eLen,l_ksize,l_ksize);
          end
        end %for l_j
      end %for l_ip
    end %l_bdt(l_iv)
  end %for l_iv
end %for l_ibs

function [l_varlist,l_varval] = GetVarval(l_p,l_e,l_t,l_u0)
global gd;
l_varlist = '';
l_varval = [];
l_nep = gd.FE.NP;
l_nvar= gd.PDES.NV;
l_nt = size(l_t,2);
l_val = zeros(l_nep,l_nt);
for l_iv = 1:l_nvar
  l_val(:) = l_u0((l_t(1:l_nep,:)-1)*l_nvar+l_iv);
  l_varlist = [l_varlist ' ' gd.PDES.VOPSTR{l_iv}];
  l_varval = [l_varval;l_val];
end
for l_ic = 1:gd.FE.DIM
  for l_ip = 1:l_nep
    pdcstr = [char(gd.FE.DCS(l_ic)) '_' num2str(l_ip)];
    l_varlist = [l_varlist ' ' pdcstr];
    eval('l_val=l_p(l_ic,l_t(l_ip,:));');
    l_varval = [l_varval;l_val];
  end
end
for l_ic = 1:gd.PDES.NC
  l_coeff = gd.PDES.CNAME{l_ic};
  l_vstr = gd.PDES.CVLIST{l_ic};
  eval([ l_coeff '=' l_vstr ';l_val=' l_coeff ';']);
  if size(l_val(:),1) ~= l_nt
    l_val = l_val*ones(1,l_nt);
  end
  l_varval = [l_varval;l_val];
end
l_varlist = [l_varlist ' ' gd.PDES.CSTR];
