function CreateMenu( items,parent,mname )
%CREATEMENU Summary of this function goes here
%  Detailed explanation goes here
nitem = size(items,1);
level = 1;
Separator = 'off';
namelen = length(mname);
for i = 1:nitem
    str = items{i};
    if strcmp(str,'>')
        level = level + 1;
    elseif strcmp(str,'<')
        level = level - 1;
    elseif strcmp(str,'-')
        Separator = 'on';
    else
        [lbl,acc]=menulabel(str);
        tag = strrep(lbl,'&','');
        if namelen > 0
            action = [mname '(''' tag ''')'];
        else
            action = '';
        end
        parent(level+1) = uimenu(parent(level),'Accelerator',acc,'Label',lbl,...
            'Tag',[mname tag],'Separator',Separator,'CallBack',action);
        Separator = 'off';
    end
end
