function n8baseline

%globals
global NOTES

%get baseline start
b=n8getnumber('baseline start (sec)');
%check
if ceil(b*NOTES.SampleRate)<=0
    b=1/NOTES.SampleRate;
end

%get baseline end
if ~isnan(b)
    b(2)=n8getnumber('baseline end (sec)');
end
%check
if b(1)>b(2)
    b(2)=n8getnumber('baseline end should be greater than baseline start');
end
if b(2)>NOTES.Dimensions(4)
    b(2)=NOTES.Dimensions(4);
end

%check
if sum(isnan(b))>0
    NOTES.Baseline=[];
    NOTES.BaselineNorm=1;
    set(b5,'value',1);
else
    NOTES.Baseline=ceil(b*NOTES.SampleRate);
end


    
    
    
    