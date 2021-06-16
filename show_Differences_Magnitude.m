function [marked_Images]=show_Differences_Magnitude(images_comparison_ref, images_comparison_changes)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

% Hier ist nur die Logik für häufigeres Plotten mit unterschiedlichen
% thresholds
%% Plot Differences with threshold on their magnitude of one picture compared to the reference pic
%Plot reference picture and moving picture
fig=figure;
set(fig,'Name','Reference and Moving Image');
imshowpair(images_comparison_ref,images_comparison_changes,'montage'); title('Reference Image vs Moving Image')


%Plot changes dependant on threshhold for changes
fig=figure;
set(fig,'Name','Change in Change_threshold');
change_thresholds=10:10:120;
marked_Images=cell(1,length(change_thresholds));
for i=change_thresholds
    marked_Images{i/10}=Difference_Magnitude(images_comparison_ref,images_comparison_changes,i);
    subplot(3,4,i/10)
    imshow(marked_Images{i/10})
    title(sprintf('Changes with threshold > %d', i))
end
sgtitle(sprintf('Images with varying threshold on changes')) 


end

