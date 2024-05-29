%% New method for analyzing whisking data
% After getting _whisker_full.mat, creates whisker tracking output and
% analyses peaks and troughs for whisk envelope "amplitude" and #whisks
%% Notes
% EDIT: setting type of trial - only looking at one trial type at 
% a time. I.e. for now type =1; meaning only hit trials
% Note: using convolved trace
%%
addpath('C:\Users\')
clearvars
experimentID = {'0113S1'}; %A individual experiment ID only
type = 1; % ATTN: Change for different trial types 1=hit,2=miss,3=CR,4=FA
start_frame = ;
end_frame = ;
%%
control_whisk_all = [];
laser_whisk_all = [];
% loading '_whisker_full.mat' for sensory laser
for dsetID =1:length(experimentID)
    temp = load(strcat('real_data/04_Results/',experimentID{dsetID},'/',experimentID{dsetID},'_whisker_full.mat'),'control_whisk','laser_whisk');
    control_whisk_all = cat(2,control_whisk_all,temp.control_whisk{type}.mean_angle_conv(start_frame:end_frame,:));
    laser_whisk_all = cat(2,laser_whisk_all,temp.laser_whisk{type}.mean_angle_conv(start_frame:end_frame,:));
end

%% FOR CONTROL TRIALS
for trialID = 1:size(control_whisk_all,2)

    %figure;
    plot(control_whisk_all(:,trialID),'k');
    hold on

    % find and plot peaks
    [peaks,idx]=findpeaks(control_whisk_all(:,trialID));
    plot(idx,peaks,'*r')

    % find and plot valleys (for finding amplitude)
    invertedY = max(control_whisk_all(:,trialID)) - control_whisk_all(:,trialID);
    [~, idx_v] = findpeaks(invertedY);
    valleys= control_whisk_all(idx_v,trialID);
    plot(idx_v,valleys,'og')
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
for trialID = 1:size(laser_whisk_all,2)

    %figure;
    plot(laser_whisk_all(:,trialID),'k');
    hold on

    % find and plot peaks
    [peaks,idx]=findpeaks(laser_whisk_all(:,trialID));
    plot(idx,peaks,'*r')

    % find and plot valleys (for finding amplitude)
    invertedY = max(laser_whisk_all(:,trialID)) - laser_whisk_all(:,trialID);
    [~, idx_v] = findpeaks(invertedY);
    valleys= laser_whisk_all(idx_v,trialID);
    plot(idx_v,valleys,'og')
    title (num2str(trialID))

    %a catch for cases when first peak is before first valley. If so make first data point the first valley
    if idx(1)<idx_v(1)
        valleys=cat(1,laser_whisk_all(1,trialID),valleys);
        idx_v=cat(1,1,idx_v);
    end

    % calculating amplitude of peaks from previous valleys
    amplitude = peaks - valleys(1:size(peaks,1)); %ignores possible valley after final peak so that peaks and valleys arrays are same size

    %organize output
    laser_whisk_data{type}.idx{trialID}=idx;
    laser_whisk_data{type}.amplitude{trialID}=amplitude;

    clear idx idx_v peaks valleys amplitude invertedY
end
