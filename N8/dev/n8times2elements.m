function elements = n8times2elements(times)

global NOTES

%convert from sec to elements
elements=times*(NOTES.SampleRate);

%if timescale is in ms, divide by 1000
if strcmp(NOTES.TimeScale,'msec')
    elements=elements/1e3;
end

%round to nearest intiger
elements=round(elements);

%replace any 0s with 1s (first element)
elements(elements==0)=1;