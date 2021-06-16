% Importing the first image (reference):
%Image = imread('2015_02.jpg');
% Image=rgb2gray(Image(1:end-60,1:end,:));
Image = Reconstructed_Images{1,2};
% Importing the second image:
%BW1 = imread('2018_10.jpg');
% BW1=rgb2gray(BW1(1:end-60,1:end,:));
BW1 = Reconstructed_Images{1,1};


% clear all
close all
% clc



BW = im2uint8(Image);
[B,L,N,A] = bwboundaries(BW);
% Showing the boundaries:
figure, imshow(BW); hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B)
  boundary = B{k};
  cidx = mod(k,length(colors))+1;
  plot(boundary(:,2), boundary(:,1),...
       colors(cidx),'LineWidth',2);
  % Randomize text position for better visibility
  rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
  col = boundary(rndRow,2); row = boundary(rndRow,1);
  h = text(col+1, row-1, num2str(L(row,col)));
  set(h,'Color',colors(cidx),...
      'FontSize',14,'FontWeight','bold');
end
% figure; spy(A);


[B1,L1,N1,A1] = bwboundaries(BW1);
% Showing the boundaries:
figure, imshow(BW1); hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for y=1:length(B1)
  boundary1 = B1{y};
  cidx1 = mod(y,length(colors))+1;
  plot(boundary1(:,2), boundary1(:,1),...
       colors(cidx1),'LineWidth',2);
  % Randomize text position for better visibility
  rndRow1 = ceil(length(boundary1)/(mod(rand*y,7)+1));
  col1 = boundary1(rndRow,2); row1 = boundary1(rndRow,1);
  h1 = text(col1+1, row1-1, num2str(L(row1,col1)));
  set(h1,'Color',colors(cidx1),...
      'FontSize',14,'FontWeight','bold');
end
% figure; spy(A1);
% Resizing the second image to match the size of the first image:
[rowsA colsA RGBA]=size(BW);
[rowsB colsB RGBB]=size(BW1);
C=imresize(BW1,[rowsB colsB]);
% Showing the images next to each other:
figure;
imshowpair(BW,C,'diff'); title("difference Image")
% The following two lines do the same thing that the function above does:
% K = imabsdiff(BW,C);
% figure, imshow(K,[])
% Showing the images on top of each other in black and white:
figure;
imshowpair(BW,C,'montage'); title("Both Pictures")
% Showing the images on top of each other:
figure;
imshowpair(BW,C,'blend','Scaling','joint'); title("Blended together")
% K = imabsdiff(BW,C);
% figure, imshow(K,[])