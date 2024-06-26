function [epochs, whtracking] = trackWhiskFun(trial_number,experimentID,epochs)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%%
addpath('ConvNet-master','ConvNet-master/matlab');

% load conv net coefficients
% alternatively, use train_cnn.m to train the convnet from scratch

load(fullfile('real_data','cnn_3_12_22.mat')); %Masaki- update '~.mat' as needed
funtype = 'matlab';

vid = VideoReader(fullfile(strcat('real_data/03_Videos/',experimentID,'/',trial_number,'.mp4')));
Nframes=vid.NumberOfFrames

% disp('Make sure that track_mouse_position.m was run');

%% set up image index mapping to stack
disp('setting up convnet index mapping..');
I=read(vid,1);
uim = single(I(:,:,1));

x=0;

isteps=inradius+10:size(uim,1)-inradius-10;  %steps for tiling the image
jsteps = inradius+10:size(uim,2)-inradius-10;

uim_2_ii=zeros(numel(uim),(((inradius*2)+1).^2));
% this is the mapping from linear input image pixel index to list of
% (inradius*2)+1) X (inradius*2)+1) indices that make up the tile to go
% with that (output) pixel. Once we have this mapping, we can just feed
% input_image(uim_2_ii(linear desired output pixel index,:)) into the CNN
% which is vastly faster than getting the -inradius:inradius X
% -inradius:inradius tile each time.

for i=isteps
    for j=jsteps
        x=x+1;
        ii=sub2ind(size(uim),i+meshgrid(-inradius:inradius)',j+meshgrid(-inradius:inradius)); %linear indices for that tile
        uim_2_ii(x,:)= ii(:);
    end;
end;
uim_2_ii=uim_2_ii(1:x,:); % now point to tile for each putput/predicted pixel in uim
stacksize=x;

disp('done');
%% track
skipn=1; % skip every Nth frame?
plotskip=1;
printskip=10;
ifplot=1;

skipi=[0:skipn-1];
trackframes=1:Nframes;
% we'd restrict tracking to only an interesting subset
% of frames here (i.e. mous epresent in the right distance to the
% target to be interesting etc.)

whtracking=[];
whtracking.intersect_mean=[];
whtracking.intersect_im=[];
whtracking.lines=[];
whtracking.mean_angle=nan(1,Nframes);

c=0;  se = strel('ball',3,3);
se_big = strel('ball',10,10);
f_big=fspecial('disk', 10);

lasttic=cputime-10;
for fnum=trackframes
    c=c+1;
    nose_x=round(epochs.nosedist_track(1,fnum));


    I=read(vid,fnum);
    Icrop=I(170:450,10:420,1);

    if     nose_x>50 & nose_x<400 % do some crude filtering to restrict tracking to useful frames

        if mod(c,printskip)==0
            fps=printskip/(cputime-lasttic);
            fprintf('%d/%d frames (%d%%) (%f fps) \n',c,round(numel(trackframes)/skipn),round(((c*skipn)/numel(trackframes))*100),fps);
            lasttic=cputime;
        end;

        I=read(vid,fnum);
        Icrop=I(170:450,10:420,1);

        % find nose Y coord
        % so far we only tracked x coord, now just track the darkest ares
        % in y-direction to find y coord
        %nose_y_detect = conv2(double(I(180:end,[-15:15]+nose_x+0,1)),f_big,'same')<40;
        %%plot(mean(nose_y_detect'));
        %m=mean(nose_y_detect'); m=m./sum(m);
        %epochs.nosedist_track(2,fnum) =min(find(cumsum(m)>.5));
        nose_y=epochs.nosedist_track(2,fnum);

        uim = single(I(:,:,1)); % input image

        % make tiles to feed into CNN
        %  use pre-computed tile indices
        %  and select which ones to use here - restrict tracking to radius
        %  around nose pos.
        [isteps,jsteps] = meshgrid(inradius+10:size(uim,1)-inradius-10, inradius+10:size(uim,2)-inradius-10);
        use_stack =  sqrt((nose_x-jsteps(:)+inradius*2).^2+(nose_y-isteps(:)+inradius*2).^2)<120 ;

        pred=ones(stacksize,2); % set up prediction output
        runon=find(use_stack);

        ii=uim_2_ii(runon,:);
        % reshape images into inradious*2 X inradious*2 X outputsize stack
        imstack = ((reshape( uim(ii'), (inradius*2)+1,(inradius*2)+1,numel(runon))./255)-0.5);  % re-normalize image range
        pred(runon,:) = cnnclassify(layers, weights, params, imstack, funtype);

        isteps_lin= inradius+10:size(uim,1)-inradius-10; %just as output size computation
        jsteps_lin = inradius+10:size(uim,2)-inradius-10;
        iout=flipud(rot90(reshape(pred(:,2)',numel(jsteps_lin),numel(isteps_lin)))); % re-assemble output image


        % Even though the CNN should have learned to not label pieces of
        % fur close to the head, running a 2nd cleanup step here is nice
        % and cheap. Most importantly, we could easily run this step with a larger
        % neighborhood size if needed and train the CNN with an inradius
        % that might be a bit too small for avoiding fur labelling but good
        % enough for vibrissa tracking.
        rem_mouse = (conv2(double(uim(inradius+10:end-inradius-10,inradius+10:end-inradius-10)<100),f_big,'same')<.2);

        % identify rough whisker angle via hough transform
        Imask=iout.*0; % as before, restrict the transform to an area arounf the nose
        try
            j=nose_x;
            i=nose_y;
            Imask(i, j)=Imask(i, j)+1;
        end;
        if sum(Imask(:))>0
            f=fspecial('disk',100); f=f./sum(f(:));
            Imask=conv2(Imask,f,'same');
            Imask=Imask./max(Imask(:));
        end;

        Ihough = ((Imask.*(1-iout))>0.2).*rem_mouse; % threshold CNN output and clean up for input to hough transform

        [H,theta,rho] = hough(Ihough);
        P = houghpeaks(H,20,'threshold',ceil(0.01*max(H(:)))); % parameters might need tweaking here
        lines = houghlines(Ihough,theta,rho,P,'FillGap',4,'MinLength',6); % and here

        %save some per-frame info for later
        whtracking.intersect_mean(fnum) = mean(mean(Ihough(:, round(epochs.gappos)+[-15:5])));
        whtracking.intersect_im=Ihough(:, round(epochs.gappos)+[-15:5]);
        whtracking.lines{fnum}=lines;

        % run a very crude mean whisker angle computation
        if numel(lines)>0
            whtracking.mean_angle(fnum)=mean([lines.rho]);
        end;

        if ifplot & mod(c,plotskip)==0
            clf;
            subplot(221);
            imagesc(flipud(uim));daspect([1 1 1]);

            subplot(222);
            hold on;
            imagesc((uim(isteps_lin,jsteps_lin)./1000)+(1-iout)./5);
            colormap(gray); daspect([1 1 1]);
            plot(nose_x, nose_y,'ro');
            for k = 1:length(lines)
                xy = [lines(k).point1; lines(k).point2];
                plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
            end
            axis tight;

            subplot(2,2,[3 4]);
            hold on;
            plot( epochs.nosedist_track(1,1:fnum),'k');
            text(0,100,'Nose x position','color','k');

            plot(-100+whtracking.intersect_mean.*10000,'b');%EDIT changed to blue
            text(0,-112,'Whisker/platform intersections','color','b'); %EDIT: moved text line so grouped correctly I think?

            plot( conv(whtracking.mean_angle,[1 1 1]./3,'same'),'r');
            text(0,10,'Whisking pattern','color','r');

            drawnow;
        end;

    end;

end;


end