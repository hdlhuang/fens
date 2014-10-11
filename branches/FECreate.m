function FE = FECreate(dim,np)
%  Number of points

FE.NP = np;

%  Number of Dimensions 维数
FE.DIM = dim;
FE.GAUSSINT = 1;
%------------------------------------
%  Independent coordinate number is DIM
%  广义坐标
%  Generalized coordinate symbols(GCS)
FE.GCSSTR = genlist('g',dim);
eval(['syms ' FE.GCSSTR ' real']);
FE.GCS = eval(['[' FE.GCSSTR ']']);
%  笛卡儿坐标
%  Descartes coordinate symbols(DCS)
FE.DCSSTR = genlist('d',dim);
eval(['syms ' FE.DCSSTR ' real']);
FE.DCS = eval(['[' FE.DCSSTR ']']);

for ic = 1:FE.DIM
  for ip = 1:FE.NP
    pdc = [char(FE.DCS(ic)) '_' num2str(ip)];
    pgc = [char(FE.GCS(ic)) '_' num2str(ip)];
    eval(['syms ' pdc ' ' pgc ' real']);
    FE.PDCS(ic,ip) = eval(pdc);
    FE.PGCS(ic,ip) = eval(pgc);
  end
end

nVeclist = genlist('nVec',dim);
eval(['syms ' nVeclist ' real']);
FE.nVec = eval(['[' nVeclist '];']);
%  二维平面三角元
if dim == 2,
  %------------------------------------
  %  三角元
  %         A
  %        / \
  %       / P \
  %      B-----C

  %  笛卡儿坐标 A=FE.PDCS(:,1);  B=FE.PDCS(:,2);  C=FE.PDCS(:,3);
  %  P = [d1;d2];
  %  定义广义坐标g1,g2满足
  %  P = g1*A + g2*B + (1-g1-g2)*C
  %  广义坐标 转变成 笛卡儿坐标
  %  P = G2DA*[g1;g2]+G2DB
  syms g1 g2 d1 d2 eVol real;
  A = FE.PDCS(:,1);
  B = FE.PDCS(:,2);
  C = FE.PDCS(:,3);
  D = A-B;
  FE.eVol = area2d(A,B,C);
  FE.eLen = sqrt(dot(D,D));
  FE.nVecStr = Sym2Str([0 1;-1 0]*D/FE.eLen);
  P = g1*A + g2*B + (1-g1-g2)*C;
  FE.G2DA = jacobian(P,FE.GCS); 
  FE.G2DB = simple(P - FE.G2DA*FE.GCS(:));
  %  笛卡儿坐标 转变成 广义坐标
  %  Descartes to Generalized
  %  D2GA = inv(G2DA) D2GB = -inv(G2DA)*G2DB
  %  [g1;g2] = D2GA*[d1;d2]+D2GB;
  %  容易验证
  %  g1 = area2d(P,B,C)/area2d(A,B,C)
  %  g2 = area2d(P,C,A)/area2d(A,B,C)
  P = FE.DCS(:);
  f = [area2d(P,B,C); area2d(P,C,A)]/eVol;
  FE.D2GA = jacobian(f,P);
  FE.D2GB = simple(f - FE.D2GA*P);
  %  体积分范围
  %  ∫dg1 ∫VEXP dg2
  FE.INTVSTR = 'l_v=int(int(VEXP,g2,0,1-g1),g1,0,1);';
  %  边界积分范围
  %  ∫BEXP dg
  FE.INTBSTR = 'g2 = 1-g1;l_b=int(BEXP,g1,0,1);';
  % Gauss Quadratic interior points and weights
  FE.QPGC = [	
    1.0/3.0,			1.0/3.0;
    0.797426985353087,	0.101286507323456;
    0.101286507323456,	0.797426985353087;
    0.101286507323456,	0.101286507323456;
    0.470142064105115,	0.059715871789770;
    0.470142064105115,	0.470142064105115;
    0.059715871789770,	0.470142064105115 ]';
  
  FE.QPW =[ 
    0.11250000000000,
    0.0629695902724135,
    0.0629695902724135,
    0.0629695902724135,
    0.066197076394253,
    0.066197076394253,
    0.066197076394253 ];
  FE.NQP = size(FE.QPW(:),1);
  
%   FE.INTBSTR = {
%     'g1 = 0;l_b1=int(BEXP,g2,0,1);';
%     'g2 = 0;l_b2=int(BEXP,g1,1,0);';
%     'g2 = 1-g1;l_b3=int(BEXP,g1,0,1);';
%     'l_b = [l_b1 l_b2 l_b3];'};
  if np == 3,
    %  三点元 ShapeFunction为
    %    f1(P) = g1
    %    f2(P) = g2
    %    f3(P) = g3 = 1 - g1 - g2 
    %  GCS Terms线性组合组成不同的ShapeFunction, 项数为顶点数
    FE.GCST = '1 g1 g2';
    %  顶点的广义坐标
    FE.PGC = [  1 0 0; 0 1 0];
  elseif np == 6,
    %------------------------------------
    %  六点元
    %           A
    %          / \
    %         /   \
    %        F     E
    %       /   P   \
    %      /         \
    %     B-----D-----C
    %
    %  ShapeFunction为
    %    f1(P) = g1*(2*g1-1)
    %    f2(P) = g2*(2*g2-1)
    %    f3(P) = g3*(2*g3-1)
    %    f4(P) = 4*g2*g3
    %    f5(P) = 4*g1*g3
    %    f6(P) = 4*g1*g2
    FE.GCST = '1 g1 g2 g1*g2 g1*g1 g2*g2';
    FE.PGC = [
      1 0 0  0 .5 .5;
      0 1 0 .5  0 .5];
  end
end
FE = CaclSF(FE);
FE = FormSF(FE);

%--------------------------------------------------------------------------
% caculate shape function coefficients and then generate formulas 
function FE = CaclSF(FE)
% GCST eval string
gcststr =['[' FE.GCST '];'];
% Caculate shapefunctions
a = zeros(FE.NP);
for p = 1:FE.NP % Row
  % Set GC as PGC{p}
  eval(['[' FE.GCSSTR '] = arrayout(FE.PGC(:,p));']);
  %   for igc = 1:FE.DIM
  %     eval([char(FE.GCS(igc)) '= FE.PGC(igc,p);']);
  %   end
  a(p,:) = eval(gcststr);
end
% SFCoeff每列对应一个形函数(Shape Function) 
FE.SFCoeff = inv(a);

%--------------------------------------------------------------------------
% using symbolic tools to form formulas of shape functions
function FE = FormSF(FE)
eval(['syms ' FE.GCSSTR ' real']);
FE.GCSTSym = eval(['[' FE.GCST '];']);
for p = 1:FE.NP
  FE.SFSym(p) = sym('0');
  for gcst = 1:FE.NP
    coeff = FE.SFCoeff(gcst,p);
    if coeff ~= 0,
      FE.SFSym(p) = FE.SFSym(p) + coeff*FE.GCSTSym(gcst);
    end
  end
  FE.SFStr{p} = ['(' char(FE.SFSym(p)) ')'];
end

function FE = test()
%FECreate Summary of this function goes here
%  Dg2iled explanation goes here
FE = FECreate(2,6);

%  Area of triangle
%  计算三角形面积
function a = area2d(A,B,C)
a = det([B - A, C - A])/2;