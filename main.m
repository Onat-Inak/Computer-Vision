%% Read imgs
% Import satellite images from specified folder
dir_path = "/Users/adammisik/Documents/01_TUM/02_Master/01_Kernmodule/Computer_Vision/SS_2021/Final_Project/git/Datasets/Dubai";
dir_list  = dir(fullfile(dir_path, '*.jpg'));
files = {dir_list.name};

imgs = cell(1,length(files));

%Loop through img files 
for j=1:length(files)
  fullFileName = fullfile(dir_path, files{j});
  img = imread(fullFileName);
  imgs{j} = {img};
end  
%% Implement reconstruction pipeline through robust fundamental/essential matrix estimation
%1.Approach: SURF+RANSAC. 
%To-Do: Extract movements T,R and do projection
EF = reconstructSURF_RANSAC(imgs);

