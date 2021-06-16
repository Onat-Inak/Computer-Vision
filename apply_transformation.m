function Image_transformed = apply_transformation(Image_ref,Image_move,tform)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

% This function applies a 2D transformation tform to the Image_move to make
% it have the same perspective as Image_ref
outputView = imref2d(size(Image_ref));
Image_transformed = imwarp(Image_move,tform,'OutputView',outputView);
end
