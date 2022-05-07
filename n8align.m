function [data,T,m] = n8align(data)
%aligns images automatically
%only use with real images that have sufficient anchor points
%crops image borders and focuses on center 70% of image for alignment

%% Variables
%dimensions of data
d=ones(1,8);
d(1:length(size(data)))=size(data);
crop1= floor(d(1)/15);
crop2= floor(d(2)/15);

%% Vectorize all non-spatiotemporal dimensions
data=reshape(data,[d(1:4) prod(d(5:8))]);

%% Get shift indices
for d3=1:d(3)
    for dx=1:prod(d(5:8)) %"dx" = dims 5-8
        %get shift indices
        [m{d3,dx},T{d3,dx}]=align(1:d(4));
        %shift array
        for i=1:d(4)
            %get shift indices
            sh=T{d3,dx}(i,:);
            %shift data
            data(:,:,d3,i,dx)=circshift(data(:,:,d3,i,dx),sh);
        end
    end
end

%% Functions
    function [m,T] = align(d4)
        % Aligns images in data for all indices in idx
        % m - mean image after the alignment
        % T - optimal translation for each frame
        if(length(d4)==1)
            A = data(1+crop1:end-crop1,1+crop2:end-crop2,d3,d4,dx);
            A = squeeze(A);
            A = double(A);
            m = A;
            T = [0 0];
        elseif (length(d4)==2)
            A = data(1+crop1:end-crop1,1+crop2:end-crop2,d3,d4(1),dx);
            B = data(1+crop1:end-crop1,1+crop2:end-crop2,d3,d4(2),dx);
            A = squeeze(A);
            B = squeeze(B);
            A = double(A);
            B = double(B);
            
            [u,v] = fftalign(A,B);
            
            Ar = circshift(A,[u,v]);
            m = (Ar+B)/2;
            T = [[u v] ; [0 0]];
        else
            d4a = d4(1:floor(end/2));
            d4b = d4(floor(end/2)+1 : end);
            
            [A,T0] = align(d4a);
            [B,T1] = align(d4b);
            
            [u,v] = fftalign(A,B);
            
            Ar = circshift(A,[u,v]);
            m = (Ar+B)/2;
            T = [(ones(size(T0,1),1)*[u v] + T0) ; T1];
        end
    end
end
