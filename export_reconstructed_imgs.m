function export_reconstructed_imgs(Images_reconstructed, fileNames_processed,folderName_processed)
%Code zum exportieren der normalisierten Bilder
%benötigt: folderName_processed, fileNames_processed, so wie
%Images_reconstructed aus der GUI

mkdir(strcat('Exported_Imgs/',folderName_processed))
for ever=1:numel(fileNames_processed)
filename=strcat('Exported_Imgs/',folderName_processed,'/',fileNames_processed{ever});
imwrite(Images_reconstructed{ever}, filename);
end

end