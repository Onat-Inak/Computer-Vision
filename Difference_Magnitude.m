function [Image_Marked,Diff_image_threshold] = Difference_Magnitude(Image_ref,Image_move,change_threshold,plot_Images,seg_flag,l_filter)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30
%% Get and show Boundaries of reconstructed Moving Image
BW = im2uint8(rgb2gray(Image_move)); %Transform to Black&White
[B,L,~,~] = bwboundaries(BW,'noholes');
if(size(B,1)>1)
    for n=2:length(B)
        L([B{n}(:,1)],[B{n}(:,2)]); %
    end
    B(2:end)=[]; %Set B to only have length 1 (main boundary)
    
end
% Showing the boundaries:
if plot_Images
    figure(2), imshow(BW); title("Boundary at Moving Image"); hold on;
    for k=1:length(B)
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
    end
end
%% Cut Reference Image
%Cut Reference Image
Image_ref_cut=Image_ref.*uint8(L);

%% Get and show Boundaries of cut reference Image
BW_ref = im2uint8(rgb2gray(Image_ref_cut)); %Transform to Black&White
[B,L_ref,~,~] = bwboundaries(BW_ref,'noholes');
if(size(B,1)>1)
    for n=2:length(B)
        L_ref([B{n}(:,1)],[B{n}(:,2)]); %
    end
    B(2:end)=[]; %Set B to only have length 1 (main boundary)
    
end
% Showing the boundaries:
if plot_Images
    figure(3), imshow(BW_ref); title("Boundary at Reference Image"); hold on;
    for k=1:length(B)
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
    end
end
%% Cut moving Image and normalize moving Image
%Cut moving Image
Image_move_cut=Image_move.*uint8(L_ref);
Image_move_norm = histeq(Image_move_cut,imhist(Image_ref_cut));

if plot_Images
    figure(4)
        subplot(2,1,1)
        imshowpair(Image_ref_cut,Image_move,'montage'); title('Cut Reference Image vs Moving Image')

        subplot(2,1,2)
        imshowpair(Image_ref_cut,Image_move_norm,'montage'); title('Cut Reference Image vs Normalized Moving Image')

    figure(5),imshowpair(Image_ref_cut,Image_move_norm,'diff'); title("Difference Image between Reference and Moving Image")
end 
%% Image Segmentation (e.g. Rural-Sea)
%Outputs binarized mask of reference and moving imgs
if seg_flag
    %Apply binary thresholding to find binary mask
    Image_ref_mask = segmentImage(rgb2gray(Image_ref_cut));
    Image_mov_mask = segmentImage(rgb2gray(Image_move_norm));
    
    %Use binary mask on reference and moving images for segmentation
    Image_ref_cut_seg = bsxfun(@times, Image_ref_cut, cast(Image_ref_mask, 'like', Image_move_norm));
    Image_move_norm_seg = bsxfun(@times, Image_move_norm, cast(Image_mov_mask, 'like', Image_move_cut));
    
    if plot_Images 
        figure(6)
        imshowpair(Image_ref_cut_seg,Image_move_norm_seg,'montage'); title('Segmented images')
    end
end
%% Threshold on change
%Calculate absolute pixel difference between reference and moving img
Diff_image=imabsdiff(rgb2gray(Image_ref_cut),rgb2gray(Image_move_norm));
Diff_image_threshold=Diff_image.*uint8(Diff_image>change_threshold);

%Check for segmentation  
if seg_flag
    Diff_image_seg=imabsdiff(rgb2gray(Image_ref_cut_seg),rgb2gray(Image_move_norm_seg));
    Diff_image_threshold_seg=Diff_image_seg.*uint8(Diff_image_seg>change_threshold);
end

if plot_Images
    figure(7), imshow(Diff_image_threshold); title("Difference Image with threshold applied");
end
%% Mark changes bigger than threshold in reconstructed moving Image in Red
%Mark changes in red channel of moving img
Image_Marked=Image_ref;
Image_Marked_red_channel=Image_Marked(:,:,1);
Image_Marked_red_channel(Diff_image_threshold>0)=255;
Image_Marked(:,:,1)=Image_Marked_red_channel;

%Check for segmentation  
if seg_flag
    %Image_Marked=Image_move_norm_seg;
    Image_Marked=Image_ref_cut_seg;
    Image_Marked_red_channel=Image_Marked(:,:,1);
    Image_Marked_red_channel(Diff_image_threshold_seg>0)=255;
    Image_Marked(:,:,1)=Image_Marked_red_channel;
end

%Check for segmentation  
if seg_flag && plot_Images
    figure(8)
    imshow(Image_Marked); 
    title('Reconstructed Segmentation Image with marked changes');
elseif plot_Images
    figure(8), 
    imshow(Image_Marked);
    title("Reconstructed Image with marked changes");
end



%% Differentiation of sizes of region of change
% This part allows for a differentiation between sizes of image changes.
% Changes that lie in image regions with only few changes can be filtered
% out, leaving changes that lie in regions with a lot change.
% It filters the mask obtained from the difference image with a lowpass
% filter, filtering out smaller regions of changes. This is a faster, but
% not so precise, alternative to the super pixels approach.
%
% Aspects: this is for comparing two images given the sliders for
% change_threshold and l_filter.
% The change_threshold is the minimal magnitude of change (0-100%) considered, with
% the best results usually being in found between 20% and 50%.
% The length of filter l_filter is propotional to the minimum size of change depicted and
% values from 3-200 are reasonable with the best results between 11 and 155.


if nargin==nargin(@Difference_Magnitude) %l_filter is given-> use function
    if l_filter>1 %condition to actually filter out smaller changes
        l_filter=l_filter-mod(l_filter,2)+1; %set to a valid filter length, just in case.
        
        diff_size_mask=Diff_image_threshold;
        diff_size_mask(diff_size_mask>0)=1;%set to one instead of 255 for better calculation
        %initialize guassian filter:
        sig=floor(l_filter/2)/2;
        x=-floor(l_filter/2):floor(l_filter/2);
        G=exp(-(x.^2)/(2*sig^2));
        G=G/sum(G);%normalize filter
        %apply filter:
        diff_size_mask=double(diff_size_mask);
        diff_size_mask=conv2(diff_size_mask,G,'same');
        diff_size_mask=conv2(diff_size_mask,G','same');
        diff_size_mask(abs(diff_size_mask)<0.15)=0;
        diff_size_mask(abs(diff_size_mask)>0)=1; %again set to 1 for better calculation in code below
        %This mask masks out the big regions of change.
        
        %improvement:
        %rebuild narrower filter to extend borders of regions. This is
        %necessary, because parts of the border fell away by thresholding
        %in the last step
         %tic
        sig=floor(l_filter/4)/2;
        x=-floor(l_filter/4):floor(l_filter/4);
        G=exp(-(x.^2)/(2*sig^2));
        G=G/sum(G);%normalize filter
        %widen boarders:
        diff_size_mask=conv2(diff_size_mask,G,'same');
        diff_size_mask=conv2(diff_size_mask,G','same');
        diff_size_mask(abs(diff_size_mask)>0.005)=1; %make it a mask
        %end improvement
        %extra_time=toc
        
        %now combine diff_size_mask and original difference image, to obtain the detailed differences in big regions of change:
        Diff_image_threshold=Diff_image_threshold.*uint8(diff_size_mask);
        %mark it in image:
        Image_Marked=Image_ref;%it might be better to show changes in the new image
        Image_Marked_red_channel=Image_Marked(:,:,1);
        Image_Marked_red_channel(Diff_image_threshold>0)=255;
        Image_Marked(:,:,1)=Image_Marked_red_channel;
        
    end
end


end %end of function

