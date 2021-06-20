
function Images_reconstructed_resized = resize_images(Images_reconstructed)

    numrows = 1000;
    numcols = 1600;
    n = length(Images_reconstructed);
    Images_reconstructed_resized = cell(1, n);
    
    for i = 1 : n
        
        Images_reconstructed_resized{i} = imresize(Images_reconstructed{i}, [numrows, numcols]);
        
    end

end