function [highlighted_image,mask]=Differentiate_size_of_change(I1,I2,tau,l,tau2)
%given: I1,I2 two aligned images(with I1 preferably beeing the older one), tau: threshold for strenghth of change, l:
%filter length, corresponds to selecting size
%output: regions with changes of that size
I1=im2double(I1);
I2=im2double(I2);
I1_g=rgb2gray(I1);
I2_g=rgb2gray(I2);

%get boundaries(copied from DIff_magnitude):
BW = im2uint8(I2_g); %Transform to Black&White
[~,L2,~,~] = bwboundaries(BW,'noholes');
BW = im2uint8(I1_g); %Transform to Black&White
[~,L1,~,~] = bwboundaries(BW,'noholes');


diff_imgs=abs(I2_g-I1_g).*L2.*L1;%difference image
%diff_imgs=1;
%preprocess difference image to logical map containing changes:
diff_imgs(abs(diff_imgs)<tau)=0; %minimum strength of considered changes
diff_imgs(abs(diff_imgs)>=tau)=1;
%use diff_mag function

%l=13;%odd number, depending on threshold
sig=floor(l/2)/2;
x=-floor(l/2):floor(l/2);
G=exp(-(x.^2)/(2*sig^2));
G=G/sum(G);%normalize filter
diff_imgs=conv2(diff_imgs,G,'same');
diff_imgs=conv2(diff_imgs,G','same');
%tau2=0.1; %strength of integral change to be adapted
diff_imgs(abs(diff_imgs)<tau2)=0; 
diff_imgs(abs(diff_imgs)>=tau2)=1;
%figure,imshow(diff_imgs);

%blend over new image: (as reddish blobbs)
test=zeros(size(I2));
mask=diff_imgs;
test(:,:,1)=diff_imgs;%into R-Channel
highlighted_image=im2double(I2)+0.5*test;
%figure,imshow(highlighted_image);
%figure, subplot(1,2,1), imshow(I1), subplot(1,2,2), imshow(I2);
end

