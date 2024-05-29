%% Decoding task variables in single-neurons using Multiple Regression Analysis
% Relevant to Suppl. Fig. 6 Linear regression analysis
% Inspired by Condylis et al 2020
%% load data 
clearvars
experimentID = {' '}; % list experiments together separated by ,
nperm = 1000; % Number of permutations
for dsetID = 1:length(experimentID)
    temp = load([experimentID{dsetID},'_data.mat'],'d'); %EDIT: location of files
    data{dsetID} = temp.d;
    clear temp
end

%% Calculating area under the curve for sensory period for each individual trial

for dsetID = 1:length(data)
    for type = 1:8
        for jj = 1 : size(data{dsetID}.dff_all,2)
            for trial = 1 : size(data{dsetID}.nolaser.dff{type},3)% no laser trials
                baseline_AUC{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.nolaser.dff{type}(:,jj,trial))',data{dsetID}.frames.baseline);
                sensory_AUC{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.nolaser.dff{type}(:,jj,trial))',data{dsetID}.frames.sensory);
            end
            for trial = 1 : size(data{dsetID}.sensorylaser.dff{type},3) % laser in sensory period trials
                baseline_AUC_sensorylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.sensorylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.baseline);
                sensory_AUC_sensorylaser{dsetID,type}(jj,trial) = areaUnderCurve(squeeze(data{dsetID}.sensorylaser.dff{type}(:,jj,trial))',data{dsetID}.frames.sensory);
            end
            for trial = 1 : size(data{dsetID}.delaylaser.dff{type},3) % laser in delay period
            end
        end
        % subtract AUC during baseline period
        sensory_AUC_minus{dsetID,type} = sensory_AUC{dsetID,type} - baseline_AUC{dsetID,type}; % area under sensory no laser minus area under baseline no laser
        sensory_AUC_laser_minus{dsetID,type} = sensory_AUC_sensorylaser{dsetID,type} - baseline_AUC_sensorylaser{dsetID,type}; %area under sensory w/ sensory laser minus area under baseline w/ sensory laser
    end
end

%% NO LASER - Mulitiple Linear Regression for each cell

for dsetID = 1:length(data)

    for cellID = 1:size(sensory_AUC_minus{dsetID,1},1)

        % T1 Hit --> G5 and lick
        trialID = 1;
        AUC{trialID,1} = squeeze(sensory_AUC_minus{dsetID,trialID}(cellID,:))';
        texture{trialID,1} = ones(size(sensory_AUC_minus{dsetID,trialID},2),1); % G5
        lick{trialID,1} = ones(size(sensory_AUC_minus{dsetID,trialID},2),1); % lick

        % T1 Miss --> G5 and no lick
        trialID = 2;
        AUC{trialID,1} = squeeze(sensory_AUC_minus{dsetID,trialID}(cellID,:))';
        texture{trialID,1} = ones(size(sensory_AUC_minus{dsetID,trialID},2),1);% G5
        lick{trialID,1} = zeros(size(sensory_AUC_minus{dsetID,trialID},2),1); % no lick

        % Blank CR --> G0 and no lick
        trialID = 3;
        AUC{trialID,1} = squeeze(sensory_AUC_minus{dsetID,trialID}(cellID,:))';
        texture{trialID,1} = zeros(size(sensory_AUC_minus{dsetID,trialID},2),1); % G0
        lick{trialID,1} = zeros(size(sensory_AUC_minus{dsetID,trialID},2),1); %no lick

        % Blank FA --> G0 and lick
        trialID = 4;
        AUC{trialID,1} = squeeze(sensory_AUC_minus{dsetID,trialID}(cellID,:))';
        texture{trialID,1} = zeros(size(sensory_AUC_minus{dsetID,trialID},2),1); % G0
        lick{trialID,1} = ones(size(sensory_AUC_minus{dsetID,trialID},2),1); % lick

        % combine into one list
        AUC = cell2mat(AUC);
        texture = cell2mat(texture);
        lick = cell2mat(lick);

        % zscore 
        AUC_z = zscore(AUC);

        % combine predictor variables into a matrix
        predictors = cat(2,texture,lick); % predictors = cat(2,texture,lick,avg_vel);

        %EDIT NEW FUNCTION FOR PERMUTATION TESTING
        [foo_pval{dsetID}(cellID,:), foo_estimates{dsetID}(cellID,:),lm{dsetID,cellID}]...
            = multiLinRegressPermTest(predictors,AUC_z,nperm);

        clear predictors AUC AUC_z texture lick nolaser
    end
    % clear avg_vel
end

%% LASER - Mulitiple Linear Regression for each cell
tic;
for dsetID = 1:length(data)

    for cellID = 1:size(sensory_AUC_laser_minus{dsetID,1},1)

        % T1 Hit --> G5 and lick
        trialID = 1;
        AUC_laser{trialID,1} = squeeze(sensory_AUC_laser_minus{dsetID,trialID}(cellID,:))';
        texture_laser{trialID,1} = ones(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % G5
        lick_laser{trialID,1} = ones(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % lick

        % T1 Miss --> G5 and no lick
        trialID = 2;
        AUC_laser{trialID,1} = squeeze(sensory_AUC_laser_minus{dsetID,trialID}(cellID,:))';
        texture_laser{trialID,1} = ones(size(sensory_AUC_laser_minus{dsetID,trialID},2),1);% G5
        lick_laser{trialID,1} = zeros(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % no lick

        % Blank CR --> G0 and no lick
        trialID = 3;
        AUC_laser{trialID,1} = squeeze(sensory_AUC_laser_minus{dsetID,trialID}(cellID,:))';
        texture_laser{trialID,1} = zeros(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % G0
        lick_laser{trialID,1} = zeros(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); %no lick

        % Blank FA --> G0 and lick
        trialID = 4;
        AUC_laser{trialID,1} = squeeze(sensory_AUC_laser_minus{dsetID,trialID}(cellID,:))';
        texture_laser{trialID,1} = zeros(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % G0
        lick_laser{trialID,1} = ones(size(sensory_AUC_laser_minus{dsetID,trialID},2),1); % lick

        % combine into one list
        AUC_laser = cell2mat(AUC_laser);
        texture_laser = cell2mat(texture_laser);
        lick_laser = cell2mat(lick_laser);

        % zscore
        AUC_laser_z = zscore(AUC_laser);

        % combine predictor variables into a matrix
        predictors_laser = cat(2,texture_laser,lick_laser); % predictors_laser = cat(2,texture_laser,lick_laser,avg_vel_laser);


        %fit multiple linear regression model and use Permutaion Testing
        [foo_laser_pval{dsetID}(cellID,:), foo_laser_estimates{dsetID}(cellID,:), lm_laser{dsetID,cellID}]...
            = multiLinRegressPermTest(predictors_laser,AUC_laser_z,nperm);

        clear predictors_laser AUC_laser AUC_laser_z texture_laser lick_laser
    end
    
end

%% Extracting Values
% Permutation pvalues for each cell and coefficient are in:lm_results{dsetID}.Coefficients.pValuePerm

for dsetID = 1:length(data)
    for cellID = 1:size(sensory_AUC_minus{dsetID,1},1)

        % estimated coefficients for each term in model
        lm_results{dsetID}.Coefficients.Estimate(cellID,:) = lm{dsetID,cellID}.Coefficients.Estimate;
        lm_results_laser{dsetID}.Coefficients.Estimate(cellID,:) = lm_laser{dsetID,cellID}.Coefficients.Estimate;

        % SE — Standard error of the coefficients
        lm_results{dsetID}.Coefficients.SE(cellID,:) = lm{dsetID,cellID}.Coefficients.SE;
        lm_results_laser{dsetID}.Coefficients.SE(cellID,:) = lm_laser{dsetID,cellID}.Coefficients.SE;

        %tStat - t statisitc for each coefficient ...
        lm_results{dsetID}.Coefficients.tStat(cellID,:) = lm{dsetID,cellID}.Coefficients.tStat;
        lm_results_laser{dsetID}.Coefficients.tStat(cellID,:) = lm_laser{dsetID,cellID}.Coefficients.tStat;

        % Old pValue
        % p-value for the t-statistic of the two-sided hypothesis test
        lm_results{dsetID}.Coefficients.OldTtestpValue(cellID,:) = lm{dsetID,cellID}.Coefficients.pValue;
        lm_results_laser{dsetID}.Coefficients.OldTtestpValue(cellID,:) = lm_laser{dsetID,cellID}.Coefficients.pValue;

        % Rsquared - Ordinary
        lm_results{dsetID}.Rsquared.Ordinary(cellID,1) = lm{dsetID,cellID}.Rsquared.Ordinary;
        lm_results_laser{dsetID}.Rsquared.Ordinary(cellID,1) = lm_laser{dsetID,cellID}.Rsquared.Ordinary;

        % Rsquared - Adjusted
        lm_results{dsetID}.Rsquared.Adjusted(cellID,1) = lm{dsetID,cellID}.Rsquared.Adjusted;
        lm_results_laser{dsetID}.Rsquared.Adjusted(cellID,1) = lm_laser{dsetID,cellID}.Rsquared.Adjusted;

        % NEW Permutation Testing pValue
        %EDIT: could change so outputs stright to this structure no need for
        %"foo" variables. But fine the way it is
        lm_results{dsetID}.Coefficients.pValuePerm(cellID,:) = foo_pval{dsetID}(cellID,:);
        lm_results_laser{dsetID}.Coefficients.pValuePerm(cellID,:) = foo_laser_pval{dsetID}(cellID,:);
    end
end
