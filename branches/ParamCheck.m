function f = ParamCheck(ParamName,ParamValue,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7)
% Error checks
nargs = nargin;
if rem(nargs,2)|(nargs<2),
  error('2 compulsory arguments and optional parameters in pairs')
end

if ~isstr(ParamName),
  error('ParamName must be a string')
elseif size(ParamName,1)~=1,
  error('ParamName must be a non-empty single row string.')
end

ParamType = class(ParamValue);
nParam = nargs/2 - 1;
for i=1:nParam,
  Param = eval(['p' int2str(i)]);
  Value = eval(['v' int2str(i)]);
  if ~isstr(Param),
    error('Parameter must be a string')
  elseif size(Param,1)~=1,
    error('Parameter must be a non-empty single row string.')
  end
  switch lower(Param)
    case {'t','type'}
      type=lower(Value);
      if ~isstr(type),
        error('Type must be a string.')
      end
      if ~strcmp(ParamType,type),
        error(['Type mismatch,' type ' wanted not ' ParamType])
      end
    case {'c','condition'}
      condition = lower(Value);
      if ~isstr(condition),
        error('Condition must be a string.')
      end
      condition = strrep(condition,'v','ParamValue');
      condition = strrep(condition,'/ParamValue','v');
      if ~eval(condition),
        error(['condition ' condition ' not satisfied'])
      end
    case {'vl','value list'}
      if strcmp(ParamType,'double'),
        v = [' ' num2str(ParamValue) ' '];
        vl = [' ' Value ' '];
      elseif strcmp(ParamType,'char'),
        v = ['|' ParamValue '|'];
        vl = ['|' Value '|'];
      else
        error(['Sorry ' ParamType ' not suportted yet for value list']);
      end
      if ~[0 strfind(vl,v)],
          error([ParamName ' must be ' lower(Value)]);
      end
    otherwise
      error(['Unknown parameter: ' Param])
  end
end