function epochs= fixNosePosFun(trial_number,experimentID)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

vid = VideoReader(fullfile(strcat('real_data/03_Videos/',experimentID,'/',trial_number,'.mp4'))); 
Nframes=vid.NumberOfFrames

imshow(read(vid, 21))
axis on;
[nose_x,nose_y] = ginput(1);
hold on
plot(nose_x, nose_y, 'r', 'LineWidth', 3, "Marker", "o")
hold off

epochs.gappos = 382; %EDIT: whats this?
epochs.retractiondist = -12;%EDIT: whats this?

fixed_nose = zeros(2, Nframes); 
fixed_nose(1, :)=nose_x;
fixed_nose(2, :)=nose_y;
epochs.nosedist_track = fixed_nose;

end