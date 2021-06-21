function [BW,maskedImage] = segmentImage(X)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

%segmentImage Segment image using auto-generated code from imageSegmenter app
%  [BW,MASKEDIMAGE] = segmentImage(X) segments image X using auto-generated
%  code from the imageSegmenter app. The final segmentation is returned in
%  BW, and a masked image is returned in MASKEDIMAGE.
%----------------------------------------------------

% Adjust data to span data range.
X = imadjust(X);

% Threshold image - global threshold
BW = X > 127;

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;
end

