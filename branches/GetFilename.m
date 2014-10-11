function [filename, pathname] = GetFilename(bload)
%GETFILENAME Summary of this function goes here
%  Detailed explanation goes here
fileext = { 
  '*.mat;*.pde;*.txt','PDE Solver Saved Files (*.mat,*.pde,*.txt)';
  '*.mat','MAT-files (*.mat)';
  '*.pde;*.txt','PDE Scipt-files (*.pde,*.txt)';
  '*.*',  'All Files (*.*)'};
if bload
  [filename, pathname] = uigetfile(fileext,'打开文件');
else
  [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)'},'保存文件');
end
