clearvars   
area_string = 'S1';
load([area_string,'_data.mat']) % Load data from responsive_cells_script.m

%% If want to use whole sensory period run this and skip next section
new_baseline_frames = data{1}.frames.baseline;

for dsetID = 1:length(data)
    new_sensory_frames{dsetID} = data{dsetID}.frames.sensory;
end

%% average dF/F across baseline and sensory periods for each trial

for dsetID = 1:length(data)
    for type = 1:4

        baseline_mean{dsetID,type} = nanmean(data{dsetID}.nolaser.dff{type}(new_baseline_frames(1):new_baseline_frames(2),:,:),1);
        sensory_mean{dsetID,type} = nanmean(data{dsetID}.nolaser.dff{type}(new_sensory_frames{dsetID}(1):new_sensory_frames{dsetID}(2),:,:),1);

        baseline_mean_sensorylaser{dsetID,type} = nanmean(data{dsetID}.sensorylaser.dff{type}(new_baseline_frames(1):new_baseline_frames(2),:,:),1);
        sensory_mean_sensorylaser{dsetID,type} = nanmean(data{dsetID}.sensorylaser.dff{type}(new_sensory_frames{dsetID}(1):new_sensory_frames{dsetID}(2),:,:),1);

        sensory_mean_minus{dsetID,type} = sensory_mean{dsetID,type} - baseline_mean{dsetID,type};
        sensory_mean_laser_minus{dsetID,type} = sensory_mean_sensorylaser{dsetID,type} - baseline_mean_sensorylaser{dsetID,type};

        temp = size(sensory_mean_minus{dsetID,type});
        sensory_mean_minus{dsetID,type} = reshape(sensory_mean_minus{dsetID,type},[temp(2:end) 1]);

        temp_laser = size(sensory_mean_laser_minus{dsetID,type});
        sensory_mean_laser_minus{dsetID,type} = reshape(sensory_mean_laser_minus{dsetID,type},[temp_laser(2:end) 1]);

        clear temp temp_laser
    end
end


%% Loop through all data sets and all cells and calculate DI and CI for no laser
% and sensory laser conditions.

nperm = 100; 
plot_flag=0; 

for dsetID = 1:length(data)
    for cellID = 1:size(sensory_mean_minus{dsetID,1},1)

        %DI - CALC USING T1 Hit+miss vs Blank CR+FA
        dataA = cat(1,sensory_mean_minus{dsetID,1}(cellID,:)',sensory_mean_minus{dsetID,2}(cellID,:)');
        dataB = cat(1,sensory_mean_minus{dsetID,3}(cellID,:)',sensory_mean_minus{dsetID,4}(cellID,:)');
        labels = cat(1, ones(length(dataA),1),ones(length(dataB),1)*2);
        [data{dsetID}.nolaser.DI_sensory(cellID,1),data{dsetID}.nolaser.DIpval_sensory(cellID,1),...
            data{dsetID}.nolaser.DI_newsig(cellID,1)] = selectivityIndex([dataA;dataB],labels,nperm,plot_flag);
        clear dataA dataB labels

        %DI SENSORY LASER - CALC USING T1 Hit+miss vs Blank CR+FA
        dataA = cat(1,sensory_mean_laser_minus{dsetID,1}(cellID,:)',sensory_mean_laser_minus{dsetID,2}(cellID,:)');
        dataB = cat(1,sensory_mean_laser_minus{dsetID,3}(cellID,:)',sensory_mean_laser_minus{dsetID,4}(cellID,:)');
        labels = cat(1, ones(length(dataA),1),ones(length(dataB),1)*2);
        [data{dsetID}.sensorylaser.DI(cellID,1),data{dsetID}.sensorylaser.DIpval(cellID,1), ...
            data{dsetID}.sensorylaser.DI_newsig(cellID,1)] = selectivityIndex([dataA;dataB],labels,nperm,plot_flag);
        clear dataA dataB labels

        % CI - NO LASER [SENSORY PERIOD]
        dataA = cat(1,sensory_mean_minus{dsetID,1}(cellID,:)',sensory_mean_minus{dsetID,4}(cellID,:)');
        dataB = cat(1,sensory_mean_minus{dsetID,2}(cellID,:)',sensory_mean_minus{dsetID,3}(cellID,:)');
        labels = cat(1, ones(length(dataA),1),ones(length(dataB),1)*2);
        [data{dsetID}.nolaser.CI_sensory(cellID,1),data{dsetID}.nolaser.CIpval_sensory(cellID,1), ...
            data{dsetID}.nolaser.CI_newsig(cellID,1)] =selectivityIndex([dataA;dataB],labels,nperm,plot_flag);
        clear dataA dataB labels

        % CI - SENSORY LASER
        dataA = cat(1,sensory_mean_laser_minus{dsetID,1}(cellID,:)',sensory_mean_laser_minus{dsetID,4}(cellID,:)');
        dataB = cat(1,sensory_mean_laser_minus{dsetID,2}(cellID,:)',sensory_mean_laser_minus{dsetID,3}(cellID,:)');
        labels = cat(1, ones(length(dataA),1),ones(length(dataB),1)*2);
        [data{dsetID}.sensorylaser.CI(cellID,1),data{dsetID}.sensorylaser.CIpval(cellID,1), ...
            data{dsetID}.sensorylaser.CI_newsig(cellID,1)] =selectivityIndex([dataA;dataB],labels,nperm,plot_flag);
        clear dataA dataB labels

    end
end

%% Save new data structure that now also contains DI and CI values

save([area_string,'_wROC.mat'],'data','experimentID',...
    'sensory_mean_minus','sensory_mean_laser_minus',...
    'new_baseline_frames','new_sensory_frames')
