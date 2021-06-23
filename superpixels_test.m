
[superpixel_pos, N] = superpixels(Images_reconstructed_new{1}, num_superpixels);
change_threshold = threshold_DM_3_2;
seg_flag = seg_flag_3_1;
[~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, change_threshold, plot_Images, seg_flag);

[m, n, l] = size(Images_reconstructed_new{1});
logical_region_mask = zeros(m, n); 
region_mask_temp = zeros(m, n);
region_mask = zeros(m, n, 3);
thr = 0;
for sp = 1 : N
    mat_temp = sp * ones(m, n);
    pos_sp_reg_img = (superpixel_pos == mat_temp);
    thr = thr + sum(Diff_Image_Threshold(pos_sp_reg_img), 'all');
    if sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') > threshold_SP_val
        logical_region_mask = logical_region_mask + pos_sp_reg_img;
    end
end
logical_region_mask = logical(logical_region_mask);
region_mask_temp(logical_region_mask) = 255;
region_mask(:,:,1) = region_mask_temp;
region_mask(:,:,2) = zeros(m, n);
region_mask(:,:,3) = zeros(m, n);
thr/num_superpixels

figure();
BM = boundarymask(superpixel_pos);
imshow(imoverlay(Images_reconstructed_new{1}, BM, 'cyan'),'InitialMagnification',67)
imshow(region_mask)