

function Difference_Magnitude_Timelapse(Images_reconstructed)

    images_comparison_ref = Images_reconstructed{1};
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
    
    for i = 1 : n

        images_comparison_changes = Images_reconstructed{i};
        change_threshold=50;
        Image_Marked = Difference_Magnitude(images_comparison_ref,images_comparison_changes,change_threshold);
        subplot(3,m,i)
        imshow(Image_Marked); 
        sgtitle("Changes over Time");
        
    end
    


end