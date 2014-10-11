function [l_varlist,l_varval] = GetVarval(l_p,l_e,l_t,l_u0)
%GETVARVAL Summary of this function goes here
%  Detailed explanation goes here
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
