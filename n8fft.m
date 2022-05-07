function [FFT,delta,theta,gamma]=n8fft(data,samplerate,window)
%calculates power spectra in 1 Hz bins
%separate power spectra are calculated for each sec of the trace
%data must be 1 x n vector
%to find power at particular Hz, use f which lists the Hz value for each
%element in DFT

%% Variables
if nargin<3, window=1; end
%convert to double
data=double(data);
%dimensions
d = ones(1,8);
d(1:length(size(data))) = size(data);
%n points for fft
if samplerate>10
    n = round(samplerate); %sets resolution of fft to exactly 1 Hz
else
    n = d(4); %arbitrary Hz steps in fft
end
%frequency values for each element in DFT
f = (0:n/2)*(samplerate/n);
%error if dim 8 is not free
if d(8)>1
    error('cannot compute FFT until dimension 8 is left as singleton.')
end

%% Compute DFT
t=round(samplerate*window);
l=floor(d(4)/t);
%preallocate data
d2=d; 
d2(4)=l;
d2(8)=length(f+1);
FFT=nan(d2);
delta=nan(d);
theta=nan(d);
gamma=nan(d);
for i=t:t:(l*t)
    %select 1 sec of data
    a=data(:,:,:,i-t+1:i,:,:,:,1);
    %calculate fft
    dft=fft(a,n,4);
    %crop to Nyquist frequency
    dft=dft(:,:,:,1:round(n/2),:,:,:,:);
    %move to dim 8
    dft=permute(dft,[1 2 3 8 5 6 7 4]);
    %Calculate power of DFT (complex conjugate)
    dft=(dft.*conj(dft));
    %normalize to max value
    m=max(dft,[],8);
    m=repmat(m,[1,1,1,1,1,1,1,size(dft,8)]);
    dft=dft./m;
    %save in output
    FFT(:,:,:,i/t,:,:,:,1:size(dft,8))=dft;
    %ave across specific bandwidths and save at same samplerate
    delta=mean(dft(:,:,:,:,:,:,:,1:4),8);
    theta=mean(dft(:,:,:,:,:,:,:,6:12),8);
    gamma=mean(dft(:,:,:,:,:,:,:,40:80),8);
    %tile arrays to make same sample rate as other continuous data
    delta(:,:,:,i-t+1:i,:,:,:,:)=repmat(delta,[1,1,1,t,1,1,1,1]);
    theta(:,:,:,i-t+1:i,:,:,:,:)=repmat(theta,[1,1,1,t,1,1,1,1]);
    gamma(:,:,:,i-t+1:i,:,:,:,:)=repmat(gamma,[1,1,1,t,1,1,1,1]);
end

%% Make DATA.FFTx exact same length as DATA.Raw
% test=size(delta,4)-size(data,4);
% if test~=0
%     %change length of delta, etc. to match dim of raw
% end


%% Make length of f and DFT the same (no longer including f in output)
% Lf=length(f);
% Ld=size(FFT,8);
% if Lf>Ld
%     f=f(1:size(FFT,8));
% elseif Ld>Lf
%     FFT=FFT(:,:,:,:,:,:,:,1:length(f));
% end

