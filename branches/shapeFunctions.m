function [ output_args ] = shapeFunctions( input_args )
%EQUATIONS Summary of this function goes here
%  Detailed explanation goes here
%  三点的有限元
%         A
%        /  \
%       /  P  \
%      B------- C
%  坐标 A(x1,y1)  B(x2,y2) C(x3,y3)
%  定义P(x,y)点广义坐标
%    zeta = area(PBC)/area(ABC) = [(x-x2)(y-y3)-(x-x3)(y-y2)]/[(x1-x2)(y1-y3)-(x1-x3)(y1-y2)]
%    eta = area(PAC)/area(ABC)
%    theta = area(PAB)/area(ABC)
%    zeta + eta + theta = 1
%  ShapeFunction为
%    f1(P) = zeta
%    f2(P) = eta
%    f3(P) = theta 

%  六点的有限元 ShapeFunction
%           A
%          / \
%         /   \
%        F     E
%       /   P   \
%      /         \
%     B-----D-----C
%
%  坐标 A(x1,y1)  B(x2,y2) C(x3,y3) D(x4,y4)  E(x5,y5) F(x6,y6)
%  P(x,y)点广义坐标同前
%  ShapeFunction为
%    f1(P) = zeta*(2*zeta-1)
%    f2(P) = eta*(2*eta-1)
%    f3(P) = theta*(2*theta-1)
%    f4(P) = 4*eta*theta
%    f5(P) = 4*zeta*theta
%    f6(P) = 4*zeta*eta

syms zeta eta;
theta = 1 - zeta - eta;
f1 = zeta
f2 = eta
f3 = theta 
f1 = zeta*(2*zeta-1)
f2 = eta*(2*eta-1)
f3 = theta*(2*theta-1)
f4 = 4*eta*theta
f5 = 4*zeta*theta
f6 = 4*zeta*eta