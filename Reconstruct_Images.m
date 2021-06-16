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
plot_Images=1;
%% Logic to concatenate transforms
% Goals:
% - As little transforms as possible (to not cut away too much of the picture)
% - As little tries as possible to normalize all to one image (to be more efficient / use less time)

%% 2.1) Choose Reference Image as the middle Image
Image_ref_number=ceil(length(Images)/2);
Image_ref=(Images{Image_ref_number}); %choose Image_ref as the middle Image
Images_reconstructed=cell(1,length(Images));
trafos=cell(length(Images));

%% 2.2.) Try direct (1-step) transformation from each picture to Image_ref

Trafo_status=zeros(1,length(Images)); %array, 1 at pos j if Trafo from image j to Image_ref worked, 0 else

for idx_Im_move_1step=1:length(Images) %Iterate over all Images
    if(idx_Im_move_1step~=Image_ref_number) %only transform non reference Images
        [tform_direct] = SURF_MSAC(Image_ref,Images{idx_Im_move_1step});
        
        
        if ~isempty(tform_direct)%Check if a trafo could be found
            Images_reconstructed{idx_Im_move_1step} = apply_transformation(Image_ref,Images{idx_Im_move_1step},tform_direct);
        else
            trafos{Image_ref_number,idx_Im_move_1step}="not Working";
            Images_reconstructed{idx_Im_move_1step}=0;
        end
        
        if ~sum(Images_reconstructed{idx_Im_move_1step}(:)) %Checks if Images_normalized is only black
            Trafo_status(idx_Im_move_1step)=0; %Only Black --> Trafo did not work. Go to step 1.3 (2-step Trafos)
            trafos{Image_ref_number,idx_Im_move_1step}="not working";
        else %Trafo worked --> safe it
            Trafo_status(idx_Im_move_1step)=1;
            trafos{Image_ref_number,idx_Im_move_1step}=tform_direct;
        end
        
    else
        Images_reconstructed{idx_Im_move_1step}=Image_ref;
        Trafo_status(idx_Im_move_1step)=1;
    end
end


% Plot all reconstructed pictures after first step in reconstruction
% algorithm if plot_Images=1
if plot_Images
    fig1=figure(1);
    set(fig1,'Name','Overview Reconstructed Images');
    for idx_plot=1:length(Images)
        subplot(3,ceil(length(Images)/3),idx_plot);
        imshow(Images_reconstructed{idx_plot}), title(sprintf('Image %d', idx_plot))
    end
    sgtitle(sprintf('Image %d was chosen as reference image', Image_ref_number)) 
end

%% 2.2.) Try 2-step transform where 1-step failed: failed Image --> next Image that worked (intermediate image) --> Reference Image
% Idea: At pictures where we could not find a 1-step transform, try a
% 2-step Transform, meaning we transform the image to the next image where
% we were able to find a 1-step transform to the Reference Image. For
% efficiency we try the neighboring images first, then the ones a bit
% further away and so on. In most cases we get a 2-step transform first try!

errors_1step=find(~Trafo_status); %List that contains all idx of pictures where we could not find a 1-step trafo

for Error_Image_idx=errors_1step %for all pictures where 1-step trafo did not work we try to find a 2-step trafo
    
    %Make a list (idx_try_2step) of 2-step trafos to try, sorted by likelihood
    %First we try closed ones, then the pcitures further away
        upstep=Error_Image_idx+1:length(Images); 
        upstep(upstep==Image_ref_number)=[]; % do not try the reference image
        downstep=Error_Image_idx-1:-1:1;
        downstep(downstep==Image_ref_number)=[];% do not try the reference image
     if length(downstep)>length(upstep)
         upstep =[upstep zeros(1,length(downstep)-length(upstep))]; %pad to make same size
     else
         downstep =[downstep zeros(1,length(upstep)-length(downstep))]; %pad to make same size
     end
        idx_try_2step=[upstep;downstep]; 
        idx_try_2step=idx_try_2step(idx_try_2step(:)~=0)'; 
        idx_try_2step(ismember(idx_try_2step,errors_1step))=[];%This is a list that gives an order to choose the middle image
        
        
    for inter_image_idx=idx_try_2step   %try all of the trafos possible, until one works, in efficient order      
        if Trafo_status(inter_image_idx) %Check if Trafo from that intermediate image to reference Image worked
            
             %step 1 from failed --> working intermediate image k
             
             [tform_indirect_step1] = SURF_MSAC(Images{inter_image_idx},Images{Error_Image_idx}); %get transform
             
             
             if ~isempty(tform_indirect_step1)%Check if a trafo could be found
                 Images_reconstructed_intermediate = apply_transformation(Images{inter_image_idx},Images{Error_Image_idx},tform_indirect_step1);
             else
                 trafos{inter_image_idx,Error_Image_idx}="not Working";
                 Images_reconstructed_intermediate=0;
             end
             
             %check if tform_indirect_step1 worked, so the trafo from failed Image -> working intermediate image
             if ~sum(Images_reconstructed_intermediate(:)) %Checks if Images_reconstructed_intermediate is only black
                Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work. Go to step 1.3 (2-step Trafos)
                trafos{inter_image_idx,Error_Image_idx}="not Working";
                continue %we can go to next for loop interation
             else
                Trafo_status(Error_Image_idx)=1;
                trafos{inter_image_idx,Error_Image_idx}=tform_indirect_step1;
             end
             
             
             %step 2 from next working intermediate image --> Ref Image
             %Apply the trafo which was already computed in the 1-step trafo part
             Images_reconstructed{Error_Image_idx} = apply_transformation(Image_ref,Images_reconstructed_intermediate,trafos{Image_ref_number,inter_image_idx});
             %check if worked
             if ~sum(Images_reconstructed{Error_Image_idx}(:)) %Checks if Images_normalized is only black
                Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work. Go to step 1.3 (2-step Trafos)
                trafos{Image_ref_number,inter_image_idx}="not Working in step 2 of 2-step";
             else
                Trafo_status(Error_Image_idx)=1;
                break %We can break the for loop if we found a working 2-step trafo
             end
        end
    end
end

%Plot Situation after 2-step Transforms if plot_Images==1
if plot_Images
    figure(1)
    for inter_image_idx=errors_1step
        subplot(3,ceil(length(Images)/3),inter_image_idx);
        imshow(Images_reconstructed{inter_image_idx}), title(sprintf('Image %d with 2 transforms', inter_image_idx))
    end
    sgtitle(sprintf('Image %d was chosen as reference image', Image_ref_number)) 
end
%% 2.3.) Try 3-step transform where 1&2-step failed: failed Image --> next Image that worked (intermediate image) --> Reference Image

end


