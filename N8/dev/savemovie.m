function savemovie

    function savemovie(src,evt)
        %identify singleton spatial dimension
        d=size(data_plot);
        xy=(d(1:3)~=1);
        %cycle through conditions
        for d5=1:size(data_plot,5)
            %figure window & axes
            f_movie=figure('Units','Normalized','Position',[0.1 0.1 0.8 0.75]); %fix position to match aspect ratio of frames
            ha_movie=tight_subplot(1,1,0,0,0);
            %color map
            if NOTES.Cmap==1
                set(gcf,'Colormap',jet);
            elseif NOTES.Cmap==2
                set(gcf,'Colormap',cmap2);
            end
            %preallocate memory
            M(1:nframes)=getframe(gcf);
            %reset frame counter
            x=0;
            %
            if nframes>size(data_plot,4)
                n=size(data_plot,4);
            else
                n=nframes;
            end
            %cycle through time series            
            for d4=1:n
                %advance frame counter
                x=x+1;
                %get image & plot
                im=data_plot(:,:,:,d4,d5,:,:,:);
                im=squeeze(im);   
                imagesc(im);
                axis off;
                caxis(clim);
                %plot timestamps
                hold on;
                if isfield(NOTES,'FieldNames_t') && ~isempty(data_ts)
                    temp=data_ts;
                    a=NOTES.CurrentTime;
                    if isnan(a)
                        a=0;
                    end
                    %timestamps at current time
                    ix = temp(:,4) == d4+a;
                    temp=temp(ix,:);
                    %timestamps at current condition
                    if ~isempty(temp)
                        ix = temp(:,5) == d5;
                        temp=temp(ix,:);
                        %plot timestamps as scatter
                        if ~isempty(temp)
                            %remove all non-spatial dimensions (Dims 4-8)
                            temp=temp(:,1:3);
                            %remove singleton spatial dimension
                            temp=temp(:,xy);
                            %add jitter for multiple spikes
                            a=rand(size(temp));
                            a=a-0.5;
                            a=a*0.1;
                            temp=temp+a;
                            %plot coordinates
                            X=temp(:,1);
                            Y=temp(:,2);
                            scatter(X,Y,'MarkerFaceColor',[0.9 0.95 1],'MarkerEdgeColor','k','SizeData',140,'LineWidth',0.5);
                            %note: does not indicate whether 1 or multiple timestamps per bin
                        end
                    end
                end
                hold off;
                %add time labels
                t=NOTES.CurrentTime; %current time
                t=t+(d4-1); %add current time step
                t=t*NOTES.BinSize; %convert to elements
                t=t/SR; %convert to sec
                if ~isempty(NOTES.Triggers)
                    t=t-(NOTES.Triggers(1)); %subtract trigger time
                end
                l=(nframes*NOTES.BinSize)/NOTES.SampleRate;
                if l>=3600
                    t_string=[num2str(round(t/3600)) ' hr'];
                elseif l>=60
                    t_string=[num2str(round(t/60)) ' min'];
                elseif l<1
                    t_string=[num2str(round(t*1000)) ' ms'];
                else
                    t_string=[num2str(round(t)) ' s'];
                end
                if d4==1
                    pause;
                end
                pause(10/nframes);
                %save figure frame for movie
                M(x) = getframe(gcf);
            end
            %SAVE MOVIE AND CLOSE
            %file name
            string = [NOTES.SaveString '_' num2str(d5)];
            %make video
            f = VideoWriter(string,'MPEG-4');
            %set frame rate
            set(f,'FrameRate',10)
            %save .mp4 file
            open(f)
            writeVideo(f,M);
            close(f);
        end
    end