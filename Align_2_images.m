function [I1,I2]=Align_2_images(trafos, im_struct, ind_old_ref, ind1, ind2)
%tThis function transforms Image in2 into orientaton of Image ind 1
%The idea behind it is equivalently to Change_ref_im, now only with two images

%inputs:
    %trafos: structure containing the transformation (just as usual)
    %im_struct: original images (not reconstructed images!!! Otherwise you would end up with nonsense (allready transformed))
    %ind_old_ref: index of the old reference image
    %ind1: index of image to be aligned to
    %ind2: index of image that has to be transformed
    
%outputs:
    %I1: first image
    %I2: second image aligned wrt first one
    
%easier debuging:
if isempty(trafos{ind_old_ref,ind1})
    error('Error due to empty field. ind_old_ref is probably wrong.');
end

if isstring(trafos{ind_old_ref,ind1}) %the caller tries to transfor onto a not linked first image-> throw error
    error('You are probably trying to convert to a not linked image 1, please consider using a different image 1 via ind1. If not successfull, also chech ind_old_ref.');
end

if isstring(trafos{ind_old_ref,ind2}) %the caller tries to transfor from a not linked second image-> throw error
    error('You are probably trying to convert a not linked image 2, please consider using a different image 2 via ind2. If not successfull, also chech ind_old_ref.');
end



%actual function:
    
I1=im_struct{ind1}; %no change necesaary
trafo=projective2d((trafos{ind_old_ref,ind2}.T)/(trafos{ind_old_ref,ind1}.T));
I2=apply_transformation(im_struct{ind_old_ref},im_struct{ind2},trafo);

end
