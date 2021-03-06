%% Master for Computer Vision SS21 project
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
close all
clear all
clc

% Define the Image Class :
Image = Image();

Image.Folder = 'Kuwait';  %Select Images you want to work on
% Image.Plot_Steps = 1; % '1' or '0'. Plots a lot of pictures if you set true

%% Image Loader

% Loads Images into Cell array of Dimensions 1 x #ofImages, where each
% entry is of the size the picture has in pixels, so height x width y
Image.Names = {dir(fullfile(Image.Folder, '*.jpg')).name}; %cell array of all Image file names
Image.Number = length(Image.Names);

%Content of Images
Image.Content = cell(1, Image.Number);

for i = 1 : Image.Number
    Image.Content{i} = imread(fullfile(Image.Folder, Image.Names{i}));
end

Image.Middle_idx = round(Image.Number/2); 

%% Plot first, middle and last Image to get
% % Define Middle, Starting and Ending Image to plot them for a better feeling
% img_Mid=Image.Content{Image.Middle_idx}(1:end-60,1:end,:);%Google Earth Logo cut out
% img_Start=Image.Content{1}(1:end-60,1:end,:);%Google Earth Logo cut out
% img_End=Image.Content{end}(1:end-60,1:end,:);%Google Earth Logo cut out
% 
% figure(1); imshow(img_Mid); title('Middle Image');
% figure(2); imshowpair(img_Start,img_End,'montage'); title('First/Last Image');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Normalizing Algorithm
% Preallocation
Image.Transforms = cell(Image.Number);
Image.Reconstructed = cell(Image.Number);
Image.Transformation_Status = cell(Image.Number);

%Iterate so that every picture is once the reference picture
for ref_index = 1 : Image.Number
    
    img_ref = rgb2gray(Image.Content{ref_index}(1 : end - 60, 1 : end, :)); %We simply cut away the google Logoc
    
    for move_index = 1 : Image.Number
            try 
                img_move = rgb2gray(Image.Content{move_index}(1 : end - 60, 1 : end,:)); %We simply cut away the google Logoc
%               imshow(img_move)
                Image.Reconstructed{ref_index, move_index} = registerImages(img_move, img_ref);
            catch
                try
                    img_move = imrotate(rgb2gray(Image.Content{move_index}(1 : end - 60, 1 : end,:)), 90);
                    Image.Reconstructed{ref_index, move_index} = registerImages(img_move, img_ref);
                catch
                    try
                        img_move = imrotate(rgb2gray(Image.Content{move_index}(1 : end - 60, 1 : end,:)), 180);
                        Image.Reconstructed{ref_index, move_index} = registerImages(img_move, img_ref);
                    catch
                        img_move = imrotate(rgb2gray(Image.Content{move_index}(1 : end - 60, 1 : end,:)), 270);
                        Image.Reconstructed{ref_index, move_index} = registerImages(img_move, img_ref);
                    end
                end
            end
    end %end move image loop
    %% Plot all reconstructed pictures
     %if Image.Plot_Steps
        fig7 = figure(7);
        set(fig7, 'Name', 'Overview Reconstructed Images');
        for k = 1 : Image.Number
            subplot(3, ceil(Image.Number / 3), k);
            imshow(Image.Reconstructed{ref_index, k}.RegisteredImage), title(sprintf('Image %d', k));
        end
        sgtitle(sprintf('Image %d was chosen as reference image', ref_index)) 
     %end

end  %end ref image loop


