function export_reconstructed_imgs(Images_reconstructed, fileNames_processed,folderName_processed)
%Code used to export the normalized images
%required inputs: folderName_processed, fileNames_processed, as well as
%Images_reconstructed from the GUI

mkdir(strcat('Exported_Imgs/',folderName_processed)) %create directory

for ever=1:numel(fileNames_processed)%go throug all reconstructed images
filename=strcat('Exported_Imgs/',folderName_processed,'/',fileNames_processed{ever});%generate filename
imwrite(Images_reconstructed{ever}, filename);%save image
end

end
