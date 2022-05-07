function choice=n8choose(dim1,dim2,string1,selected,string2)
%input size of dimension 1 (d1) and size of dimension 2 (d2)
%creates window for user to select option
%'selected' should be logical 2d matrix indicating which boxes should already be selected

%defaults
if nargin<1, dim1=3; dim2=4; end
if nargin<2, dim2=1; end
if nargin<3, string1='Choose location(s):'; end

%check 'selected' variable
if nargin<4 || size(selected,1)~=dim1 || size(selected,2)~=dim2
    selected=false(dim1,dim2);
end

%check promptstring2
if nargin<5 || size(string2,1)~=dim1 || size(string2,2)~=dim2
    for d1=1:dim1
        for d2=1:dim2
            string2{d1,d2}=num2str(sub2ind([dim1 dim2],d1,d2));
        end
    end
end

%set choice output to empty
choice=[];

%figure window & prompt string
fchoose=figure('name',['   ' string1],'Units','normalized',...
    'OuterPosition',[0.25 0.4 0.5 0.4],...
    'toolbar','none',...
    'menubar','none');

%choices
for d1=1:dim1
    for d2=1:dim2
        %determine if selected
        toggle=selected(d1,d2);
        locs(d1,d2)=uicontrol(gcf,'Style','togglebutton',...
            'FontSize',13,...
            'FontWeight','bold',...
            'String',string2{d1,d2},...
            'Units','normalized',...
            'SelectionHighlight','off',...
            'HitTest','off',...
            'Position',[0+(1/dim1)*(d1-1) (1-(0.8/dim2))-(0.8/dim2)*(d2-1) 1/dim1 0.8/dim2],...
            'Value',toggle);
    end
end

%button to select all
uicontrol(gcf,'Style','pushbutton',...
    'String','Select All',...
    'FontSize',12,...
    'Units','normalized',...
    'SelectionHighlight','off',...
    'Position',[0.03 0.01 0.44 0.18],...
    'Callback',@selectall);

%button to send choices
uicontrol(gcf,'Style','pushbutton',...
    'String','Done',...
    'FontSize',12,...
    'Units','normalized',...
    'SelectionHighlight','off',...
    'Position',[0.53 0.01 0.44 0.18],...
    'Callback',@closecontinue);

%wait for user input
while isempty(choice)
    pause(0.2);
    try 
        test=get(fchoose);
    catch
        break;
    end
end

%functions
    function selectall(~,~)
        for d1=1:dim1
            for d2=1:dim2
                set(locs(d1,d2),'Value',1);
            end
        end
    end
    function closecontinue(~,~)
        for d1=1:dim1
            for d2=1:dim2
                choice(d1,d2)=get(locs(d1,d2),'Value');
                choice=logical(choice);
            end
        end
        close(fchoose);
    end
end
        
        