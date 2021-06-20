function Image_Marked = Difference_Magnitude(Image_ref,Image_move,change_threshold)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

plot_Images=0; %0 or 1


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
    figure(2); imshow(BW); title("Boundary at Moving Image"); hold on;
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

%% Threshold on change
Diff_image=imabsdiff(rgb2gray(Image_ref_cut),rgb2gray(Image_move_norm));
Diff_image_threshold=Diff_image.*uint8(Diff_image>change_threshold);
if plot_Images
    figure(6), imshow(Diff_image_threshold); title("Difference Image with threshold applied");
end
%% Mark changes bigger than threshold in reconstructed moving Image in Red

Image_Marked=Image_move_cut;
Image_Marked_red_channel=Image_Marked(:,:,1);
Image_Marked_red_channel(Diff_image_threshold>0)=255;
Image_Marked(:,:,1)=Image_Marked_red_channel;

if plot_Images
    figure(7), imshow(Image_Marked); title("Reconstructed Image with changes marked");
end

end %end of function

