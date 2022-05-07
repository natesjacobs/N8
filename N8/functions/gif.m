function gif(images,FR,colormap)

%NEED TO DECIDE WHAT THIS FUNCTION IS SUPPOSED TO DO

%Saves input images as GIF in current folder. 
%input images should be 4D - m x n (dim1 and dim2) with RGB values (dim3) and
%multiple frames stored in dim 4
%Default frame rate is 30.
%if RGB values not provided in dim4, uses colormap

if nargin<3, colormap=jet; end
if nargin<2, FR=30; end

%make gif
for n=1:size(images,4)
frame = getframe(1);
im = frame2im(frame);
[A,map] = rgb2ind(im,256); 
	if n == 1;
		imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
	else
		imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
	end
end

%make video
f = VideoWriter(string,'MPEG-4');
%set frame rate
set(f,'FrameRate',FR)
%save .mp4 file
open(f)
writeVideo(f,M);
close(f);