function n8_big
%opens & checks .mat files using N8 architecture
%N8 Requirements:
% Dimension 1 - Space (X)
% Dimension 2 - Space (Y)
% Dimension 3 - Space (Z, depth)
% Dimension 4 - Time
% Dimension 5 - Condition
% Dimension 6 - Other (subject)
% Dimension 7 - Other (trial)
% Dimension 8 - Other (n-trode)

%% Variables
global NOTES DATA

%% Open data file object (reference to .mat file)
%find n8data filenames
f = dir('*n8data*.mat');
%user select files
disp('Loading N8 data:');
if isempty(f)
    [fn,path]=uigetfile('*.mat','Select N8 data file to load');
    disp([' ' cd '\' fn]);
    DATA = matfile([path fn],'Writable',true);
elseif size(f,1)==1
    disp([' ' cd '\' f.name]);
    DATA = matfile(f.name,'Writable',true);
    fn=f.name;
elseif size(f,1)>1
    [fn,path]=uigetfile('*n8data*.mat','Select N8 data file to load');
    disp([' ' cd '\' NOTES.SaveString]);
    DATA = matfile([path fn],'Writable',true);
end
%load NOTES variable into workspace
NOTES=DATA.NOTES;

%% Check NOTES fields
n8check;

%% Message & Plot
clc;
display(' ');
display(' ');
display('global DATA NOTES;  n8plot;');
display(' ');
display(' ');

