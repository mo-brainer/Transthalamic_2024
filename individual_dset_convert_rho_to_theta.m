%% THIS CODE OUTPUTS ALL TRIALS REGARDLESS OF EXCEL SPREADSHEET
addpath('C:\Users\')
clearvars
experimentID = ' '; %ATTN, individual experiment ID only
type = 1; % change for each trial type

%%
temp = load(strcat('real_data/04_Results/',experimentID,'/',experimentID,'_whisker_full.mat'),'control_whisk','laser_whisk','delaylaser_whisk');

%% control
Nframes = size(temp.control_whisk{1,1}.lines,1);
Ntrial=size(temp.control_whisk{1,1}.lines,2);

for trial = 1: Ntrial
    for fnum = 1:Nframes
        % run a very crude mean whisker angle computation
        if numel(temp.control_whisk{type}.lines{fnum,trial})>0
            control_new.mean_angle(fnum,trial)=mean([temp.control_whisk{type}.lines{fnum,trial}.theta]);
        end
    end
            control_new.mean_angle_conv(:,trial) = conv(control_new.mean_angle(:,trial),[1 1 1]./3,'same');

end



%% EDIT: PLOT CONTROL TRIALS
for trial = 1:Ntrial
    figure;
    plot(control_new.mean_angle_conv(:,trial),'r');
%     ylim([0 360])
%     ylabel("Pixel")
    xlabel("t (timeframe)")
    title(['Whisking pattern of CONTROL trial ', num2str(trial),' (not actual trial number)'])
end

clear Ntrial
%% laser
Nframes = size(temp.delaylaser_whisk{1,1}.lines,1);  % Nframes = size(temp.laser_whisk{1,1}.lines,1);
Ntrial=size(temp.delaylaser_whisk{1,1}.lines,2);     % Ntrial=size(temp.laser_whisk{1,1}.lines,2);

for trial = 1: Ntrial
    for fnum = 1:Nframes
        % run a very crude mean whisker angle computation
        if numel(temp.delaylaser_whisk{type}.lines{fnum,trial})>0
            delaylaser_new.mean_angle(fnum,trial)=mean([temp.delaylaser_whisk{type}.lines{fnum,trial}.theta]);
        end
    end
     delaylaser_new.mean_angle_conv(:,trial) = conv(delaylaser_new.mean_angle(:,trial),[1 1 1]./3,'same');

end

%% EDIT: PLOT LASER TRIALS
for trial = 1:Ntrial
    figure;
    plot(laser_new.mean_angle_conv(:,trial),'r');
%     ylim([0 360])
%     ylabel("Pixel")
    xlabel("t (timeframe)")
    title(['Whisking pattern of LASER trial ', num2str(trial),' (not actual trial number)'])
end
%% Saving

save(strcat('real_data/04_Results/',experimentID,'/',experimentID,['_whisker_THETA.mat']),'control_new','delaylaser_new')
