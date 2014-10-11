function gd = Parser( filename )
%PARSER Summary of this function goes here
%  Detailed explanation goes here
if ~nargin
  error('Need Filename Argument')
end

VARSEC = 1; CFFSEC = 2; PDESEC = 3;
BDCSEC = 4; MSHSEC = 5; PARSEC = 6;
COMSEC = 7;
SectionStr = {
  'variables','coefficients','pdes',...
  'boundary','mesh','parameters','comments'};
section = 0;

vlist = {};   clist = {};
cname = {};   cvlist = {};
pdevlist = {};
bdclist = {}; bdtlist = [];

% default parameter values
dim = 2;  np = 3; gaussint = 0;

fid = fopen(filename);
line = 0;
try
while 1
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  line = line + 1;
  % Delete comments
  i = FindFirstChar([tline '%'],'%');
  str = tline(1:i-1);
  pre = ' 	,;=>';
  while 1
    [token,str] = GetToken(str,pre,pre);
    switch token.type
      case 0
        break;
      case 1
        x = strmatch(lower(token.str),SectionStr);
        if ~isempty(x)
          section = x(1);
        end
      case 2
        switch section
          case VARSEC
            namestr = token.str;
            if CheckVarName(namestr)
              pos = GetAppendStrPos(vlist,namestr);
              vlist{pos} = namestr;
            end
          case {CFFSEC,PARSEC}
            namestr = token.str;
            if CheckVarName(namestr)
              [token,str] = GetToken(str,pre,';');
              valstr = token.str;
              if section == CFFSEC
                pos = GetAppendStrPos(cname,namestr);
                cname{pos} = namestr;
                cvlist{pos} = valstr;
                clist{pos} = [namestr '=' valstr ';'];
              else
                eval([lower(namestr) '=' valstr ';']);
              end
            end
          case PDESEC
            x = strmatch(token.str,vlist,'exact');
            if ~isempty(x)
              [token,str] = GetToken(str,pre,';');
              pdevlist{x(1)} = token.str;
            end
          case BDCSEC
            namestr = token.str;
            x = strmatch(namestr,vlist,'exact');
            if ~isempty(x)
              [token,str] = GetToken(str,[pre '['],']');
              try
                bdl = eval(['[' token.str '];']);
                [token,str] = GetToken(str,[']' pre],pre);
                bdt = eval([token.str ';']);
                bdclist(x(1),bdl) = {str};
                bdtlist(x(1),bdl) = bdt;
              catch
              end
            end
          case MSHSEC
            meshfilename = token.str;
          otherwise
        end % switch section
    end % switch token.type
  end % while
end
catch
  gd = 0;
end
fclose(fid);
gd.FE = FECreate(dim,np);
gd.FE.GAUSSINT = gaussint;
PDES.PDEVLIST = pdevlist;
PDES.VLIST = vlist;
PDES.CLIST = clist;
PDES.CNAME = cname;
PDES.CVLIST = cvlist;
PDES.BDCLIST = bdclist;
PDES.BDTLIST = bdtlist;
gd.PDES = PDECreate(PDES);
gd.MESHFILE = meshfilename;

function valid = CheckVarName(name)
valid = 1;
try
  eval([name '=0;']);
catch
  valid = 0;
end

function pos = GetAppendStrPos(list,str)
x = strmatch(str,list,'exact');
if isempty(x)
  pos = size(list(:),1)+1;
else
  pos = x(1);
end

function list = AppendStrList(list,str)
list{GetAppendStrPos(list,str)} = str;

function [token,str] = GetToken(str,pre,suf)
token = struct('str','','type',0);
str = SkipChar(str,pre);
if length(str)
  if str(1) == '<'
    token.type = 1;
    str = SkipChar(str,[pre '<']);
    i = FindFirstChar(str,'>');
    str(i) = '';
  else
    token.type = 2;
    i = FindFirstChar(str,suf);
  end
  token.str = str(1:i-1);
  str = str(i:end);
end

function i = FindFirstChar(str,findstr)
n = length(str);
for i=1:n
  if any(findstr == str(i))
    return;
  end
end
i = i+1;
    
function i = FindFirstNotChar(str,findstr)
n = length(str);
for i=1:n
  if ~any(findstr == str(i))
    return;
  end
end
i = i+1;

function str = SkipChar(str,skipstr)
i = FindFirstNotChar(str,skipstr);
str = str(i:end);

function str = SkipNotChar(str,skipstr)
i = FindFirstChar(str,skipstr)
str = str(i:end);

function str = SkipBlank(str)
str = SkipChar(str,' 	');

function str = DelExtraBlank(str)
% delete comments
i = find([str '%']=='%');
str = str(1:i(1)-1);
% find blank and tab characters
str = strrep(str,'	',' ');
i = find(str==' ');
% delete continuous
j = find(diff(i)==1);
str(i(j)) = '';


  