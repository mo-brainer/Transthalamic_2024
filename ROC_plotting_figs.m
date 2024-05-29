clearvars
area_string = 'S1';
load('_wROC.mat') %Load data from ROC_calculating_DI

%% Responsive cells 

for dsetID = 1:length(experimentID)
    data{dsetID}.resp_cellIDs_both = find(sum(cat(1,data{dsetID}.nolaser.is_resp,data{dsetID}.sensorylaser.is_resp),1) > 0);
end
%% gather DI, CI and pvals for responsive neurons, for all datasets laser
% and nonlaser conditions

% DI
for dsetID =1:length(data)
    % RESPONSIVE CELLS
    DI_resp_nolaser{dsetID,1} =data{dsetID}.nolaser.DI_sensory(data{dsetID}.resp_cellIDs_both,1);
    pDI_resp_nolaser{dsetID,1} = data{dsetID}.nolaser.DIpval_sensory(data{dsetID}.resp_cellIDs_both,1);
    DI_resp_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.DI(data{dsetID}.resp_cellIDs_both,1);
    pDI_resp_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.DIpval(data{dsetID}.resp_cellIDs_both,1);
    sig_DI_resp_nolaser_NEW{dsetID,1} = data{dsetID}.nolaser.DI_newsig(data{dsetID}.resp_cellIDs_both,1);
    sig_DI_resp_sensorylaser_NEW{dsetID,1} = data{dsetID}.sensorylaser.DI_newsig(data{dsetID}.resp_cellIDs_both,1);

    %ALL CELLS
    DI_nolaser{dsetID,1} =data{dsetID}.nolaser.DI_sensory;
    pDI_nolaser{dsetID,1} = data{dsetID}.nolaser.DIpval_sensory;
    DI_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.DI;
    pDI_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.DIpval;
end

% CI
for dsetID =1:length(data)
    CI_resp_nolaser{dsetID,1} =data{dsetID}.nolaser.CI_sensory(data{dsetID}.resp_cellIDs_both,1);
    pCI_resp_nolaser{dsetID,1} = data{dsetID}.nolaser.CIpval_sensory(data{dsetID}.resp_cellIDs_both,1);
    CI_resp_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.CI(data{dsetID}.resp_cellIDs_both,1);
    pCI_resp_sensorylaser{dsetID,1} =data{dsetID}.sensorylaser.CIpval(data{dsetID}.resp_cellIDs_both,1);
    sig_CI_resp_nolaser_NEW{dsetID,1} = data{dsetID}.nolaser.CI_newsig(data{dsetID}.resp_cellIDs_both,1);
    sig_CI_resp_sensorylaser_NEW{dsetID,1} = data{dsetID}.sensorylaser.CI_newsig(data{dsetID}.resp_cellIDs_both,1);
end

%% Fraction of RESPONSIVE neurons selective w/ and w/out laser

frac_DI_resp_nolaser = cell2mat(cellfun(@(x) sum(x)/length(x),sig_DI_resp_nolaser_NEW,'UniformOutput',false));
frac_DI_resp_sensorylaser = cell2mat(cellfun(@(x) sum(x)/length(x),sig_DI_resp_sensorylaser_NEW,'UniformOutput',false));
figure;
plotBarError(cat(1,frac_DI_resp_nolaser',frac_DI_resp_sensorylaser'))
