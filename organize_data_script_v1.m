%% Organize data (gives '_data.mat file for each experiment' for responsive_cells_script)
% Run this script once for each dataset and save the output for later
% Suite2p Fall.mat file rename to date of experiment
% Be sure to have correct info in corresponding excel file 'trialtype_order_suite2p'
%if a dataset doesn’t have any trials for a certain trial type, the code fills the cell corresponding 
%to that trial type with a matrix of NaN values with the same dimensions as the rest of the trial types 
%[# neurons x # of timepoints x # of trials], with # of trials set to 1 for simplicity.
%The rest of the analysis code is now set to ignore any NaN values.
%%
clearvars
experimentID = '0221S2'; %ATTN, individual experiment ID only
 %  MAKE SURE UPDATE EXCEL SPREADSHEET 'trialtype_order_suite2p' with start/end periods etc.

%% Load in fluo data from Suite 2p output, correct fluo based on neuropil fluo,
% calculate dF/F using MacLean lab method, and organize by trial type
d = organizeDataSuite2pNew(experimentID);

save([experimentID,'_data_S1_before.mat'],'d')
 %%
% load('0604S1_cmo_data_S1_before.mat')
% load([experimentID,'0422S1_cmo_data_before.mat'],'d')

%% Go through each individual dataset, plot all dF/F traces, and identify
% any non-cells that need to be removed
%NOTE: space between traces is 10 dF/F

nc = 10;
offset = repmat(10 * (1:nc)', 1, size(d.dff_all,1));
nFigs=floor(size(d.dff_all,2)/nc);
remain=rem(size(d.dff_all,2),nc);
nFrames=size(d.dff_all,1);

for i=0:(nFigs)

    figure('units','normalized','outerposition',[0 0 1 1]);
    hold on
    if (i*nc+nc) <= size(d.dff_all,2)
        plot(d.dff_all(:,(i*nc+1):(i*nc+nc))+offset')

        xlabel('frame')
        title(['dset =',experimentID,', neurons ',num2str(i*nc+1),' - ',num2str(i*nc+nc)])

    elseif (i*nc+nc) > size(d.dff_all,2)

        plot(d.dff_all(:,(i*nc+1):end)+offset(1:remain,:)')
        xlabel('frame')
        title(['dset =',experimentID,', neurons ',num2str(i*nc+1),' - ',num2str(size(d.dff_all,2))])

    end
    for z=1:size(offset,1)
        plot(offset(z,:),'--k')
    end
    cell_labels={num2str(i*nc+1)}; %label y ticks with cell ID number

    for jj=2:nc
        cell_labels = [cell_labels,{num2str(i*nc+jj)}];
    end
    yticks([offset(:,1)])
    yticklabels(cell_labels)
    ylim([0 150])
end
%% remove "non-cells" (i.e. spikes indF/F values not physilologically possible)
bad_cells = [35,18];%ATTN

d.dff_all(:,bad_cells)=[];

for type = 1:8 %1:8
    if ~isempty(d.nolaser.dff{type})
        d.nolaser.dff{type}(:,bad_cells,:)=[];
    end
    if ~isempty(d.sensorylaser.dff{type})
        d.sensorylaser.dff{type}(:,bad_cells,:)=[];
    end
    if ~isempty(d.delaylaser.dff{type})
        d.delaylaser.dff{type}(:,bad_cells,:)=[];
    end
end

%% save data in matlab file
save([experimentID,'_data.mat'],'d')
