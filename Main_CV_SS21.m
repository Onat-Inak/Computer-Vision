%% Main for Computer Vision Project in SS21
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

% Goal of the Project: Spot changes of places like Glaciers, Cities,
% Rainforests over time to see their development. Therefore satelite images
% taken at different times are input to the GUI and differences are shown
% to the user, who can also choose parameters on:
% - magnitude of changes
% - segmentation of changes
% - Clusters/outlier changes
% - Type of visualization (time-lapse: slow/fast, difference highlights)

clear all
close all
clc

tic
%% 1.) Load a folder of satelite images by specifying its name
% From Project specification: Folder of pictures taken of the same location
% on earth with naming convention YYYY_MM.FORMAT

% Loads Images into Cell array of Dimensions 1 x #ofImages, where each
% entry is of the size the picture has in pixels, so  width x height
Name_of_Image_Folder = 'Beirut';  %Select Images you want to work on


Image_Names={dir(fullfile(Name_of_Image_Folder,'*_*.*')).name}; %cell array of all Image file names
Image_number=length(Image_Names);
%Content of Images
Images=cell(1,Image_number);
for i=1:Image_number
Images{i}=imread(fullfile(Name_of_Image_Folder,Image_Names{i}));
end

%% 2.) Reconstruct all pictures to be taken from the same point in space
% To spot differences in the pictures, we need to transform the images in
% the cell array Images, to be taken from the same point in space. The
% loaded images can be seen as rotated and translated compared to a
% reference image. With an Algorithm based on SURF+MSAC (a variant of
% RANSAC), we find matching features between images and get a
% transformation to adapt the images to the reference Image. With a 
% graph-theory based logic we efficiently compute only transforms that are
% needed to Reconstruct all images to be adapted to the reference picture


% Here we have the following functions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  [Images_reconstructed, trafos] = Reconstruct_Images(Images) %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstructs Images so that they are all adapted to the Reference Image, 
% meaning they are taken from the same point in space, showing the same
% location. Here we have the logic implemented to efficiently call our 
% SURF + MSAC Algorithm. 
%   Images                   Cell array of Dimensions 1 x #ofImages, original images
% 
%   Images_reconstructed     Cell array of Dimensions 1 x #ofImages, All adapted to reference picture
%   trafos                   Cell array of Dimensions #ofImages x#ofImages,contains all calculated working transforms
%                            trafos(i,j) describes the transform from j-th Image to i-th Image as reference Image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  [tform] = SURF_MSAC(Image_ref,Image_move) %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements SURF with MSAC
%   Image_ref                Reference Image
%   Image_move               Image to be transformed to Reference Image perspective
% 
%   tform                    trafo allowing Image_move to be transformed to Image_ref
tic
[Images_reconstructed, trafos, Image_ref_number] = Reconstruct_Images(Images);
normalization_calc_duration=toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% ==> AB HIER ENDE MOE UND ROBERT UND START ONAT UND ADAM  <=== %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3.) Get Differences between the reconstructed Images
% 1. Create a panorama view of the reconstructed images. This view serves
% as a canvas for the change visualization and displays all the scene
% regions represented in the reconstructed images.
% 2. Crop reference and moving image boundaries, then normalize pixels in
% reference image. Afterwards, calculate absolute pixel differences and
% mark them in red channel of moving image if above threshold. Furthemore, specify if
% image segmentation is implemented with a binarized mask. This will
% crop out specific image regions (e.g. sea/land, forest/city).
% 3. Display changes of n images in a time lapse visualization on the
% panorama view canvas. Set speed of time lapse. 


% 3.0.1 Set the parameters in order to change between different functionalities and
% visualizations :

% for 3.1 :
apply_3_1 = true;
comparison_rg_first_img = true; % compare all the images regarding the first image in a timelapse plot:
comparison_rg_prev_img = false; % compare all the images regarding the previous image in a timelapse plot:

apply_3_2 = false;
apply_3_3 = false;

% parameters for 3.1 :
threshold_DM_3_1 = 80; % threshold for the Difference Magnitude function
seg_flag_3_1 = 0;
plot_images_3_1 = 0;
pause_in_sec_3_1 = .5; % time difference between plots

% parameters for 3.2 :
num_superpixels = 5000;
threshold_DM_3_2 = 50;
threshold_SP_val = 10000; % threshold for seperating superpixels, which have more pixels than this threshold,
                        % from the others

% 3.0.2 Extract years and months from Image Names and save the results to the corresponding arrays:
% Ignore the empty reconstructed images and save the new image cell to the variable 
% Images_reconstructed_new:

logic_vec = logical(zeros(1, length(Images_reconstructed)));
years = zeros(1, length(Images_reconstructed));
months = zeros(1, length(Images_reconstructed));
iter = 1;
for i = 1 : length(Images_reconstructed)
    year_month_temp = cell2mat(Image_Names(i));
    years(i) = str2double(year_month_temp(1:4));
    months(i) = str2double(year_month_temp(5:7));
    if numel(Images_reconstructed{i}) == 0
        logic_vec(i) = false;
    else
        logic_vec(i) = true;
        Images_reconstructed_new{iter} = Images_reconstructed{i};
        iter = iter + 1;
    end
end
years_new = years(logic_vec);
months_new = months(logic_vec);

% 3.1 Apply Difference Magnitude for Threshold :

if apply_3_1
    % Get treshold, segmentation flag (implements segmentation) from GUI
    % and plot flag (plots each processing step)
    change_threshold = threshold_DM_3_1;
    seg_flag = seg_flag_3_1;
    plot_Images = plot_images_3_1;
    fig_for_3_1 = figure();
    hold on
    if comparison_rg_prev_img
        title('Changes between Images regarding to their Previous Images');
        for img_num = 1 : length(Images_reconstructed_new) - 1
            ref_image = Images_reconstructed_new{img_num};
            moving_image = Images_reconstructed_new{img_num + 1};

            %Measure runtime and run difference calculation
            t_all_differences_3_1 = tic;
            [Image_Marked, ~] = Difference_Magnitude(ref_image, moving_image, change_threshold, plot_Images, seg_flag);
            clf;
            imshow(Image_Marked);
            pause(pause_in_sec_3_1);
        end
    end
    if comparison_rg_first_img 
        for img_num = 2 : length(Images_reconstructed_new)
            ref_image = Images_reconstructed_new{1};
            moving_image = Images_reconstructed_new{img_num};

            %Measure runtime and run difference calculation
            t_all_differences_3_1 = tic;
            [Image_Marked, ~] = Difference_Magnitude(ref_image, moving_image, change_threshold, plot_Images, seg_flag);
            clf;
            title('Changes between Images regarding to first Image');
            imshow(Image_Marked);
            pause(pause_in_sec_3_1);
        end 
    end
    difference_calc_duration_3_1 = toc(t_all_differences_3_1)
    hold off
end

% 3.2 Apply Difference Magnitude function regarding superpixels in order to obtain 
% differences along bigger regions over a timelapse:

[superpixel_pos, N] = superpixels(Images_reconstructed_new{1}, num_superpixels);
change_threshold = threshold_DM_3_2;
seg_flag = seg_flag_3_1;
[~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, change_threshold, plot_Images, seg_flag);

[m, n, l] = size(Images_reconstructed_new{1});
logical_region_mask = zeros(m, n); 
region_mask_temp = zeros(m, n);
region_mask = zeros(m, n, 3);
for sp = 1 : N
    mat_temp = sp * ones(m, n);
    pos_sp_reg_img = (superpixel_pos == mat_temp);
%     sum(Diff_Image_Threshold(pos_sp_reg_img), 'all')
    if sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') > threshold_SP_val
        logical_region_mask = logical_region_mask + pos_sp_reg_img;
    end
end
logical_region_mask = logical(logical_region_mask);
region_mask_temp(logical_region_mask) = 255;
region_mask(:,:,1) = region_mask_temp;
region_mask(:,:,2) = zeros(m, n);
region_mask(:,:,3) = zeros(m, n);

figure();
BM = boundarymask(superpixel_pos);
imshow(Images_reconstructed_new{1})
figure();
imshow(imoverlay(region_mask, BM, 'cyan'),'InitialMagnification',67)

%% 4.)Nur nochmal eine temporäre spielerei, bei der für verschiedene Magnitudes die changes geplottet werden
% Das ist nur zum ansehen, allerdings nicht relevant!
%[Images_marked_changing_threshold]=show_Differences_Magnitude(images_comparison_ref, images_comparison_changes);