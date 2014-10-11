function astr = Sym2Str(asym,barrayop)
%SYM2STR Summary of this function goes here
%  Detailed explanation goes here
if nargin == 1
  barrayop = 1;
end
while strcmp(class(asym),'cell')
  aasym = [asym{:}];
  asym = aasym;
end
n = size(asym(:),1);
astr ={};
for i=1:n
  str = char(asym(i));
  if strcmp(str,'0')
    astr{i} = '';
  else
    if barrayop
      astr{i} = Op2ArrayOp(str); 
    else
      astr{i} = str; 
    end
  end
end

astr = reshape(astr,size(asym));
