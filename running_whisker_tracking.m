%
% Associated functions/codes:
% trackWhiskFun.m
% plotWhiskFun.m
% fixNosePosFun.m
%
% NOTES:
% Code assumes you're working in whisker_tracking-master folder,
% which is itself located inside the "main" folder that contains the
% rest of the analysis code etc
%
% 'trialtype_order_suite2p.xls' should be located in this "main" folder
% with the rest of our analysis code. That is, it should be saved in the
% folder that contains the folder whisker_tracking-master, but should not
% be inside whisker_tracking-master
%
% For each dataset, create 2 folder with name of dataset ID in:
%   whisker_tracking-master/real_data/03_Videos, and
%   whisker_tracking-master/real_data/04_Results.
%% 
%EDIT: change to path to where matlab functions are stored
addpath('C:\Users\')

clearvars
experimentID = ' '; % individual experiment ID only
%% For each trial type, read in corresponding trial numbers from spreadsheet

num_trials = table2array(readtable('../trialtype_order_suite2p.xlsx',...
    'Sheet',experimentID,'Range','B2:B25'));
vid_order = table2array(readtable('../trialtype_order_suite2p.xlsx',...
    'Sheet',experimentID,'Range','O2:AN25','TextType','string',...
    'TreatAsMissing','N/A','ReadVariableNames',false));

for ii = 1:length(num_trials)
    whisker_vid_trials{ii}=vid_order(ii,1:num_trials(ii));
end
%% Run, looping through each trial and each trial type
control_cond = [1,2,7,8,13,14,19,20];
delaylaser_cond =[3,4,9,10,15,16,21,22];
laser_cond = [5,6,11,12,17,18,23,24];

for cond = 1:length(num_trials)
    for trial_idx = 1:length(whisker_vid_trials{cond})

        epochs(trial_idx)= fixNosePosFun(whisker_vid_trials{cond}(trial_idx),experimentID);
        [epochs(trial_idx), whtracking(trial_idx)] = trackWhiskFun(whisker_vid_trials{cond}(trial_idx),experimentID,epochs(trial_idx));
        plotWhiskFun(whisker_vid_trials{cond}(trial_idx),experimentID,whtracking(trial_idx))

        whisk_data{cond}.mean_angle_conv(:,trial_idx) = conv(whtracking(trial_idx).mean_angle,[1 1 1]./3,'same');
        whisk_data{cond}.intersect_mean(:,trial_idx) = whtracking(trial_idx).intersect_mean;
        whisk_data{cond}.epochs(trial_idx) = epochs(trial_idx);
        whisk_data{cond}.lines(:,trial_idx) = whtracking(trial_idx).lines;%EDIT: check
        whisk_data{cond}.intersect_im(:,:,trial_idx) = whtracking(trial_idx).intersect_im;

    end
end

control_whisk = whisk_data(control_cond);
delaylaser_whisk = whisk_data(delaylaser_cond);
laser_whisk = whisk_data(laser_cond);

%save as mat so can read in whisker tracking info to analysis script
save(strcat('real_data/04_Results/',experimentID,'/',experimentID,'_whisker.mat'),'control_whisk','delaylaser_whisk','laser_whisk')
