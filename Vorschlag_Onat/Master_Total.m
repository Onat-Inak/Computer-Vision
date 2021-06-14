%% Master for Computer Vision SS21 project
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
close all
tic

% Define the Image Class :
Image = Image();

Image.Folder = 'Kuwait';  %Select Images you want to work on
Image.Plot_Steps = 0; % '1' or '0'. Plots a lot of pictures if you set true

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
for ref_index = 1:Image.Number
    img_ref = rgb2gray(Image.Content{ref_index}(1:end-60,1:end,:)); %We simply cut away the google Logoc
    for move_index = 1 : Image.Number
        img_move = rgb2gray(Image.Content{move_index}(1 : end - 60, 1 : end,:)); %We simply cut away the google Logoc
        
        %% Plot reference and moving Image
        if Image.Plot_Steps
            fig2 = figure(2);
            set(fig2, 'Name', 'Orig Ref and Mov Image');
            imshowpair(img_ref, img_move, 'montage'); title('Reference vs. Moving Image')
        end
        
        %% Detect SURF Features
        points_ref=detectSURFFeatures(img_ref, 'NumScaleLevels',4);
        points_move=detectSURFFeatures(img_move, 'NumScaleLevels',4);
        
        if Image.Plot_Steps
            fig3 = figure(3);
            set(fig3, 'Name', 'SURF Features Detection');
            imshow(img_move); hold on; plot(points_move(1 : 250)); title('Moving image with 250 features')
        end
        
        %% Extract Features around each point
        [features_ref, points_ref] = extractFeatures(img_ref, points_ref);
        [features_move, points_move] = extractFeatures(img_move, points_move);

        %% Match found features
        indexPairs = matchFeatures(features_ref, features_move, 'Metric','SSD');
        numMatchedPoints = int32(size(indexPairs, 1));

        matchedPoints_ref = points_ref(indexPairs(:,1), :);
        matchedPoints_move = points_move(indexPairs(:,2), :);
        
        if Image.Plot_Steps
            fig4 = figure(4);
            set(fig4, 'Name', 'SURF Matched Features');
            showMatchedFeatures(img_ref, img_move, matchedPoints_ref, matchedPoints_move);
            title('Matched Points')
            legend('Reference Image', 'Moving Image')
        end
        %% Kill outliers with technique similiar to RANSAC
        %We need a try here to catch error if we can't find 4 SURF points
        % Here we eliminate outliers
        try 
        [tform, inlierIndex] = estimateGeometricTransform2D(matchedPoints_move, matchedPoints_ref, 'projective',...
             'MaxNumTrials', 30000, 'MaxDistance',10);
        catch
            Image.Transforms{ref_index, move_index} = [];
            Image.Reconstructed{ref_index, move_index} = [];
            Image.Transformation_Status{ref_index, move_index} = "4 points not found"; 
            continue
        end
        inlierPts_move = matchedPoints_move(inlierIndex, :);
        inlierPts_ref = matchedPoints_ref(inlierIndex, :);
        
        %Plot inlier features, so like figure 4 but with some features kicked out
        if Image.Plot_Steps
            fig5 = figure(5);
            set(fig5, 'Name', 'Matched Inlier Features');
            figure(5)
            showMatchedFeatures(img_ref, img_move, inlierPts_ref, inlierPts_move)
            title('Matched Inlier Points')
        end
        
        %Apply the transformation to the moving image and check if it
        %worked, If it is all black, the features made a transform not possible
        outputView = imref2d(size(img_ref));
        Image_reconstruced = imwarp(img_move, tform, 'OutputView', outputView);
        if ~sum(Image_reconstruced(:)) %Checks if Image_reconstruced is only black
            status=0;
        else
            status=1;
        end
        if Image.Plot_Steps
            fig6 = figure(6);
            set(fig6, 'Name', 'Recosntructed Image');
            imshow(Image_reconstruced); 
            title('Reconstructed Image');
        end
        %Save all values obtained in loop
        Image.Transforms{ref_index, move_index} = tform;
        Image.Reconstructed{ref_index, move_index} = Image_reconstruced;
        Image.Transformation_Status{ref_index, move_index} = status;
    end %end move image loop
    %% Plot all reconstructed pictures
     %if Image.Plot_Steps
        fig7 = figure(7);
        set(fig7, 'Name', 'Overview Reconstructed Images');
        for k = 1 : Image.Number
            subplot(3, ceil(Image.Number / 3), k);
        imshow(Image.Reconstructed{ref_index, k}), title(sprintf('Image %d', k))
        end
        sgtitle(sprintf('Image %d was chosen as reference image', ref_index)) 
     %end

end  %end ref image loop
toc

