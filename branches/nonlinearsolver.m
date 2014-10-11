function [u,res]=nonlinearsolver(p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7)
%nonlinearsolver Solve nonlinear PDE problem.
%
%       [U,RES]=nonlinearsolver(D) solves the nonlinear
%       PDE problem described by d including boundary conditions, on a mesh
%       described by P, E, and T,, using damped Newton iteration with the
%       Armijo-Goldstein line search strategy.
%
%       The solution u is represented as the MATLAB column vector U.
%       RES is the 2-norm of the Newton step residuals.
%
%       The geometry of the PDE problem is given by the triangle
%       data P, E, and T. See either INITMESH or PDEGEOM for details.
%
%       The optional arguments TOL and U0 signify a relative tolerance
%       parameter and an initial solution respectively.
%
%       Fine tuning parameters may be sent to the solver in the form of
%       Parameter-Value pairs. It is possible to choose between computing
%       the full Jacobian, a "lumped" approximation or a fixed point
%       iteration and supply an initial guess of the solution.
%       The maximum number of iterations, the minimal damping factor of
%       the search vector, the size and norm of the residual at termination
%       can be controlled. These adjustments are made by setting one ore more
%       of the following property/value pairs:
%
%       Property   Value/{Default}              Description
%       --------------------------------------------------------------
%       Jacobian   'lumped'|'full'|{'fixed'}    Jacobian approximation
%       U0          string|numeric {0}          Set initial guess
%       Tol         numeric scalar {1e-4}       Acceptable residual
%       MaxIter     numeric scalar {25}         Maximum iterations
%       MinStep     numeric scalar {1/2^16}     Minimal damping factor
%       Report      'on'|{'off'}                Write convergence info.
%       Norm        numeric|{Inf}|'energy'      Residual norm
%
%       Diagnostics: If the Newton-iteration does not converge, the
%       error messages 'Too many iterations' or 'Stepsize too small' are
%       displayed.

%       HDL 1-11-2004
%       Copyright MicroHDL, Inc.
%       $Revision: 1.10 $  $Date: 2004/01/09 17:03:18 $

% Error checks
if rem(nargin,2),
  error('optional parameters in pairs')
end

% Default values
maxiter=25;
minstep=2^(-16);
tol=1e-4;
u0=0;
jacobian='fixed';
usenorm='inf';
report=0;
nParam = nargin/2;
for i=1:nParam,
  Param = eval(['p' int2str(i)]);
  Value = eval(['v' int2str(i)]);
  ParamCheck('ParameterName',Param,'t','char','c','size(v,1)==1');
  Param = lower(Param);
  switch Param
    case 'jacobian'
      jacobian=Value;
      ParamCheck('Jacobian',jacobian,'t','char','vl','fixed|lumped|full');
    case 'tol'
      tol=Value;
      ParamCheck('Tolerance',tol,'t','double','c','~imag(v)&&v>0');
    case 'u0'
      u0=Value;
    case 'maxiter'
      maxiter=Value;
      ParamCheck('MaxIter',maxiter,'t','double','c','~imag(v)&&v>0');
    case 'minstep'
      minstep=Value;
      ParamCheck('MinStep',minstep,'t','double','c','~imag(v)&&v>0');
    case 'report'
      Value=lower(Value);
      ParamCheck('report',Value,'t','char','vl','off|on|false|true');
      if strfind(Value,'off false'),report=0; else report=1;  end
    case 'norm'
      usenorm=Value;
      if isstr(usenorm)
        ParamCheck('Norm',lower(usenorm),'vl','inf|-inf|energy');
      elseif (size(usenorm)~=[1 1])|(imag(usenorm)~=0)
        error('Norm must be a scalar')
      end
    otherwise
      error(['Unknown parameter: ' Param])
  end
end

if report
  PrintHeader;
  %disp(['Iteration     Residual     Step size  Jacobian: ',jacobian])
  %disp(sprintf('%4i%20.10f',0,res))
end
u = u0; res = []; nr2 = inf;
% Gauss-Newton iteration
iter=0; tmp=u;
cor=zeros(size(u));
while 1
  iter=iter+1;
  if iter>maxiter,  error('Too many iterations');  end
  if strcmp(jacobian,'lumped')
  elseif strcmp(jacobian,'full')
  end
  [K,F,H,R]=assem(u);
  %ii =find(any(H));  K(ii,:)=H(ii,:);
  %F(ii)=R(ii);
  r = F+R*1e10;
  J = K+H*1e10;
  alpha = 1;  cor = -J\r;
  u = u + alpha*cor;
  [conv,errmsg] = SolverCheckErr(cor,u,iter,1,tol);
  if report
    HistoryLog(errmsg);
    PlotSolution(u);
  end
  if all(conv), break; end
  nres = 1;
  while 0
    if alpha<minstep, error('Stepsize too small'), end
    tmp = u + alpha*cor;
    [nK,nF,nH,nR]=assem(tmp);
    r = nF+nR*1e10;
    J = nK+nH*1e10;
    rr = r - J*tmp;
    %rr = F - K*tmp;
    if isstr(usenorm)
      if strcmp(usenorm,'energy')
        nrr=rr'*K*rr;
      else
        nrr=norm(rr,usenorm)^2;
      end;
    else
      nrr=(norm(rr,usenorm)/length(rr)^(1/usenorm))^2;
    end
    if nr2-nrr < alpha/2*nr2
      alpha = alpha/2;
    else
      u = tmp;      r = rr;
      nr2 = nrr;    nres = sqrt(nr2);
      if report
        pdetool('plotu',tmp);
        disp(sprintf('%4i%20.10f%12.7f',iter,nres,alpha))
      end
      break
    end
  end
  res=[res;nres];
  if nres < tol,break; end
end

%--------------------------------------------------------------------------
function PrintHeader()
global gd;
HistoryLog('Finite Element Method');
HistoryLog(sprintf('Dimension:%d\nPoints of element:%d',gd.FE.DIM,gd.FE.NP));
headerstr = ' its';
for i = 1:gd.PDES.NV
    headerstr = sprintf('%s %5s-err ',headerstr, gd.PDES.VLIST{i});
end
HistoryLog(headerstr);

%--------------------------------------------------------------------------
function [conv,errmsg] = SolverCheckErr(dx,x,iter,errtype,tol)
global gd;
nconv = 0;
errmsg = sprintf('%3d',iter);
errv = 0;
nvar = gd.PDES.NV;
np = size(dx(:),1)/nvar;
if size(x(:),1) == 1
  x = x.*ones(size(dx));
end
pos = [0:np-1]*nvar;
tol = tol.*ones(nvar,1);
for iv = 1:nvar
  idx = pos + iv;
  if errtype == 1
    % relative err
    errv(iv) = max( abs(dx(idx))./(abs(x(idx))+1e-100) );
  else
    % absolute err
    errv(iv) = max(abs(dx(idx)));
  end
  conv(iv) = errv(iv) < tol(iv);
  if conv(iv)
    convc = '*';
  else
    convc = ' ';
  end
  errmsg = sprintf('%s %s%1.3e',errmsg,convc,errv(iv));
end
