function string = n8getstring(promptstring,promptstring2)

%make sure promptstring1 is char
if nargin<1 || ~ischar(promptstring)
    promptstring='';
end

%make sure promptstring2 is char
if nargin<2 || ~ischar(promptstring2)
    promptstring2='Input text and press return';
end

%set value to empty
string=[];

%figure window & prompt
f1=figure('name',promptstring2,...
    'Units','normalized',...
    'OuterPosition',[0.35 0.6 0.3 0.2],...
    'toolbar','none',...
    'menubar','none');

%choices
b1=uicontrol(gcf,'Style','edit',...
    'String',promptstring,...
    'FontSize',25,...
    'ForegroundColor',[0.5 0.5 0.5],...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Callback',@send);

%wait for user input
x=0;
while isempty(string)
    x=x+1;
    pause(0.2);
    if x>300
        break;
    end
end

close(f1)

%functions
    function send(~,~)
        string=get(b1,'string');
    end
end