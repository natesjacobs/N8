function n8save(justNOTESyesno)
%only saves NOTES variable by default, to save DATA also input
%n8save(false)

global DATA NOTES

%% Variables
if nargin<1
    justNOTESyesno=true;
end
fn=[NOTES.SaveString '.mat'];

%% Check if directory exists and save
if isempty(dir(fn))
    save(fn,'DATA','NOTES','-v7.3');
else
    obj=matfile(fn,'Writable',true);
    obj.NOTES=NOTES;
    if ~justNOTESyesno
        obj.DATA=DATA;
    end
end
