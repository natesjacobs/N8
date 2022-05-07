function c = cmap1
%light to dark symmetric scale mape (similar to HSV)

%initialize 64x3 array of RGB values
c=zeros(64,3);

%create symmetric color scale
c(1:32,:)=NegColors(32);
c(33:64,:)=PosColors(32);

%convert from 1:256 to 0:1
c=c/255;

%functions
    function cmap_n = NegColors(nsteps)
        cmap_n=zeros(nsteps,3);
        %color transition 2 (redish to purple)
        n1=round(nsteps*3/7); %n steps
        cmap_n(1:n1,1)=0:(175)/(n1-1):175; %fliplr(175:(225-175)/(n1-1):225); %R:175->0
        cmap_n(1:n1,2)=0; %G:0
        cmap_n(1:n1,3)=75:(255-75)/(n1-1):255; %B:75->255
        %color transition 3 (purple to torqouise)
        n3=nsteps-n1;
        cmap_n(end-n3:end,1)=fliplr(0:175/n3:175); %R:175->0
        cmap_n(end-n3:end,2)=0:255/n3:255; %G:0->255
        cmap_n(end-n3:end,3)=255; %B=255
    end
    function cmap_p = PosColors(nsteps)
        cmap_p=zeros(nsteps,3);
        %color transition 1 (torqouise to yellow, exponential)
        n1=round(nsteps*1/7);
        x1=n1+1;
        cmap_p(1:x1,1)=(0:sqrt(255)/n1:sqrt(255)).^2; %R:0->255, exp
        cmap_p(1:x1,2)=255; %G=255
        cmap_p(1:x1,3)=fliplr(sqrt(0:(255^2)/n1:(255^2))); %B:255->0, sqrt
        %color transition 2 (yellow to red)
        n2=round(nsteps*4.5/7);
        x2=x1+n2;
        cmap_p(x1:x2,1)=255; %R=255
        cmap_p(x1:x2,2)=fliplr(0:255/n2:255); %G:255->0
        cmap_p(x1:x2,3)=0; %B=0
        %color transition 3 (red to dark red)
        n3=round(nsteps-(nsteps*5.5/7));
        cmap_p(end-n3:end,1)=fliplr(128:(255-128)/n3:255); %R:255->128
        cmap_p(end-n3:end,2)=0; %G=0
        cmap_p(end-n3:end,3)=0; %B=0
    end
end




