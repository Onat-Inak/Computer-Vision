function [Images_reconstructed, trafos] = Reconstruct_Images(Images)
% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

% Reconstructs Images so that they are all adapted to the Reference Image, 
% meaning they are taken from the same point in space, showing the same
% location. Here we have the logic implemented to efficiently call our 
% SURF + MSAC Algorithm. 
%   Images                   Cell array of Dimensions 1 x #ofImages, original images
% 
%   Images_reconstructed     Cell array of Dimensions 1 x #ofImages, All adapted to reference picture
%   trafos                   Cell array of Dimensions #ofImages x#ofImages,contains all calculated working transforms
%                            trafos(i,j) describes the transform from j-th Image to i-th Image as reference Image
plot_Images=1; %Decide to plot the reconstructed Images for Testing purposes
%% Logic to concatenate transforms
% Goals:
% - As little transforms as possible (to not cut away too much of the picture)
% - As little tries as possible to normalize all to one image (to be more efficient / use less time)

%% 2.1) Choose Reference Image as the middle Image
Image_ref_number=ceil(length(Images)/2);
Image_ref=(Images{Image_ref_number}); %choose Image_ref as the middle Image
Images_reconstructed=cell(1,length(Images));
trafos=cell(length(Images));

% For reference picture we already know transform and reconstructed Image
trafos{Image_ref_number,Image_ref_number} = projective2d;
Images_reconstructed{Image_ref_number}=Image_ref;

concatenation=mat2cell(zeros(length(Images),(length(Images)-1)),ones(length(Images),1));%save the chains
Trafo_status=zeros(1,length(Images)); %array, 1 at pos j if Trafo from image j to Image_ref worked, 0 else
Trafo_status(Image_ref_number)=1;

%% 2.2.) Try x-step transform
% Idea: Try all 1-step transformations to the reference picture first.
% At pictures where we could not find a 1-step transform, try a
% 2-step Transform, meaning we transform the image to the next image where
% we were able to find a 1-step transform to the Reference Image. For
% efficiency we try the neighboring images first, then the ones a bit
% further away and so on. In most cases we get a 2-step transform first try!
% If the two step transforms did not work we try all possible 3-step
% transforms that could potentially yield a working chaining of trafos.
% The logic for selecting which of the transformations are left to be
% calculated is based on graph theory and guarantees that all possible
% combinations are tried!

for x_step_transform=1:length(Images)-1 %max is a length(Images)-1 step transform
    
    errors_pre_step=find(~Trafo_status); %List that contains all idx of pictures where we could not find a (x-1)-step trafo
    for Error_Image_idx=errors_pre_step %for all pictures where (x-1)-step trafo did not work we try to find a x-step trafo
        
        
        %% 2.2.1 Logic to find transformations
        % Find all potentially successfull transformations with as little
        % calculations as possible. idx_try_find_trafo contains all destinations
        % of transformations that could work, starting from the Image we
        % are currently trying to adapt to the reference picture in
        % x_step_transform steps
        
        if(x_step_transform==1) %We only try a direct trafo to the reference Image in a 1-step trafo
            idx_try_find_trafo=Image_ref_number;
        else %if we need to concatenate at least 2 transforms
            %Make a list (idx_try_step) of single-step trafos to next intermediate image to try, sorted by likelihood
            %First we try close ones, then the pcitures further away
            upstep=Error_Image_idx+1:length(Images); 
            upstep(upstep==Image_ref_number)=[]; % do not try the reference image
            downstep=Error_Image_idx-1:-1:1;
            downstep(downstep==Image_ref_number)=[];% do not try the reference image
             if length(downstep)>length(upstep)
                 upstep =[upstep zeros(1,length(downstep)-length(upstep))]; %pad to make same size
             else
                 downstep =[downstep zeros(1,length(upstep)-length(downstep))]; %pad to make same size
             end
            idx_try_find_trafo=[upstep;downstep]; 
            idx_try_find_trafo=idx_try_find_trafo(idx_try_find_trafo(:)~=0)';  %filter out padding zeros
            idx_try_find_trafo(~cellfun('isempty',trafos(idx_try_find_trafo,Error_Image_idx)))=[]; %filter out previously tried trafos
            idx_try_find_trafo(ismember(idx_try_find_trafo,errors_pre_step))=[];%This is a list that gives an order to choose the middle image
        end
        
        if(isempty(idx_try_find_trafo))
            break %no transformation for that image could be found with x_step_transform steps
        end
    
        
        %% 2.2.2 Calculating the needed transforms and concatenation of them
        % We calculate all the transforms, specified by idx_try_find_trafo. So
        % we only calculate 1-step transforms from our current moving image
        % to the intermediate image specified in idx_try_find_trafo and
        % from there go the x_step_transform -2 transfroms that are already
        % calculated! This is a very efficient and extensive way!
        
        
        % Calculate and checking the transformation
        for inter_image_idx=idx_try_find_trafo   %try all of the trafos possible, until one works, in efficient order      
            if Trafo_status(inter_image_idx) %Check if Trafo from that intermediate image to reference Image worked

                 [tform_indirect_step1] = SURF_MSAC(Images{inter_image_idx},Images{Error_Image_idx}); %get transform

                 if isempty(tform_indirect_step1) || ~Check_Transform(tform_indirect_step1)%Check if a trafo could not be found
%                   if isempty(tform_indirect_step1) %Check if a trafo could not be found
                     trafos{inter_image_idx,Error_Image_idx}="not Working";
                     Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work
                     continue %we can go to next for loop interation
                 else
                     trafos{inter_image_idx,Error_Image_idx}=tform_indirect_step1;
                     concatenation{Error_Image_idx}(x_step_transform)=inter_image_idx;
                     Trafo_status(Error_Image_idx)=1;
                 end

                 % go along the chain of transforms:
                 concatenation{Error_Image_idx}=concatenation{Error_Image_idx}+concatenation{inter_image_idx};
                 transform_chain=tform_indirect_step1; %just an initialization of transform_chain
                 
                 % Concatenate the transform from moving Image ->intermediate Image and the x-2 step one from
                 % intermediate Image --> reference Image
                 transform_chain.T = trafos{inter_image_idx,Error_Image_idx}.T * trafos{Image_ref_number,inter_image_idx}.T;
                 Images_reconstructed{Error_Image_idx} = apply_transformation(Image_ref,Images{Error_Image_idx},transform_chain);
                 
                 % Check if everything worked
                 if ~sum(Images_reconstructed{Error_Image_idx}(:)) %Checks if Images_normalized is only black
                    Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work. Go to step 1.3 (2-step Trafos)
                    trafos{inter_image_idx,Error_Image_idx}="not Working";
                    concatenation{Error_Image_idx}(:)=0;
                    Images_reconstructed{Error_Image_idx}=[];
                 else
                    Trafo_status(Error_Image_idx)=1;
                    trafos{Image_ref_number,Error_Image_idx}=transform_chain;
                    break %We can break the for loop if we found a working 2-step trafo
                 end
            end
        end
    end
end

%Plot Situation 
if plot_Images
    figure(1)
    for image__plot_idx=1:length(Images)
        subplot(3,ceil(length(Images)/3),image__plot_idx);
        imshow(Images_reconstructed{image__plot_idx}), title(sprintf('Image %d, Nr. of transformations: %d',image__plot_idx, nnz(concatenation{image__plot_idx})))
    end
    sgtitle(sprintf('Image %d was chosen as reference image!', Image_ref_number)) 
end
end


