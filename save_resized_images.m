

function save_resized_images(Images_reconstructed_resized, Name_of_Image_Folder)

    foldername = 'Resized_Images';
    if ~exist(foldername, 'dir')
        % Folder does not exist so create it.
        mkdir(foldername);
    end
    mkdir foldername Name_of_Image_Folder;
    save(fullfile(fileparts(mfilename('fullpath')), foldername, Name_of_Image_Folder, '.mat'), 'Images_reconstructed_resized');
    
    for i = 1 : length(Images_reconstructed_resized) 
        image_to_save_jpg = Images_reconstructed_resized{i};
%         imshow(image_to_save_jpg);
        filename = append(Name_of_Image_Folder, int2str(i));
        imwrite(image_to_save_jpg, append(filename, '.jpg'));
%         saveas(gcf, fullfile(fileparts(mfilename('fullpath')), foldername, Name_of_Image_Folder), append(filename, '.jpg'));
    end
    
end