

% Images_reconstructed_resized = resize_images(Images_reconstructed);
% 
% Difference_Magnitude_Timelapse(Images_reconstructed_resized)
% 
% save_resized_images(Images_reconstructed_resized, Name_of_Image_Folder);

logical_vec = zeros(1, length(Images_reconstructed));

for i = 1 : length(Images_reconstructed)
    if numel(Images_reconstructed{i}) == 0
        logical_vec(i) = 0;
    else 
        logical_vec(i) = 1;
    end
end

Images_reconstructed = Images_reconstructed(logical(logical_vec));
