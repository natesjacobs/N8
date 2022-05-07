function n8
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
evalin('base','global NW NA NOTES');

%% Open data file
files = dir('*n8data*.mat');
if isempty(files)
    files = dir('*n4data*.mat');
end
disp('Loading N8 data:');
if isempty(files)
    [fn,path]=uigetfile('*.mat','Select N8 data file to load');
    disp([' ' cd '\' fn]);
    load([path fn]);
elseif size(files,1)==1
    disp([' ' cd '\' files.name]);
    load(files.name);
    fn=files.name;
elseif size(files,1)>1
    if ~isempty(dir('*n8data*.mat'))
        [fn,path]=uigetfile('*n8data*.mat','Select N8 data file to load');
    else
        [fn,path]=uigetfile('*n4data*.mat','Select N8 data file to load');
    end
    NOTES.SaveString = fn;
    disp([' ' cd '\' NOTES.SaveString]);
    load([path fn]);
end

%% Update save string to filename
%remove any extension from fn
ext=strfind(fn,'.');
if ~isempty(ext)
    fn=fn(1:ext-1);
end
NOTES.SaveString=fn;

%% Check NOTES fields
n8check;
clc;
disp(' ');
disp('type "n8plot" to visualize data');
disp(' ');
disp(' ');


n8plot;

