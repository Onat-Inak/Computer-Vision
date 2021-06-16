function EF = reconstructSURF_RANSAC(imgs)
%RECONSTRUCTSURF_RANSAC: Extract SURF features, apply RANSAC to filter
%outliers and calculate fundamental matrix EF
    for i=1:size(imgs,2)-1
        %Read image
        img1 = imgs{1,i}{1,1};
        img2 = imgs{1,i+1}{1,1};
        %Convert to grayscale
        img1 = rgb2gray(img1);
        img2 = rgb2gray(img2);
        
        %Find SURF features
        points1 = detectSURFFeatures(img1);
        points2 = detectSURFFeatures(img2);
        
        %Extract feature locations and descriptor variables
        [features1,valid_points1] = extractFeatures(img1,points1);
        [features2,valid_points2] = extractFeatures(img2,points2);
        
        %Do dense correspondence with SSD w. feature descriptors
        indexPairs = matchFeatures(features1,features2);
        
        %Find correspondence 
        matchedPoints1 = valid_points1(indexPairs(:,1),:);
        matchedPoints2 = valid_points2(indexPairs(:,2),:);
        
        %Find fundamental matrix using the RANSAC (w. Sampson distance) 
        %method.        
        EF_i = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'Method','RANSAC');
        EF_all{i} = {EF_i};
    end   
    
    %From the calculated fundamental matrices, calculate mean fundamental
    %matrix
    EF = cell2mat([EF_all{:}]);
    EF = reshape(EF,[3,3,7]);
    EF = mean(EF,3);
end

