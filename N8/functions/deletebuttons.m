function deletebuttons

buttons1=findobj('Style','pushbutton');
buttons2=findobj('Style','popup');

delete(buttons1);
delete(buttons2);