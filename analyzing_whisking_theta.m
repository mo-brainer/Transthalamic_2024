%% Complement to analyzing_whisking_092822, outputs "theta angle"
addpath('C:\Users\')
clearvars
experimentID = {' '}; % experiments
type = 1; % change this for different trial types
start_frame =  ; % adjust start and end frame for particular epoch
end_frame =  ;   % frames 
%%
control_whisk_all = [];
delaylaser_whisk_all = [];  % laser_whisk_all = [];

for dsetID =1:length(experimentID)
    temp = load(strcat('real_data/04_Results/',experimentID{dsetID},'/',experimentID{dsetID},'_whisker_THETA.mat'),'control_new','delaylaser_new');
     control_whisk_all = cat(2,control_whisk_all,temp.control_new{type}.mean_angle_conv(start_frame:end_frame,:));
    delaylaser_whisk_all = cat(2,delaylaser_whisk_all,temp.laser_new{type}.mean_angle_conv(start_frame:end_frame,:));
end

%% FOR CONTROL TRIALS
for trialID = 1:size(control_whisk_all,2)

  %  figure;
   % plot(control_whisk_all(:,trialID),'k');   %commented out to speed up
    hold on

    % find and plot peaks
    [peaks,idx]=findpeaks(control_whisk_all(:,trialID));
  %  plot(idx,peaks,'*r')                     %commented out to speed up

    % find and plot valleys (for finding amplitude)
    invertedY = max(control_whisk_all(:,trialID)) - control_whisk_all(:,trialID);
    [~, idx_v] = findpeaks(invertedY);
    valleys= control_whisk_all(idx_v,trialID);
   % plot(idx_v,valleys,'og')           %commented out to speed up
    title (num2str(trialID))

    %a catch for cases when first peak is before first valley. If so make first data point the first valley
    if idx(1)<idx_v(1)
        valleys=cat(1,control_whisk_all(1,trialID),valleys);
        idx_v=cat(1,1,idx_v);
    end

    % calculating amplitude of peaks from previous valleys
    amplitude = peaks - valleys(1:size(peaks,1)); %ignores possible valley after final peak so that peaks and valleys arrays are same size

    %organize output
    control_whisk_data{type}.idx{trialID}=idx;
    control_whisk_data{type}.amplitude{trialID}=amplitude;

    clear idx peaks valleys amplitude idx_v invertedY

end
%% FOR LASER TRIALS
for trialID = 1:size(delaylaser_whisk_all,2)

  %  figure;
   % plot(laser_whisk_all(:,trialID),'k');   %commented out to speed up
    hold on

    % find and plot peaks
    [peaks,idx]=findpeaks(delaylaser_whisk_all(:,trialID));
   % plot(idx,peaks,'*r')                    %commented out to speed up

    % find and plot valleys (for finding amplitude)
    invertedY = max(delaylaser_whisk_all(:,trialID)) - delaylaser_whisk_all(:,trialID);
    [~, idx_v] = findpeaks(invertedY);
    valleys= delaylaser_whisk_all(idx_v,trialID);
  %  plot(idx_v,valleys,'og')             %commented out to speed up
    title (num2str(trialID))

    %a catch for cases when first peak is before first valley. If so make first data point the first valley
    if idx(1)<idx_v(1)
        valleys=cat(1,delaylaser_whisk_all(1,trialID),valleys);
        idx_v=cat(1,1,idx_v);
    end

    % calculating amplitude of peaks from previous valleys
    amplitude = peaks - valleys(1:size(peaks,1)); %ignores possible valley after final peak so that peaks and valleys arrays are same size

    %organize output
    delaylaser_whisk_data{type}.idx{trialID}=idx;
    delaylaser_whisk_data{type}.amplitude{trialID}=amplitude;

    clear idx idx_v peaks valleys amplitude invertedY
end

%% To extract data
% Extract 'theta' of each whisk in variable 'control_whisk_data' or 'laser_whisk_data'
% amplitude variable, per "type" (1=hit, 2=miss, 3=CR, 4=FA)
%set percentage or threshold for counting as whisk (vs noise in frame avg)
% perc = 75; %ATTN: can edit the percentage for now set to find 75 percentile
% 
% % find percentile of amplitudes
% P = prctile(amps,perc);

%find "upticks" with amplitude values that are above the given percentile