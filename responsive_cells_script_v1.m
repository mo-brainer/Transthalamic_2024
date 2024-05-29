%% Script to find "responsive cell".
% Mean dF/F during sensory period (29 frames) minus mean baseline, Wilcoxon p<0.05
% USE BEFORE using most recent version of "analyis_laser_vs_nolaser...
% saves responsive cell IDs in "data" structure that is read into the
% 2p analysis script

%% load datasets (which have already gone through initial organization using "organize_data_script.m")
clearvars
experimentID = {'S2'}; 
for dsetID = 1:length(experimentID)
     temp = load([experimentID{dsetID},'_data.mat'],'d'); 
    data{dsetID} = temp.d;
    clear temp
end

%% NEW: SET NUMBER OF TRIAL TYPES USED TO SELECT RESPONSIVE CELLS
number_types = 4;

%% Calculating average dF/F across trials - for use in determining responsive cells below
for dsetID = 1:length(data)
    for j = 1:number_types
        for i = 1:size(data{dsetID}.dff_all,2)
            [data{dsetID}.nolaser.avg_dff{j}(:,i),data{dsetID}.nolaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.nolaser.dff{j},i);
            [data{dsetID}.sensorylaser.avg_dff{j}(:,i),data{dsetID}.sensorylaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.sensorylaser.dff{j},i);
            [data{dsetID}.delaylaser.avg_dff{j}(:,i),data{dsetID}.delaylaser.sem_dff{j}(:,i)] = avgTrialsNew(data{dsetID}.delaylaser.dff{j},i);
        end
    end
end

%% Responsive Cells - Mean
skew = 0.6;
alpha = 0.05; 

% NO LASER
for dsetID = 1:length(experimentID)
    for trial_type_ID =1:number_types
        for cellID = 1:size(data{dsetID}.nolaser.dff{trial_type_ID},2)%number of cells
            sensory_dff_temp= squeeze(data{dsetID}.nolaser.dff{trial_type_ID}(data{dsetID}.frames.sensory(1):data{dsetID}.frames.sensory(2),cellID,:));
            baseline_dff_temp = squeeze(data{dsetID}.nolaser.dff{trial_type_ID}(data{dsetID}.frames.baseline(1):data{dsetID}.frames.baseline(2),cellID,:));
            diff_temp = mean(sensory_dff_temp,1,"omitnan") - mean(baseline_dff_temp,1,"omitnan");
            if abs(skewness(diff_temp)) < skew
                pvals{dsetID}(trial_type_ID,cellID) = signrank(diff_temp); % Wilcoxon signed-rank test
            else
                pvals{dsetID}(trial_type_ID,cellID) = signtest(diff_temp); % sign test
            end
            clear dff_temp
        end
        data{dsetID}.nolaser.is_resp = pvals{dsetID} < alpha; %cell IDs that are responsive
    end
    data{dsetID}.nolaser.resp_cellIDs = find(sum(data{dsetID}.nolaser.is_resp(1:number_types,:),1) > 0); 
end

% SENSORY LASER
for dsetID = 1:length(experimentID)
    for trial_type_ID =1:number_types
        for cellID = 1:size(data{dsetID}.sensorylaser.dff{trial_type_ID},2)%number of cells
            sensory_dff_temp= squeeze(data{dsetID}.sensorylaser.dff{trial_type_ID}(data{dsetID}.frames.sensory(1):data{dsetID}.frames.sensory(2),cellID,:));
            baseline_dff_temp = squeeze(data{dsetID}.sensorylaser.dff{trial_type_ID}(data{dsetID}.frames.baseline(1):data{dsetID}.frames.baseline(2),cellID,:));
            diff_temp = mean(sensory_dff_temp,1,"omitnan") - mean(baseline_dff_temp,1,"omitnan");
            if abs(skewness(diff_temp)) < skew
                pvals_laser{dsetID}(trial_type_ID,cellID) = signrank(diff_temp); % Wilcoxon signed-rank test
            else
                pvals_laser{dsetID}(trial_type_ID,cellID) = signtest(diff_temp); % sign test
            end
            clear dff_temp
        end
        data{dsetID}.sensorylaser.is_resp = pvals_laser{dsetID} < alpha; %cell IDs that are responsive
    end
    data{dsetID}.sensorylaser.resp_cellIDs = find(sum(data{dsetID}.sensorylaser.is_resp(1:number_types,:),1) > 0);
end

%% save data
save([experimentID{1}(5:6),'_S2.mat'],'data','experimentID','number_types') %pulls area string(i.e. 'S1' or 'S2') from experiment ID string
