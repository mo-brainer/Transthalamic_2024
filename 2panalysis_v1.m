%% Script for 2p analysis
%% load datasets (after initial organization and exps processed in organize_data_script.m then organized in responsive_cells_script.m
clearvars
area_string = 'S1';
load([area_string,'_7data.mat'])
%% Calculating average dF/F across trials
for dsetID = 1:length(data)
    for j = 1:8
        for i = 1:size(data{dsetID}.dff_all,2)
            [data{dsetID}.nolaser.avg_dff{j}(:,i),data{dsetID}.nolaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.nolaser.dff{j},i);
            [data{dsetID}.sensorylaser.avg_dff{j}(:,i),data{dsetID}.sensorylaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.sensorylaser.dff{j},i);
            [data{dsetID}.delaylaser.avg_dff{j}(:,i),data{dsetID}.delaylaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.delaylaser.dff{j},i);
        end
    end
end

%% Calculating area under the curve during either delay or sensory period
for dsetID = 1:length(data)
    for type = 1:8  %1:8
        for jj = 1 : size(data{dsetID}.dff_all,2)
            for trial = 1 : size(data{dsetID}.nolaser.dff{type},3)% no laser trials
                baseline_AUC{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.nolaser.dff{type}(:,jj,trial))',data{dsetID}.frames.baseline);
                sensory_AUC{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.nolaser.dff{type}(:,jj,trial))',data{dsetID}.frames.sensory);% sensory period 47 76 but 48-77 for 1106S2
                delay_AUC{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.nolaser.dff{type}(:,jj,trial))',data{dsetID}.frames.delay);% sensory period 47 76 but 48-77 for 1106S2
            end
            for trial = 1 : size(data{dsetID}.sensorylaser.dff{type},3) % laser in sensory period trials
                baseline_AUC_sensorylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.sensorylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.baseline);
                sensory_AUC_sensorylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.sensorylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.sensory);
            end
            for trial = 1 : size(data{dsetID}.delaylaser.dff{type},3) % laser in delay period
                baseline_AUC_delaylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.delaylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.baseline);
                delay_AUC_delaylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.delaylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.delay);
            end
        end
        % subtract AUC during baseline period
        sensory_AUC_minus{dsetID,type} = sensory_AUC{dsetID,type} - baseline_AUC{dsetID,type}; % area under sensory no laser minus area under baseline no laser
        sensory_AUC_laser_minus{dsetID,type} = sensory_AUC_sensorylaser{dsetID,type} - baseline_AUC_sensorylaser{dsetID,type}; %area under sensory w/ sensory laser minus area under baseline w/ sensory laser
        delay_AUC_minus{dsetID,type} = delay_AUC{dsetID,type} - baseline_AUC{dsetID,type}; % area under delay no laser minus area under baseline no laser
        delay_AUC_laser_minus{dsetID,type} = delay_AUC_delaylaser{dsetID,type} - baseline_AUC_delaylaser{dsetID,type}; %area under delay w/ delay laser minus area under baseline w/ delay laser
    end
end
%% Responsive cells include responsive for no laser and laser (any trial type) 
%EDIT!!
for dsetID = 1:length(experimentID)
    data{dsetID}.resp_cellIDs_both = find(sum(cat(1,data{dsetID}.nolaser.is_resp,data{dsetID}.sensorylaser.is_resp),1) > 0);
end
%% Creating new variables with only responsive cells
for dsetID =  1:length(data)
    % sensory AUC - no laser
    sensory_AUC_minus_resp(dsetID,:) = cellfun(@(x) x(data{dsetID}.resp_cellIDs_both,:),...
        sensory_AUC_minus(dsetID,:),'UniformOutput',false);
    % sensory AUC - sensory laser
    sensory_AUC_laser_minus_resp(dsetID,:) = cellfun(@(x) x(data{dsetID}.resp_cellIDs_both,:),...
        sensory_AUC_laser_minus(dsetID,:),'UniformOutput',false);

    % delay AUC - no laser
    delay_AUC_minus_resp(dsetID,:) = cellfun(@(x) x(data{dsetID}.resp_cellIDs_both,:),...
        delay_AUC_minus(dsetID,:),'UniformOutput',false);
    % delay AUC - delay laser
   delay_AUC_laser_minus_resp(dsetID,:) = cellfun(@(x) x(data{dsetID}.resp_cellIDs_both,:),...
        delay_AUC_laser_minus(dsetID,:),'UniformOutput',false);

end

%% Reorganizing the way matrices of AUC and dFF values are structured

% avg dff: aligning time courses across dataset
%all
[aligned,aligned_sensory_laser,aligned_delay_laser, sz_baseline] = alignDFFnew(data);

%only responsive
 [aligned_resp,aligned_sensory_laser_resp,aligned_delay_laser_resp, sz_baseline_resp] = alignDFFonlyResponsiveNew(data);%EDIT: check sz_baseline same for resp and not resp

% organizing area under curve data
% SENSORY
% all
sensory_AUC_minus_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),sensory_AUC_minus,'UniformOutput',false));
sensory_AUC_laser_minus_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),sensory_AUC_laser_minus,'UniformOutput',false));

% only responsive
sensory_AUC_minus_resp_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),sensory_AUC_minus_resp,'UniformOutput',false));
sensory_AUC_laser_minus_resp_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),sensory_AUC_laser_minus_resp,'UniformOutput',false));

%DELAY
% all
delay_AUC_minus_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),delay_AUC_minus,'UniformOutput',false));
delay_AUC_laser_minus_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),delay_AUC_laser_minus,'UniformOutput',false));

% only responsive
delay_AUC_minus_resp_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),delay_AUC_minus_resp,'UniformOutput',false));
delay_AUC_laser_minus_resp_ALL = cell2mat(cellfun(@(x) mean(x,2,'omitnan'),delay_AUC_laser_minus_resp,'UniformOutput',false));


%reorganize IDs of responsive cells so # reflects index relative to all datasets
% EDIT
resp_cellIDs_all =[];
cellID_offset = 0;

for dsetID=1:length(data)
    resp_cellIDs_all = cat(1,resp_cellIDs_all,data{dsetID}.resp_cellIDs_both' + cellID_offset);
    cellID_offset = cellID_offset + size(data{dsetID}.dff_all,2);
end
 

%% plot heat map of average dF/F for each cell, sorted by activity after
% texture onset
% plot example responses: ylim([0 30]); xlim([10 120]);
 color_limit = [-1 4]; %ATTN: adjust color limits
% color_limit = [-1 2];
color_map = "parula"; %ATTN: change color map (examples of matlab color maps "jet", "parula", "turbo" ..)

% sorting by AUC sensory minus baseline for no laser HIT trials
[~,I_resp]=sort(sensory_AUC_minus_resp_ALL(:,1),'descend');
[~,I]=sort(sensory_AUC_minus_ALL(:,1),'descend');
title_strings = {'Hit','Miss','CR','FA'};

% ONLY RESPONSIVE CELLS - no laser

for ii = 1:4
    figure
  foo=squeeze(aligned_resp(:,:,ii))';    %zscored
%   foo=squeeze(aligned_resp_z(:,:,ii))';    %zscored
    plotHeatMapNew(foo(I_resp,:),sz_baseline_resp,color_limit,resp_cellIDs_all(I_resp),color_map)
    clear foo
    title(['no laser: ',title_strings{ii},' , only responsive cells'])
%     saveas(gcf,['heatmap_nolaser_',title_strings{ii},'_resp_',area_string,'.jpg'])
end

% ONLY RESPONSIVE CELLS - sensory laser
for ii = 1:4 
    figure;
         foo=squeeze(aligned_sensory_laser_resp(:,:,ii))'; % zscored
%         foo=squeeze(aligned_sensory_laser_resp_z(:,:,ii))'; % zscored
    plotHeatMapNew(foo(I_resp,:),sz_baseline_resp,color_limit,resp_cellIDs_all(I_resp),color_map)
    clear foo
    title(['sensory laser: ',title_strings{ii},' , only responsive cells'])
%         saveas(gcf,['heatmap_sensorylaser_',title_strings{ii},'_resp_',area_string,'.jpg'])

end

% ONLY RESPONSIVE CELLS - delay laser
for ii = 1:4
    figure;
       foo=squeeze(aligned_delay_laser_resp(:,:,ii))'; % zscored
%         foo=squeeze(aligned_delay_laser_resp_z(:,:,ii))'; % zscored

%     foo=zscore(squeeze(aligned_delay_laser_resp(:,:,ii)))'; % zscored
    plotHeatMapNew(foo(I_resp,:),sz_baseline_resp,color_limit,resp_cellIDs_all(I_resp),color_map)
    clear foo
    title(['delay laser: ',title_strings{ii},' , only responsive cells'])
%         saveas(gcf,['heatmap_delaylaser_',title_strings{ii},'_resp_',area_string,'.jpg'])

end

% xlim([0 120]);
% ylim([0 12]);

% ALL CELLS - no laser
for ii = 1:4
    figure;
            foo=squeeze(aligned(:,:,ii))'; % zscored
%             foo=squeeze(aligned_z(:,:,ii))'; % zscored
    plotHeatMapNew(foo(I,:),sz_baseline,color_limit,I,color_map)
    clear foo
    title(['no laser: ',title_strings{ii}])
%         saveas(gcf,['heatmap_nolaser_',title_strings{ii},'_all_',area_string,'.jpg'])

end

% ALL CELLS - sensory laser
for ii = 1:4
    figure;
        foo=squeeze(aligned_sensory_laser(:,:,ii))'; %zscored
%         foo=squeeze(aligned_sensory_laser_z(:,:,ii))'; %zscored

    plotHeatMapNew(foo(I,:),sz_baseline,color_limit,I,color_map)
    clear foo
    title(['sensory laser: ',title_strings{ii}])
%         saveas(gcf,['heatmap_sensorylaser_',title_strings{ii},'_all_',area_string,'.jpg'])

end

% ALL CELLS - delay laser
for ii = 1:4
    figure;
         foo=squeeze(aligned_delay_laser(:,:,ii))'; %zscored
%         foo=squeeze(aligned_delay_laser_z(:,:,ii))'; %zscored

    plotHeatMapNew(foo(I,:),sz_baseline,color_limit,I,color_map)
    clear foo
    title(['delay laser: ',title_strings{ii}])
%         saveas(gcf,['heatmap_delaylaser_',title_strings{ii},'_all_',area_string,'.jpg'])

end
%% plot average traces - no laser, sensory laser, delay laser

dsetID = 4; 
for cellID = 37   

    figure
    for trial_type_ID =1:8
        subplot(4,2,trial_type_ID)
   %     plotAvgDffTracesNew(data{dsetID}.nolaser,[52 148 186]./255,cellID,trial_type_ID) % no laser color red[204 0 0]/255
        title(data{1}.trial_type_order(trial_type_ID))
  %      hold on
        plotAvgDffTracesNew(data{dsetID}.sensorylaser,[204 0 0]/255,cellID,trial_type_ID)% sensory laser color darkblue[51 51 255]/255
   %     plotAvgDffTracesNew(data{dsetID}.delaylaser,[255 153 0]/255,cellID,trial_type_ID)% delay laser pink [0.9, 0, 0.5]
        xticks([0:50:200]);
        set(gca, ...
            'FontName'    ,'Helvetica', ...
            'FontSize'    , 8        , ...
            'Box'         , 'off'     , ...
            'TickDir'     , 'out'     , ...
            'TickLength'  , [.02 .02] , ...
            'XMinorTick'  , 'off'      , ...
            'YMinorTick'  , 'off'      , ...
            'YGrid'       , 'off'      , ...
            'XColor'      , [.3 .3 .3], ...
            'YColor'      , [.3 .3 .3], ...
            'LineWidth'   , 1         );
        hold on
        % lines marking start of baseline, sensory and delay periods
        %baseline start
        x00 = [data{dsetID}.frames.baseline(1) data{dsetID}.frames.baseline(1)];    %line at frame 76
        y00 = [-10 -1];   %spans length of y-axis on graph
        DL00 = line(x00,y00, 'Color','k');  %draw red line where delay laser starts
        DL00.Annotation.LegendInformation.IconDisplayStyle = 'off';
        %baseline stop
        x0 = [data{dsetID}.frames.baseline(2) data{dsetID}.frames.baseline(2)];    %line at frame 76
        y0 = [-10 -1];   %spans length of y-axis on graph
        DL0 = line(x0,y0, 'Color','k');  %draw red line where delay laser starts
        DL0.Annotation.LegendInformation.IconDisplayStyle = 'off';
        %sensory
        x = [data{dsetID}.frames.sensory(1) data{dsetID}.frames.sensory(1)];    %line at frame 76
        y = [-10 -1];   %spans length of y-axis on graph
        DL1 = line(x,y, 'Color','k');  %draw red line where delay laser starts
        DL1.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % hold on
        %delay start
        x = [data{dsetID}.frames.delay(1) data{dsetID}.frames.delay(1)];    %line at frame 76
        y = [-10 -1];   %spans length of y-axis on graph
        DL2 = line(x,y, 'Color','k');
        DL2.Annotation.LegendInformation.IconDisplayStyle = 'off';
        % hold on
        %delay end
        x = [data{dsetID}.frames.delay(2) data{dsetID}.frames.delay(2)];    %line at frame 76
        y = [-10 -1];   %spans length of y-axis on graph
        DL3 = line(x,y, 'Color','k');
        DL3.Annotation.LegendInformation.IconDisplayStyle = 'off';
        ylim([-3 10]); %[-3 10]
        %  ylim([-1 10]);
        xlim([0 200]);

    end
    %  legend({'No laser','Sensory laser','Delay laser'})
    sgtitle(['cellID ',num2str(cellID),' dset=',num2str(dsetID)])
    saveas(gcf,['dset',num2str(dsetID),'_cell',num2str(cellID),'.jpg'])

end