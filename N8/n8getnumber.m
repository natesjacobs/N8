function value = n8getnumber(promptvalue,promptstring,dim1,dim2)

%check input arguments
if nargin<4, dim2=1; end
if nargin<3, dim1=1; end
if nargin<2, promptstring='Input value and press return'; end
if nargin<1, promptvalue='enter value'; end

%convert promptvalue to cell
if ~iscell(promptvalue)
    promptvalue={promptvalue};
end

%repeat promptvalue if dims don't match dim1 and dim2
if size(promptvalue,1)~=dim1 || size(promptvalue,2)~=dim2
    promptvalue='enter value';
    promptvalue=repmat(promptvalue,dim1,dim2);
end

%set value to empty
value=NaN;

%increase window size if many choices
if dim1>4
    h=0.3;
else
    h=0;
end
if dim2>4
    w=0.1;
else
    w=0;
end

%figure window & prompt
fgetnumber=figure('name',promptstring,...
    'Units','normalized',...
    'OuterPosition',[0.35-w 0.6-h 0.3+w 0.2+h],...
    'toolbar','none',...
    'menubar','none');

if dim1+dim2==2
    %choices for single input
    b1=uicontrol(gcf,'Style','edit',...
        'String',promptvalue{1},...
        'FontSize',25,...
        'ForegroundColor',[0.5 0.5 0.5],...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Callback',@send1);
else
    %choices for multi input
    for d1=1:dim1
        for d2=1:dim2
            b1(d1,d2)=uicontrol(gcf,'Style','edit',...
                'FontSize',14,...
                'Units','normalized',...
                'Position',[0+(1/dim2)*(d2-1) (1-(0.8/dim1))-(0.8/dim1)*(d1-1) 1/dim2 0.8/dim1],...
                'String',promptvalue{d1,d2});
        end
    end
    %button to send choices
    uicontrol(gcf,'Style','pushbutton',...
        'String','done',...
        'FontSize',11,...
        'FontWeight','bold',...
        'Units','normalized',...
        'SelectionHighlight','off',...
        'Position',[0 0 1 0.2],...
        'Callback',@send2);
end

%wait for user input
while isnan(value)
    pause(0.2);
    try 
        test=get(fgetnumber);
    catch
        break;
    end
end

%functions
    function send1(~,~)
        value=get(b1,'string');
        value=str2double(value);
        %wait until number is entered
        if ~isnan(value)
            close(fgetnumber);
        end
    end
    function send2(~,~)
        for d1=1:dim1
            for d2=1:dim2
                v=get(b1(d1,d2),'string');
                v=str2double(v);
                value(d1,d2)=v;
            end
        end      
        %wait until all numbers are entered
        if ~isnan(mean(value(:)))
            close(fgetnumber);
        end
    end
end