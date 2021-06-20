

function Difference_Magnitude_Reg_Ref(Images_reconstructed, Image_ref_number)

    images_comparison_ref = Images_reconstructed{Image_ref_number};
    n = length(Images_reconstructed);
    
    if n <= 3
        m = 1;
    elseif n <= 6
        m = 2; 
    elseif n <= 9
        m = 3;
    elseif n <= 12
        m = 4;
    else
        m = 5;
    end
    
    figure();
    for i = 1 : n

        images_comparison_changes = Images_reconstructed{i};
        change_threshold = 50;
        Image_Marked = Difference_Magnitude(images_comparison_changes, images_comparison_ref, change_threshold);
        subplot(3,m,i)
        imshow(Image_Marked); 
        sgtitle("Changes Regarding Reference Image");
        
    end