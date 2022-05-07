function n8bl

global DATA NOTES

%get baseline value
b=n8getnumber('baseline start (sec)');
if b==0
    b=1/NOTES.SampleRate;
end
if ~isnan(b)
    b(2)=n8getnumber('baseline end (sec)');
end
if sum(isnan(b))>0
    NOTES.Baseline=[];
    NOTES.BaselineNorm=1;
    set(b4b,'value',1);
else
    NOTES.Baseline=round(b*NOTES.SampleRate);
end