function CalcJacob
%ASSEMPDE Summary of this function goes here
global gd
l_emptysym = sym;
l_emptysym = l_emptysym([]);
%  Declare GC sym
eval(['syms ' gd.FE.GCSSTR ' real']);
%  Declare PDE variable sym
%  Variables of Points list NP*NPDE
l_nep = gd.FE.NP;
l_nvar = gd.PDES.NV;
for l_ic = 1:gd.FE.DIM
  l_pdcstr = genlist([char(gd.FE.DCS(l_ic)) '_'],l_nep);
  eval(['syms ' l_pdcstr ' real']);
end
for l_iv = 1:l_nvar
  l_var = gd.PDES.VLIST{l_iv};
  l_vop = genlist(l_var,l_nep);
  gd.PDES.VOPSTR{l_iv} = l_vop;
  % Declare VOP sym
  eval(['syms ' l_vop ' real']);
  l_vopsym = eval(['[' l_vop '];']);
  eval([l_var 'A = l_vopsym;']);
  eval([l_var '=dot(gd.FE.SFSym,l_vopsym);']);
  % enlist vop sym
  l_voplist(l_iv,:) = l_vopsym(:);
end
gd.PDES.IV = [1:l_nvar]'*ones(1,l_nep);
gd.PDES.IP = ones(l_nvar,1)*[1:l_nep];

eval(['syms ' gd.PDES.CSTR ' eVol eLen real']);
l_njac = l_nvar*l_nep;
% 体积分
l_jacs = l_emptysym;
l_fv = l_emptysym;

SFA = gd.FE.SFSym;
for l_iv = 1:l_nvar
  l_vexp = gd.PDES.PDEVLIST{ l_iv };
  l_vexp = strrep(l_vexp,'nVec','gd.FE.nVec');
  if  ~gd.FE.GAUSSINT
  l_vexp = strrep(gd.FE.INTVSTR,'VEXP',l_vexp);
  end
  for l_ip = 1:l_nep
    SF = gd.FE.SFSym(l_ip);
    if gd.FE.GAUSSINT
      %l_intstr = strrep(l_vexp,'SF',['(' gd.FE.SFStr{l_ip} ')']);
      l_v = sym('0');      digits(10);
      for l_iqp = 1:gd.FE.NQP
        eval(['[' gd.FE.GCSSTR ']=arrayout(gd.FE.QPGC(:,l_iqp));']);
        l_intstr = char(eval(l_vexp));
        l_v = l_v + gd.FE.QPW(l_iqp)*eval(l_intstr);
      end
      l_v = simple(l_v);
    else
      eval(l_vexp);
    end
    l_jac = simple(jacobian(l_v,l_voplist));
    l_ij = l_nvar*l_ip - l_nvar + l_iv;
    l_jacs(l_ij,1:l_njac) = l_jac;
    l_fv(l_ij,1) = l_v;
  end
end
gd.PDES.JACV = l_jacs;
gd.PDES.JACVSTR = Sym2Str(l_jacs);
gd.PDES.FVSTR = Sym2Str(l_fv);

% 边界积分
l_bdl = gd.PDES.BDCLIST(:);
l_bdt = gd.PDES.BDTLIST(:);
% 第二类边界条件
ii = find(l_bdt==0);
l_bdlist = DelSame(l_bdl(ii),1);
l_nbd = size(l_bdlist(:),1);
gd.PDES.BNSTR = l_bdlist;
l_t = 0;
l_jacs = l_emptysym;
l_fv = l_emptysym;
for l_ibd = 1:l_nbd
  l_bexp = l_bdlist{l_ibd};
  l_bexp = strrep(l_bexp,'nVec','gd.FE.nVec');
  for l_ip = 1:l_nep
    l_intstr = strrep(l_bexp,'SF',['(' gd.FE.SFStr{l_ip} ')']);
    l_intstr = char(eval(l_intstr));
    l_intstr = strrep(gd.FE.INTBSTR,'BEXP',l_intstr);
    eval(l_intstr);
    eval(['syms ' gd.FE.GCSSTR ' real;']);
    l_jac = simple(jacobian(l_b,l_voplist));
    l_t = l_t + 1;
    l_fv(l_t) = l_b;
    l_jacs(l_t,1:l_njac) = l_jac;
  end
end
gd.PDES.JACBNSTR = Sym2Str(l_jacs);
gd.PDES.FBNSTR = Sym2Str(l_fv);

% 第一类边界条件 diri
ii = find(l_bdt);
l_bdlist = DelSame(l_bdl(ii),1);
l_nbd = size(l_bdlist(:),1);

% 用边界中点值计算边界条件
l_vsym = (l_voplist(:,1)+l_voplist(:,2))/2;
% 用边界第一个节点计算边界条件
l_vsym = l_voplist(:,1);
eval(['[' gd.PDES.VSTR ']=arrayout(l_vsym);']);
gd.PDES.BDSTR = l_bdlist;
l_t = 0;
l_jacs = l_emptysym;
l_fv = l_emptysym;
for l_ibd = 1:l_nbd
  l_bexp = l_bdlist{l_ibd};
  l_bexp = strrep(l_bexp,'nVec','gd.FE.nVec');
  l_b = eval(l_bexp);
  l_t = l_t + 1;
  % l_jac = simple(jacobian(l_b,l_voplist));
  % l_jacs(l_t,1:l_njac) = l_jac;
  l_jac = simple(jacobian(l_b,l_voplist(:,1)));
  l_jacs(l_t,1:l_nvar) = l_jac;
  l_fv(l_t) = l_b;
end
gd.PDES.JACBDSTR = Sym2Str(l_jacs);
gd.PDES.FBDSTR = Sym2Str(l_fv);

function l_str = replaceReversedSym(l_str)

% \partial f Ω 
function l_f = dfdidc(l_f,l_idc)
global gd
l_dfdgc = jacobian(l_f,gd.FE.GCS)';
l_f = dot(l_dfdgc,gd.FE.D2GA(:,l_idc));

function l_f = der(l_f,varargin)
global gd
l_nvar = (nargin - 1)/2;
for l_ivar = 1:l_nvar
  l_var = varargin{2*l_ivar-1};
  l_idc = str2num(l_var(2:end));
  if l_var(1)~='d' || l_idc<1 || l_idc>gd.FE.DIM
    error('Wrong DCS name')
  end
  l_n = varargin{2*l_ivar};
  for l_ider = 1:l_n
    l_dfdgc = jacobian(l_f,gd.FE.GCS)';
    l_f = dot(l_dfdgc,gd.FE.D2GA(:,l_idc));
  end
end

%
function l_d = grad(l_f)
global gd
for l_idc = 1:gd.FE.DIM
  l_d(l_idc) = dfdidc(l_f,l_idc);
end

function l_d = div(l_f)
global gd
l_d = sym('0');
for l_idc = 1:gd.FE.DIM
  l_d = l_d + dfdidc(l_f(l_idc),l_idc);
end

function l_d = nabla(l_f)
l_d = grad(l_f);

function l_d = nabladot(l_f)
l_d = div(l_f);

function l_d = div1(l_f)
global gd
l_d = sym('0');
for l_idc = 1:gd.FE.DIM
  l_d = l_d + dfdidc(l_f,l_idc);
end

function l_d = delta(l_f)
l_d = div(grad(l_f));