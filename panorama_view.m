function panorama = panorama_view(images_reconstructed, trafos)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

%PANORAMA_VIEW: creates a "panorama" image from an array of reconstructed images

%Check number of images and transforms
numImages = length(images_reconstructed);
trafos = trafos(ceil(length(trafos)/2),:);
trafos = cell(size(trafos));
trafos(:) = {projective2d};

%Check for image sizes
for n = 1:numImages
     imageSize(n,:) = size(rgb2gray(images_reconstructed{n}));
end

%Check for axis limits
for i = 1:numel(trafos)  
    [xlim(i,:), ylim(i,:)] = outputLimits(trafos{i}, [1 imageSize(i,2)], [1 imageSize(i,1)]);    
end

%Set axis and dimensions
avgXLim = mean(xlim, 2);
[~,idx] = sort(avgXLim);
centerIdx = floor((numel(trafos)+1)/2);
centerImageIdx = idx(centerIdx);

maxImageSize = max(imageSize);

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', images_reconstructed{1});

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);



% Create the panorama.
for i = 1:numImages   
    I = images_reconstructed{i};      
    % Transform I into the panorama.
    warpedImage = imwarp(I, trafos{i}, 'OutputView', panoramaView);
                  
    % Generate a binary mask.    
    mask = imwarp(true(size(I,1),size(I,2)), trafos{i}, 'OutputView', panoramaView);
    
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end

figure(2),
imshow(panorama),
title("Panorama view of the reconstructed images")

end