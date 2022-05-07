function [choice,choice_string]=n8choosestring(promptstring,stringchoices)

%set choice output to empty
choice=[];

%size of string
d=size(stringchoices);
if sum(d)<4
    fsize=26;
elseif sum(d)<16
    fsize=16;
else
    fsize=9;
end

%figure window & prompt
fchoosestring=figure('name',promptstring,...
    'Units','normalized',...
    'OuterPosition',[0.35 0.6 0.3 0.2],...
    'toolbar','none',...
    'menubar','none');

%choices
for d1=1:d(1)
    for d2=1:d(2)
        locs(d1,d2)=uicontrol(gcf,'Style','pushbutton',...
            'String',stringchoices{d1,d2},...
            'FontSize',fsize,...
            'Units','normalized',...
            'SelectionHighlight','off',...
            'HitTest','off',...
            'Position',[0+(1/d(1))*(d1-1) (1-(1/d(2)))-(1/d(2))*(d2-1) 1/d(1) 1/d(2)],...
            'CallBack',@send);
    end
end

%wait for user input
while isempty(choice)
    pause(0.2);
    try 
        test=get(fchoosestring);
    catch
        break;
    end
end

%functions
    function send(src,~)
        choice=find(locs==src);
        choice_string=stringchoices{choice};
        close(fchoosestring);
    end
end
        
        