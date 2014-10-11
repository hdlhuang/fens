function l_str = Op2ArrayOp(l_str);
%OP2ARRAYOP Summary of this function goes here
%  Detailed explanation goes here
% 改变成数组运算符号
l_str = strrep( l_str,'*','.*' );
l_str = strrep( l_str,'/','./' );
l_str = strrep( l_str,'^','.^' );
l_str = strrep( l_str,'\','.\' );

