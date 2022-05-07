function times = n8elements2times(elements)

global NOTES

%set element 1 = 0;
elements(elements==1)=0;

%convert from elements to times
times=elements/(NOTES.SampleRate);

%if timescale is in ms, multiply by 1000
if strcmp(NOTES.TimeScale,'msec')
    times=times*1e3;
end