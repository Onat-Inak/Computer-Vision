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
tic
%% 1.) Load a folder of satelite images by specifying its name
% From Project specification: Folder of pictures taken of the same location
% on earth with naming convention YYYY_MM.FORMAT

% Loads Images into Cell array of Dimensions 1 x #ofImages, where each
% entry is of the size the picture has in pixels, so  width x height
Name_of_Image_Folder='Singapur';  %Select Images you want to work on


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
[Images_reconstructed, trafos] = Reconstruct_Images(Images);
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

% 3.1 Create panorama view img from reconstructed imgs and trafos
panorama_img = panorama_view(Images_reconstructed,trafos);
figure; imshow(panorama_img); title('Panorama view img');


% 3.2 Changes in Image based on absolute pixel differences.
images_comparison_ref=Images_reconstructed{1};
images_comparison_changes=Images_reconstructed{end};

%Set treshold, segmentation flag (implements segmentation)
% and plot flag (plots each processing step)
change_threshold=50;
seg_flag = 1;
plot_Images=0;

%Measure runtime and run difference calculation
%To-Do: only extract difference pixels, not whole img
t_all_differences=tic;
Image_Marked = Difference_Magnitude(images_comparison_ref,images_comparison_changes,change_threshold,plot_Images,seg_flag);
single_difference_calc_duration=toc(t_all_differences)
figure; imshow(Image_Marked); title('Changes between selected features with selected threshold');

%Show changes on panorama view 
figure;imshowpair(Image_Marked,panorama_img,'blend');title("Result img");

%3.3 Time lapse visualization 

%% 4.)Nur nochmal eine temporäre spielerei, bei der für verschiedene Magnitudes die changes geplottet werden
% Das ist nur zum ansehen, allerdings nicht relevant!
%[Images_marked_changing_threshold]=show_Differences_Magnitude(images_comparison_ref, images_comparison_changes);