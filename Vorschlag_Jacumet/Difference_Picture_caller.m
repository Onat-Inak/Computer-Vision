%% Plot differences between images
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
clear all
tic

load('Reconstructed_Images_Kuwait.mat')
Image_ref=(Images{7});
Image_move=(Images{5});
tform=Image_transforms{7,5};

%Plot reference picture and moving picture
fig=figure;
set(fig,'Name','Reference and Moving Image');
imshowpair(Image_ref,Image_move,'montage'); title('Reference Image vs Moving Image')


%Plot changes dependant on threshhold for changes
fig=figure;
set(fig,'Name','Change in Change_threshold');
for i=10:10:120
    Image_Marked=Difference_Func(Image_ref,Image_move,tform,i);
    subplot(3,4,i/10)
    imshow(Image_Marked)
    title(sprintf('Changes with threshold > %d', i))
end
sgtitle(sprintf('Images with varying threshold on changes')) 
toc



function Image_Marked = Difference_Func(Image_ref,Image_move,tform,change_threshold)
plot_Images=0; %0 or 1

%% Cut Images and transform moving Image
Image_move = Image_move(1:end-60,1:end,:)+1;
Image_ref = Image_ref(1:end-60,1:end,:);

if plot_Images
    figure(1), imshowpair(Image_ref,Image_move,'montage'); title('Reference Image vs Moving Image')
end 
% Transform moving Image
outputView = imref2d(size(Image_ref));
Image_move_recon = imwarp(Image_move,tform,'OutputView',outputView);

%% Get and show Boundaries of reconstructed Moving Image
BW = im2uint8(rgb2gray(Image_move_recon)); %Transform to Black&White
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
%% Cut Reference Image and normalize moving Image
%Cut Reference Image
Image_ref_cut=Image_ref.*uint8(L);
Image_move_recon_norm = histeq(Image_move_recon,imhist(Image_ref_cut));

if plot_Images
    figure(3)
        subplot(2,1,1)
        imshowpair(Image_ref_cut,Image_move_recon,'montage'); title('Cut Reference Image vs Moving Image')

        subplot(2,1,2)
        imshowpair(Image_ref_cut,Image_move_recon_norm,'montage'); title('Cut Reference Image vs Normalized Moving Image')

    figure(4),imshowpair(Image_ref_cut,Image_move_recon_norm,'diff'); title("Difference Image between Reference and Moving Image")
end 

%% Threshold on change
Diff_image=imabsdiff(rgb2gray(Image_ref_cut),rgb2gray(Image_move_recon_norm));
Diff_image_threshold=Diff_image.*uint8(Diff_image>change_threshold);
if plot_Images
    figure(5), imshow(Diff_image_threshold); title("Difference Image with threshold applied");
end
%% Mark changes bigger than threshold in reconstructed moving Image in Red

Image_Marked=Image_move_recon;
Image_Marked_red_channel=Image_Marked(:,:,1);
Image_Marked_red_channel(Diff_image_threshold>0)=255;
Image_Marked(:,:,1)=Image_Marked_red_channel;

if plot_Images
    figure(6), imshow(Image_Marked); title("Reconstructed Image with changes marked");
end

end %end of function

