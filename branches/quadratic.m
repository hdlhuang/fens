function [ output_args ] = quadratic( input_args )
%QUADRATIC Summary of this function goes here
%  Detailed explanation for zeta eta refer to shapeFunctions.m
global quad6;
quad6.numFuncs = 6;
quad6.numPoints = 7;
%  Each row contains zeta eta Weight.
quad6.Points = [
	1.0/3.0,			1.0/3.0,	0.11250000000000;  
	0.797426985353087,	0.101286507323456,      0.0629695902724135;
	0.101286507323456,	0.797426985353087,      0.0629695902724135;
	0.101286507323456,	0.101286507323456,      0.0629695902724135;
	0.470142064105115,	0.059715871789770,      0.066197076394253; 
	0.470142064105115,	0.470142064105115,      0.066197076394253; 
	0.059715871789770,	0.470142064105115,     0.066197076394253];
quad6.ShapeFuncs = [
  @ShapeFunction1 @ShapeFunction2 @ShapeFunction3 ... 
  @ShapeFunction4 @ShapeFunction5 @ShapeFunction6];

function EvaluateShapeFunctions_Quadratic_Private(zeta,eta,xy)
%	 ASSUMPTION: The coordinates passed in are corrected for periodicity
global quad6;
x    = 0.0;		y    = 0.0;
dxdz = 0.0;		dxde = 0.0;
dydz = 0.0;		dyde = 0.0;
for func = 1:quad6.numFuncs
  a = feval(quad6.ShapeFuncs(func),zeta,eta,00);
  dz = feval(quad6.ShapeFuncs(func),zeta,eta,10);
  de = feval(quad6.ShapeFuncs(func),zeta,eta,01);
  x = x + xy(func,0)*a;
  y = y + xy(func,1)*a;
  dxdz = dxdz + xy(func,0)*dz;
  dxde = dxde + xy(func,0)*de;
  dydz = dydz + xy(func,1)*dz;
  dyde = dyde + xy(func,1)*de;
end

function f = ShapeFunction1(zeta,eta,der)
%  ShapeFunction der 含义:十位上为对zeta求导次数,个位上为对eta求导次数
switch der
  case 0
    f = zeta*(2*zeta-1);
  case {10,20}
    f = 4*zeta;
  otherwise
    f = 0;
end

function f = ShapeFunction2(zeta,eta,der)
switch der
  case 00
    f = eta*(2*eta-1);
  case {01,02}
    f = 4*eta;
  otherwise
    f = 0;
end

function f = ShapeFunction3(zeta,eta,der)
switch der
  case 00
    f = 1 - 3*(zeta+eta) + 2*(zeta+eta)^2;
  case {10,01}
    f = 4*(zeta+eta) - 3;
  case {11,02,20}
    f = 4;
  otherwise
    f = 0;
end

function f = ShapeFunction4(zeta,eta,der)
switch der
  case 00
    f = 4*eta*(1-zeta-eta);
  case 10
    f = -4*eta;
  case 01
    f = 4*(1-zeta-2*eta);
  case 02
    f = -8;
  case 11
    f = -4;
  otherwise
    f = 0;
end

function f = ShapeFunction5(zeta,eta,der)
switch der
  case 00
    f = 4*zeta*(1-zeta-eta);
  case 01
    f = -4*zeta;
  case 10
    f = 4*(1-eta-2*zeta);
  case 20
    f = -8;
  case 11
    f = -4;
  otherwise
    f = 0;
end

function f = ShapeFunction6(zeta,eta,der)
switch der
  case 00
    f = 4*eta*zeta;
  case 10
    f = 4*eta;
  case 01
    f = 4*zeta;
  case 11
    f = 4;
  otherwise
    f = 0;
end

function Setup_Triangular_2D_Quadratic()
%  
global quad6;
for p=1:quad6.numPoints
  zeta  = quad6.Points(p,1);
	eta = quad6.Points(p,2);
	for func = 1:quad6.numFuncs
    quad6.ShapeFuncs(func) = feval(quad6.ShapeFuncs(func),zeta,eta,00);
    quad6.ShapeFuncDers(func,1) = feval(quad6.ShapeFuncs(func),zeta,eta,10);
    quad6.ShapeFuncDers(func,2) = feval(quad6.ShapeFuncs(func),zeta,eta,01);
  end
end
