function [tform] = SURF_MSAC(Image_ref,Image_move)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30
plot_image_steps= 0; % '1' or '0'. Plots a lot of pictures if you set true

Image_ref=rgb2gray(Image_ref); 
Image_move=rgb2gray(Image_move); 

%% Plot reference and moving Image
if plot_image_steps
    fig2=figure(2);
    set(fig2,'Name','Orig Ref and Mov Image');
    imshowpair(Image_ref,Image_move,'montage'); title('Reference vs. Moving Image')
end

%% Detect SURF Features
points_ref=detectSURFFeatures(Image_ref,'ROI',[1 1 size(Image_ref,2) size(Image_ref,1)-60]);
points_move=detectSURFFeatures(Image_move,'ROI',[1 1 size(Image_ref,2) size(Image_ref,1)-60]);
if plot_image_steps
    fig3=figure(3);
    set(fig3,'Name','SURF Features Detection');
    imshow(Image_move); hold on; plot(points_move(1:250)); title('Moving image with 250 features')
end

%% Extract Features around each point
[features_ref, points_ref] = extractFeatures(Image_ref,points_ref);
[features_move, points_move] = extractFeatures(Image_move,points_move);

%% Match found features
indexPairs = matchFeatures(features_ref,features_move,'Metric','SSD');
numMatchedPoints= int32(size(indexPairs,1));

matchedPoints_ref = points_ref(indexPairs(:,1),:);
matchedPoints_move = points_move(indexPairs(:,2),:);

if plot_image_steps
    fig4=figure(4);
    set(fig4,'Name','SURF Matched Features');
    showMatchedFeatures(Image_ref,Image_move,matchedPoints_ref,matchedPoints_move);
    title('Matched Points')
    legend('Reference Image','Moving Image')
end
%% Kill outliers with technique similiar to RANSAC
%We need a try here to catch error if we can't find 4 SURF points
% Here we eliminate outliers
try 
[tform,inlierIndex] = estimateGeometricTransform2D(matchedPoints_move,matchedPoints_ref,'projective',...
     'MaxNumTrials',20000,'MaxDistance',20);
 if length(inlierIndex) <20 %Do this since these Transformations are often bad
     tform=[];
    inlierIndex=[];
 end
 
catch
    tform=[];
    inlierIndex=[];
    %transformation_status{ref_index,move_index}="4 points not found"; 
end
inlierPts_move= matchedPoints_move(inlierIndex,:);
inlierPts_ref= matchedPoints_ref(inlierIndex,:);

%Plot inlier features, so like figure 4 but with some features kicked out
if plot_image_steps
    fig5=figure(5);
    set(fig5,'Name','Matched Inlier Features');
    figure(5)
    showMatchedFeatures(Image_ref,Image_move,inlierPts_ref,inlierPts_move)
    title('Matched Inlier Points')
end

end