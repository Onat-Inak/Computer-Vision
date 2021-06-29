function [trafos_new,imstruct_new]=Change_ref_im(trafos,im_struct,ind_old_ref,ind_new_ref)
%This function changes the referencimage and the aligned images as well as the necessary
%transformations. Please read the instruction.

%inputs:
    %trafos: structure containing the transformation (just as usual)
    %im_struct: original images (not reconstructed images!!! Otherwise you would end up with nonsense (allready transformed))
    %ind_old_ref: index of the old reference image
    %ind_new_ref: index of new reference image, this must be a linked image (i.e.: trafos{ind_old_ref,ind_new_ref} must contain a valid trafo)
    

%output:
    %trafos_new: transformations to the orientation of the new reference image
    %imstruct_new: transformed images wrt. the new reference image
    
    
%basic idea is using the chain of transformations: im1->im_ref_new =
%im1->im_ref_old->im_ref_new, whereas the last transformation is just the
%inverse transformation of im_ref_new->im_ref_old. These transformations
%can be found in 'trafos'.

if isstring(trafos{ind_old_ref,ind_new_ref}) %the caller tries to transfor ont a not linked reference image-> throw error
    error('You are probably trying to convert to a not linked image, please consider using a different new reference image via ind_new_ref. If not successfull, also chech ind_old_ref.');
end



%initialize:
trafos_new=cell(size(trafos));
imstruct_new=cell(size(im_struct));

%for easier working: set element in trafos at position ind_old_ref to I (no
%case destinction later)
%trafos{ind_old_ref,ind_old_ref}=projective2d(eye(3));
%no longer needed, as initialized as I before

if isempty(trafos{ind_old_ref,ind_new_ref})
    error('Error due to empty field. ind_old_ref is probably wrong.');
end


%going over all images that could be linked:
for i=1:numel(im_struct)
    
    if ~isstring(trafos{ind_old_ref,i}) %check if linked (otherwise it contains a string)
    %calculate new trafo over above described chain:
    trafos_new{ind_new_ref,i}=projective2d((trafos{ind_old_ref,i}.T)/(trafos{ind_old_ref,ind_new_ref}.T));
    
    
    %apply trafo to image:
    imstruct_new{i}= apply_transformation(im_struct{ind_old_ref},im_struct{i},trafos_new{ind_new_ref,i});

    
    else %no trafo was found bevor -> not possoble to link-> insert "not Working" with a capital 'W' to maintain original structure
        trafos_new{ind_new_ref,i}='not Working'; %emphasis on the capital 'W'
    end
    
end


%Further explanation: https://www.youtube.com/watch?v=dQw4w9WgXcQ
    
    

end

