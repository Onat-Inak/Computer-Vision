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
Name_of_Image_Folder = 'Dubai';  %Select Images you want to work on


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

% Create a class for the visualization of the image differences :
VisualizationClass = Visualization(Images_reconstructed, Image_Names);

% Define the parameters :
            num_visualization = 3;
            chosen_images = "all"; % "all" or [vector contains image_numbers]
            threshold_DM = 50; % threshold for the Difference Magnitude function
            comparison_rg_first_img = true; % compare all the images regarding the first image in a timelapse plot
            comparison_rg_prev_img = false; % compare all the images regarding the previous image in a timelapse plot
            pause_duration = 1.5; % duration/time-difference between two different plots
            num_superpixels = 3000;
            threshold_SP_big = 30; % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
            threshold_SP_intermediate = 45;
            threshold_SP_small = 60;
            plot_big_changes = true;
            plot_intermediate_changes = true;
            plot_small_changes = true;

VisualizationClass.define_parameters(...
            'num_visualization', num_visualization ,...
            'chosen_images', chosen_images ,...
            'threshold_DM', threshold_DM ,...
            'comparison_rg_first_img', comparison_rg_first_img ,...
            'comparison_rg_prev_img', comparison_rg_prev_img ,... 
            'pause_duration', pause_duration ,...
            'num_superpixels', num_superpixels ,...
            'threshold_SP_big', threshold_SP_big ,...
            'threshold_SP_intermediate', threshold_SP_intermediate ,...
            'threshold_SP_small', threshold_SP_small ,...
            'plot_big_changes', plot_big_changes ,...
            'plot_intermediate_changes',  plot_intermediate_changes ,...
            'plot_small_changes', plot_small_changes)

        
if VisualizationClass.num_visualization == 1
    VisualizationClass.apply_3_1();
elseif VisualizationClass.num_visualization == 2
    %     TO-DO ADAM :
    %     VisualizationClass.apply_3_2();
    disp('TO-DO ADAM : VisualizationClass.apply_3_2()');
else
    VisualizationClass.apply_3_3();
end
%% 4.)Nur nochmal eine temporäre spielerei, bei der für verschiedene Magnitudes die changes geplottet werden
% Das ist nur zum ansehen, allerdings nicht relevant!
%[Images_marked_changing_threshold]=show_Differences_Magnitude(images_comparison_ref, images_comparison_changes);



