function plotWhiskFun (trial_number,experimentID,whtracking)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
figure;
plot(conv(whtracking.mean_angle,[1 1 1]./3,'same'),'r');
ylim([0 360])
ylabel("Pixel")
xlabel("t (timeframe)")
title(['Whisking pattern of trial ', trial_number])

% Save image
saveas(gcf, strcat('real_data/04_Results/',experimentID,'/whisk_',trial_number,'.png' ))

end