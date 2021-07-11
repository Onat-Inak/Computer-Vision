% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the Visualization Class. This class is used for visualization
% purposes and it's methods for the GUI integration. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. Display changes of n images in a timelapse or indivudual visualization

% 3.0 Extract years and months from Image Names and save the results to the corresponding arrays:
%     Ignore the empty reconstructed images and save the new image cell to the variable 
%     Images_reconstructed_new:

% 3.1 Apply Difference Magnitude for Threshold :

% 3.2 : Apply Difference Magnitude function regarding superpixels in a
    %   timelapse and differ big, intermediate and small changes from
    %   eachother : - red : big changes 
    %               - blue : intermediate changes
    %               - green : small changes
    
% 3.3 Apply Difference Highlights function and determine the most
%     changed pixels between chosen images :
        

classdef Visualization < handle
   
    % Properties that can be changed by the user/GUI :
    properties
        num_visualization
        chosen_images
        threshold_DM % threshold for the Difference Magnitude function
        comparison_rg_first_img % compare all the images regarding the first image in a timelapse plot
        comparison_rg_prev_img % compare all the images regarding the previous image in a timelapse plot
        pause_duration % duration/time-difference between two different plots
        num_superpixels
        threshold_SP_big % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
        threshold_SP_intermediate
        threshold_SP_small
        plot_big_changes
        plot_intermediate_changes
        plot_small_changes
        top_percentage_threshold
        threshold_l
    end
    
    % Properties that cannot be changed by the user/GUI :
    properties
        plot_background_img = 1;
        Images_reconstructed_new;
        years_new;
        months_new;
        superpixel_pos;
        num_iterations_SP = 5;
        seg_flag = 0;
        plot_images = 0;
        trafos_new;
        Images_new;
        Image_ref_number_new;
        ind_new_ref = 1;
        moving_image
        Image_Marked
        Image_Highlights
        Difference_Image_Highlight
        Diff_Image_Comparison
        Image_Names_new
        Images_reconstructed
        overlay
        Diff_Image_Threshold
        seg_mask
        folderName_processed
    end
    
    % Properties that are specific for corresponding type of visualization
    properties
        % parameters for 3.1 :
        duration_3_1 = [];

        %parameters for 3.3 :
        duration_3_3 = [];
    end
    
    
    methods
        % Constructor / 3.0:
        % -The images_reconstructed_new property is created from the
        % parameter Images_reconstructed by eliminating the images, by
        % which there were no transformation possibilities.
        % -The years and methods are gotten from the image names in the
        % folder for every single applicable image and saved in the
        % corresponding class properties.
        % -The elements of the transformation matrix, which correspond to
        % the images without possible transformation are eliminated from
        % the matrix.
        % -The original images corresponding the transformed images in the 
        % property Images_reconstructed_new are saved in the property
        % Images_new, to use the methods align_2_images and Change_ref_im
        % in further visualization options corresponding the chosen images
        % and selected visualization options by the user or regarding 
        % the selected folder.
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The constructor is essential for the methods of this class and
        % therefore must be initialized every time after the user changes
        % some options in the GUI!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Visualization(Images_reconstructed, Image_Names, trafos, Images, Image_ref_number)
            obj.Images_reconstructed = Images_reconstructed;
            logic_vec = logical(zeros(1, length(Images_reconstructed)));
            years = zeros(1, length(Images_reconstructed));
            months = zeros(1, length(Images_reconstructed));
            iter = 1;
            temp_ref = zeros(1, length(Images_reconstructed));
            temp_ref(Image_ref_number) = 1;
            for i = 1 : length(Images_reconstructed)
                %The years and methods are gotten from the image names
                year_month_temp = cell2mat(Image_Names(i));
                years(i) = str2double(year_month_temp(1:4));
                months(i) = str2double(year_month_temp(6:7));
                if numel(Images_reconstructed{i}) == 0
                    logic_vec(i) = false;
               else
                    logic_vec(i) = true;
                    obj.Images_reconstructed_new{iter} = Images_reconstructed{i};
                    obj.Images_new{iter} = Images{i};
                    obj.Image_Names_new{iter} = Image_Names{i};
                    iter = iter + 1;
                end
            end
            temp_ref = temp_ref(logic_vec);
            for k = 1 : length(obj.Images_reconstructed_new)
                if temp_ref(k) == 1
                    obj.Image_ref_number_new = k;
                end
            end
            obj.years_new = years(logic_vec);
            obj.months_new = months(logic_vec);
            trafos(~logic_vec,:) = [];
            trafos(:,~logic_vec) = [];
            obj.trafos_new = trafos;
        end
    
        % Choose the images that you want to analyze/ visualize further :
        % The Images_reconstructed_new is recreated regarding the chosen
        % images by the user. The parameter Images_reconstructed_new only
        % contains the selected images, if chosen_images parameter is not
        % set to "all". If it is set to "all", then all the transformed
        % images are stored in the corresponding preperty.
        function choose_images(obj, chosen_images)
            obj.chosen_images = sort(chosen_images);
            if string(obj.chosen_images) ~= "all"
                if ~all(obj.chosen_images <= length(obj.Images_reconstructed_new))
                    error("Choose the images you want to visualize correctly!");
                end
                temp_cell = cell(1, length(obj.chosen_images));
                for i = 1 : length(obj.chosen_images)
                    temp_cell{i} = obj.Images_reconstructed_new{obj.chosen_images(i)};
                end
                obj.Images_reconstructed_new = cell(1, length(obj.chosen_images));
                obj.Images_reconstructed_new = temp_cell;
            end
        end
        
        % Define the parameters, through the class parser:
        function define_parameters(obj, varargin)
            default_num_visualization = 1; %set if Difference Magnitude function shall be applied
            default_chosen_images = "all"; %set if all images will be analyzed
            default_threshold_DM = 50; %default threshold for the Difference Magnitude function
            default_comparison_rg_first_img = true; %compare all the images regarding the first image in a timelapse plot
            default_comparison_rg_prev_img = false; % compare all the images regarding the previous image in a timelapse plot
            default_pause_duration = 1.5; % duration/time-difference between two different plots
            default_num_superpixels = 3000; %set number of superpixels
            default_threshold_SP_big = 30; % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
            default_threshold_SP_intermediate = 50; % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
            default_threshold_SP_small = 70;% threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
            default_plot_big_changes = true; %mark if big changes will be shown
            default_plot_intermediate_changes = true; %mark if medium changes will be shown
            default_plot_small_changes = true; %mark if  small will be shown
            default_top_percentage_threshold = 10; %set default threshold for highlights function 
            default_threshold_l = 1; %set default area threshold
            
            parser = inputParser;
            
            %Add and check format of parameters, which are required in each viz mode:
            addOptional(parser, 'num_visualization', default_num_visualization, @(x) isinteger(x) && (x > 0) && (x <= 3));
            addOptional(parser, 'chosen_images', default_chosen_images, @(x) (isnumeric(x) && all(x <= length(obj.Images_reconstructed_new)) && all(x > 0)) || (string(x) == "all"));
            addOptional(parser, 'threshold_DM', default_threshold_DM);
            addOptional(parser, 'comparison_rg_first_img', default_comparison_rg_first_img, @(x) islogical(x));
            addOptional(parser, 'comparison_rg_prev_img', default_comparison_rg_prev_img, @(x) islogical(x));
            addOptional(parser, 'pause_duration', default_pause_duration, @(x) isnumeric(x) && (x > 0));
            addOptional(parser, 'num_superpixels', default_num_superpixels, @(x) isnumeric(x) && (x > 0));
            addOptional(parser, 'threshold_SP_big', default_threshold_SP_big, @(x) isnumeric(x) && (x > 0) && (x <= 100));
            addOptional(parser, 'threshold_SP_intermediate', default_threshold_SP_intermediate, @(x) isnumeric(x) && (x > 0) && (x <= 100));
            addOptional(parser, 'threshold_SP_small', default_threshold_SP_small, @(x) isnumeric(x) && (x > 0) && (x <= 100));
            addOptional(parser, 'plot_big_changes', default_plot_big_changes, @(x) islogical(x));
            addOptional(parser, 'plot_intermediate_changes', default_plot_intermediate_changes, @(x) islogical(x));
            addOptional(parser, 'plot_small_changes', default_plot_small_changes, @(x) islogical(x));
            addOptional(parser, 'top_percentage_threshold', default_top_percentage_threshold, @(x) isnumeric(x) && x <= 100 && x >= 0);
            addOptional(parser, 'threshold_l', default_threshold_l, @(x) isnumeric(x) && x >= 1);
            
            % parse the input variables with the defined parser object: 
            parse(parser, varargin{:});
            
            %Define the variables in the Visualization Class :
            obj.num_visualization = parser.Results.num_visualization;
            obj.choose_images(parser.Results.chosen_images);
            obj.threshold_DM = parser.Results.threshold_DM; 
            obj.comparison_rg_first_img = parser.Results.comparison_rg_first_img; 
            obj.comparison_rg_prev_img = parser.Results.comparison_rg_prev_img; 
            obj.pause_duration = parser.Results.pause_duration; 
            obj.num_superpixels = parser.Results.num_superpixels;
            obj.threshold_SP_big = parser.Results.threshold_SP_big; 
            obj.threshold_SP_intermediate = parser.Results.threshold_SP_intermediate;
            obj.threshold_SP_small = parser.Results.threshold_SP_small;
            obj.plot_big_changes = parser.Results.plot_big_changes;
            obj.plot_intermediate_changes = parser.Results.plot_intermediate_changes;
            obj.plot_small_changes = parser.Results.plot_small_changes;
            obj.top_percentage_threshold = parser.Results.top_percentage_threshold;
            obj.threshold_l = parser.Results.threshold_l;
        end
        
        % Aling_2_images function :
        function [I1,I2] = Align_2_images(obj, ind1, ind2)
            %tThis function transforms Image in2 into orientaton of Image ind 1
            %The idea behind it is equivalently to Change_ref_im, now only with two images

            %inputs:
                %trafos_new: structure containing the transformation (just as usual)
                %Images_new: original images (not reconstructed images!!! Otherwise you would end up with nonsense (allready transformed))
                %Image_ref_number_new: index of the old reference image
                %ind1: index of image to be aligned to
                %ind2: index of image that has to be transformed

            %outputs:
                %I1: first image
                %I2: second image aligned wrt first one

            %easier debuging:
            if isempty(obj.trafos_new{obj.Image_ref_number_new, ind1})
                error('Error due to empty field. Image_ref_number_new is probably wrong.');
            end

            if isstring(obj.trafos_new{obj.Image_ref_number_new,ind1}) %the caller tries to transfor onto a not linked first image-> throw error
                error('You are probably trying to convert to a not linked image 1, please consider using a different image 1 via ind1. If not successfull, also check Image_ref_number_new.');
            end

            if isstring(obj.trafos_new{obj.Image_ref_number_new,ind2}) %the caller tries to transfor from a not linked second image-> throw error
                error('You are probably trying to convert a not linked image 2, please consider using a different image 2 via ind2. If not successfull, also check Image_ref_number_new.');
            end

            %actual function:

            I1=obj.Images_new{ind1}; %no change necesaary
            trafo=projective2d((obj.trafos_new{obj.Image_ref_number_new,ind2}.T)/(obj.trafos_new{obj.Image_ref_number_new,ind1}.T));
            I2=apply_transformation(obj.Images_new{obj.Image_ref_number_new},obj.Images_new{ind2},trafo);

        end
            
        % Change reference image for visualization purposes :
        function Change_ref_im(obj)
            %This function changes the referencimage and the aligned images as well as the necessary
            %transformations. Please read the instruction.

            %inputs:
                %trafos_new: structure containing the transformation (just as usual)
                %Images_new: original images (not reconstructed images!!! Otherwise you would end up with nonsense (allready transformed))
                %Image_ref_number_new: index of the old reference image
                %ind_new_ref: index of new reference image, this must be a linked image (i.e.: trafos{Image_ref_number_new,ind_new_ref} must contain a valid trafo)


            %output:
                %trafos_new: transformations to the orientation of the new reference image
                %Images_reconstructed_new: transformed images wrt. the new reference image


            %basic idea is using the chain of transformations: im1->im_ref_new =
            %im1->im_ref_old->im_ref_new, whereas the last transformation is just the
            %inverse transformation of im_ref_new->im_ref_old. These transformations
            %can be found in 'trafos'.
            
            for count = 1 : numel(obj.Images_new)
                if ~isempty(obj.Images_reconstructed_new{count})
                    break;
                end
            end
            obj.ind_new_ref = count;

            
            if isstring(obj.trafos_new{obj.Image_ref_number_new, obj.ind_new_ref}) %the caller tries to transfor ont a not linked reference image-> throw error
                error('You are probably trying to convert to a not linked image, please consider using a different new reference image via ind_new_ref. If not successfull, also check Image_ref_number_new.');
            end
            
            %initialize:
            trafos_intern = cell(size(obj.trafos_new));
            obj.Images_reconstructed_new=cell(size(obj.Images_new));

            %for easier working: set element in trafos at position Image_ref_number_new to I (no
            %case destinction later)
            %trafos{Image_ref_number_new,Image_ref_number_new}=projective2d(eye(3));
            %no longer needed, as initialized as I before
            if isempty(obj.trafos_new{obj.Image_ref_number_new, obj.ind_new_ref})
                error('Error due to empty field. Image_ref_number_new is probably wrong.');
            end
            
            %going over all images that could be linked:
            for i=1:numel(obj.Images_new)
                if ~isstring(obj.trafos_new{obj.Image_ref_number_new,i}) %check if linked (otherwise it contains a string)
                    %calculate new trafo over above described chain:
                    trafos_intern{obj.ind_new_ref, i} = projective2d((obj.trafos_new{obj.Image_ref_number_new, i}.T)/(obj.trafos_new{obj.Image_ref_number_new, obj.ind_new_ref}.T));
                    %apply trafo to image:
                    obj.Images_reconstructed_new{i} = apply_transformation(obj.Images_new{obj.Image_ref_number_new}, obj.Images_new{i}, trafos_intern{obj.ind_new_ref, i});
                else %no trafo was found bevor -> not possoble to link-> insert "not Working" with a capital 'W' to maintain original structure
                    trafos_intern{obj.ind_new_ref,i} = 'not Working'; %emphasis on the capital 'W'
                end
            end
        %Further explanation: https://www.youtube.com/watch?v=dQw4w9WgXcQ
        end 
        
        % 3.1 Apply Difference Magnitude for different Threshold values :
        function apply_3_1(obj,seg_mask)
            obj.seg_mask = seg_mask;
            % Get treshold, segmentation flag (implements segmentation) from GUI
            % and plot flag (plots each processing step)
            hold on
            t_3_1 = tic;
            %For two image comparison
            if obj.comparison_rg_prev_img
                for img_num = 1 : length(obj.Images_reconstructed_new) - 1
                    ref_image = obj.Images_reconstructed_new{img_num};
                    obj.moving_image = obj.Images_reconstructed_new{img_num + 1};
                    %Allign both of the images to be compared using the
                    %allign 2 images function
                    if ~isstring(obj.chosen_images)
                        [ref_image, obj.moving_image] = obj.Align_2_images(obj.chosen_images(1), obj.chosen_images(2));
                    else
                        [ref_image, obj.moving_image] = obj.Align_2_images(img_num, img_num + 1);
                    end
                    %Run Difference Magnitude function with the chosen images:      
                    [~, obj.Diff_Image_Comparison] = Difference_Magnitude(ref_image, obj.moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag,obj.threshold_l);                  
                    %If segmentation mask was given, filter the calculated
                    %differences for the segmentated regions
                    if ~isempty(obj.seg_mask)
                        obj.Diff_Image_Comparison  = bsxfun(@times, obj.Diff_Image_Comparison, cast(obj.seg_mask, 'like', obj.Diff_Image_Comparison));
                    end
                    %Now combine diff_size_mask and original difference image, to obtain the detailed differences in big regions of change:
                    obj.Image_Marked=ref_image;%it might be better to show changes in the new image
                    Image_Marked_red_channel=obj.Image_Marked(:,:,1);
                    %Mark it in image:
                    Image_Marked_red_channel(obj.Diff_Image_Comparison>0)=255;
                    obj.Image_Marked(:,:,1)=Image_Marked_red_channel;
                    pause(obj.pause_duration);
                end
            end
            %This part is not actively used within our implementation, but
            %could be used later on, e.g. for historical timelape without
            %superpixels
            if obj.comparison_rg_first_img
                obj.Change_ref_im();
                for img_num = 2 : length(obj.Images_reconstructed_new)
                    ref_image = obj.Images_reconstructed_new{1};
                    obj.moving_image = obj.Images_reconstructed_new{img_num};
                    t_3_1 = tic;
                    [obj.Image_Marked, obj.Diff_Image_Comparison] = Difference_Magnitude(ref_image, obj.moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag);
                    clf;
                    pause(obj.pause_duration);
                end 
            end
            obj.duration_3_1 = toc(t_3_1);
            hold off
        end
        
        % 3.2 Apply Difference Magnitude function regarding superpixels in
        % a timelapse :
        function apply_3_2(obj,seg_mask,folderName_processed)
            obj.seg_mask  = seg_mask;
            obj.folderName_processed = folderName_processed;
            %For comparison timelapse
            if obj.comparison_rg_prev_img
                t_3_3 = tic;
                figure()
                %Iterate over images of timelapse
                for img_num = 1 : length(obj.Images_reconstructed_new) - 1
                    ref_image = obj.Images_reconstructed_new{img_num};
                    moving_image = obj.Images_reconstructed_new{img_num + 1};
                    %Allign the two current timelapse images
                    if ~isstring(obj.chosen_images)
                        [ref_image, moving_image] = obj.Align_2_images(obj.chosen_images(1), obj.chosen_images(2));
                    else
                        [ref_image, moving_image] = obj.Align_2_images(img_num, img_num + 1);
                    end
                    %Calculate superpixels, and apply Difference Magnitude
                    %function on the superpixel representation of the image
                    [obj.superpixel_pos, N] = superpixels(moving_image, obj.num_superpixels, 'NumIterations', obj.num_iterations_SP);
                    [~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag,obj.threshold_l);
                    Diff_Image_Threshold(Diff_Image_Threshold > 0) = 1;
                    
                    %If segmentation mask was given, filter the calculated
                    %differences for the segmentated regions
                    if ~isempty(obj.seg_mask)
                        Diff_Image_Threshold  = bsxfun(@times, Diff_Image_Threshold, cast(obj.seg_mask{img_num}, 'like', Diff_Image_Threshold));
                    end
                    
                    %Init superpixel masks
                    [m, n, ~] = size(obj.Images_reconstructed_new{1});
                    logical_region_mask_big = zeros(m, n); 
                    logical_region_mask_intermediate = zeros(m, n);
                    logical_region_mask_small = zeros(m, n);
                    region_mask_red = zeros(m, n);
                    region_mask_blue = zeros(m, n);
                    region_mask_green = zeros(m, n);
                    region_mask = zeros(m, n, 3);
                    region_mask_big = zeros(m, n, 3);
                    region_mask_intermediate = zeros(m, n, 3);
                    region_mask_small = zeros(m, n, 3);

                    biggest_change_mean = 0;
                    for sp = 1 : N
                        pos_sp_reg_img = (obj.superpixel_pos == sp);
                        mean_change_in_sp = sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') / numel(Diff_Image_Threshold(pos_sp_reg_img));
                        if mean_change_in_sp > biggest_change_mean
                            biggest_change_mean = mean_change_in_sp;
                        end
                    end

                    th_SP_big = biggest_change_mean * (100 - obj.threshold_SP_big) / 100;
                    th_SP_intermediate = biggest_change_mean * (100 - obj.threshold_SP_intermediate) / 100;
                    th_SP_small = biggest_change_mean * (100 - obj.threshold_SP_small) / 100;
                    
                    for sp = 1 : N
                        pos_sp_reg_img = (obj.superpixel_pos == sp);
                        mean_change_in_sp = sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') / numel(Diff_Image_Threshold(pos_sp_reg_img));
                        if mean_change_in_sp > th_SP_big
                            logical_region_mask_big = logical_region_mask_big + pos_sp_reg_img;
                        elseif mean_change_in_sp > th_SP_intermediate
                            logical_region_mask_intermediate = logical_region_mask_intermediate + pos_sp_reg_img;
                        elseif mean_change_in_sp > th_SP_small
                            logical_region_mask_small = logical_region_mask_small + pos_sp_reg_img; 
                        else
                            continue;
                        end       
                    end
                    % biggest changes -> red
                    logical_region_mask_big = logical(logical_region_mask_big);
                    region_mask_red(logical_region_mask_big) = 255;

                    % intermediate changes -> blue
                    logical_region_mask_intermediate = logical(logical_region_mask_intermediate);
                    region_mask_blue(logical_region_mask_intermediate) = 255;

                    % low changes -> green
                    logical_region_mask_small = logical(logical_region_mask_small);
                    region_mask_green(logical_region_mask_small) = 255;


                    BM = boundarymask(obj.superpixel_pos);
                    if ~obj.plot_big_changes && ~obj.plot_intermediate_changes && ~obj.plot_small_changes
                        error("Select at least one option : 1) big change 2) intermediate change 3) small change");
                    elseif obj.plot_big_changes && ~obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_red, 'red');
                    elseif ~obj.plot_big_changes && obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_blue, 'blue');
                    elseif ~obj.plot_big_changes && ~obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_green, 'green');  
                    elseif obj.plot_big_changes && obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_blue, 'blue');
                    elseif obj.plot_big_changes && ~obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    elseif ~obj.plot_big_changes && obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(ref_image, region_mask_blue, 'blue');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    else
                        overlay = imoverlay(ref_image, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_blue, 'blue');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    end
                    clf
                    overlay(ref_image == 0) = 0;
                    imshowpair(overlay, moving_image, 'montage');
                    title(sprintf("Comparison timelapse for %s",obj.folderName_processed));
                end
                obj.duration_3_3 = toc(t_3_3);
            end
            %For historical timelapse
            if obj.comparison_rg_first_img
                obj.Change_ref_im();
                t_3_3 = tic;
                figure();
                %Iterate over images of timelapse
                for img_num = 2 : length(obj.Images_reconstructed_new)
                    %Calculate superpixels, and apply Difference Magnitude
                    %function on the superpixel representation of the image
                    [obj.superpixel_pos, N] = superpixels(obj.Images_reconstructed_new{img_num}, obj.num_superpixels, 'NumIterations', obj.num_iterations_SP);
                    ref_image = obj.Images_reconstructed_new{1};
                    moving_image = obj.Images_reconstructed_new{img_num};
                    [~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag,obj.threshold_l);
                    Diff_Image_Threshold(Diff_Image_Threshold > 0) = 1;
                    
                    %If segmentation mask was given, filter the calculated
                    %differences for the segmentated regions
                    if ~isempty(obj.seg_mask)
                        Diff_Image_Threshold  = bsxfun(@times, Diff_Image_Threshold, cast(obj.seg_mask{img_num}, 'like', Diff_Image_Threshold));
                    end

                    [m, n, ~] = size(obj.Images_reconstructed_new{1});
                    logical_region_mask_big = zeros(m, n); 
                    logical_region_mask_intermediate = zeros(m, n);
                    logical_region_mask_small = zeros(m, n);
                    region_mask_red = zeros(m, n);
                    region_mask_blue = zeros(m, n);
                    region_mask_green = zeros(m, n);

                    biggest_change_mean = 0;
                    for sp = 1 : N
                        pos_sp_reg_img = (obj.superpixel_pos == sp);
                        mean_change_in_sp = sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') / numel(Diff_Image_Threshold(pos_sp_reg_img));
                        if mean_change_in_sp > biggest_change_mean
                            biggest_change_mean = mean_change_in_sp;
                        end
                    end

                    th_SP_big = biggest_change_mean * (100 - obj.threshold_SP_big) / 100;
                    th_SP_intermediate = biggest_change_mean * (100 - obj.threshold_SP_intermediate) / 100;
                    th_SP_small = biggest_change_mean * (100 - obj.threshold_SP_small) / 100;
                    
                    for sp = 1 : N
                        pos_sp_reg_img = (obj.superpixel_pos == sp);
                        mean_change_in_sp = sum(Diff_Image_Threshold(pos_sp_reg_img), 'all') / numel(Diff_Image_Threshold(pos_sp_reg_img));
                        if mean_change_in_sp > th_SP_big
                            logical_region_mask_big = logical_region_mask_big + pos_sp_reg_img;
                        elseif mean_change_in_sp > th_SP_intermediate
                            logical_region_mask_intermediate = logical_region_mask_intermediate + pos_sp_reg_img;
                        elseif mean_change_in_sp > th_SP_small
                            logical_region_mask_small = logical_region_mask_small + pos_sp_reg_img; 
                        else
                            continue;
                        end       
                    end
                    % biggest changes -> red
                    logical_region_mask_big = logical(logical_region_mask_big);
                    region_mask_red(logical_region_mask_big) = 255;

                    % intermediate changes -> blue
                    logical_region_mask_intermediate = logical(logical_region_mask_intermediate);
                    region_mask_blue(logical_region_mask_intermediate) = 255;

                    % low changes -> green
                    logical_region_mask_small = logical(logical_region_mask_small);
                    region_mask_green(logical_region_mask_small) = 255;


                    BM = boundarymask(obj.superpixel_pos);
                    if ~obj.plot_big_changes && ~obj.plot_intermediate_changes && ~obj.plot_small_changes
                        error("Select at least one option : 1) big change 2) intermediate change 3) small change");
                    elseif obj.plot_big_changes && ~obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_red, 'red');
                    elseif ~obj.plot_big_changes && obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_blue, 'blue');
                    elseif ~obj.plot_big_changes && ~obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_green, 'green');  
                    elseif obj.plot_big_changes && obj.plot_intermediate_changes && ~obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_blue, 'blue');
                    elseif obj.plot_big_changes && ~obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    elseif ~obj.plot_big_changes && obj.plot_intermediate_changes && obj.plot_small_changes
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_blue, 'blue');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    else
                        overlay = imoverlay(obj.Images_reconstructed_new{obj.plot_background_img}, region_mask_red, 'red');
                        overlay = imoverlay(overlay, region_mask_blue, 'blue');
                        overlay = imoverlay(overlay, region_mask_green, 'green');
                    end
                    clf
                    overlay(obj.Images_reconstructed_new{obj.plot_background_img} == 0) = 0;
                    imshowpair(overlay, moving_image, 'montage')
                    title(sprintf("Historical timelapse for %s",obj.folderName_processed));
                end
                obj.duration_3_3 = toc(t_3_3);
            end
        end
        
        % 3.3 Apply Difference Highlights function and determine the most
        % changed pixels between chosen images :
        function apply_3_3(obj)
                obj.ind_new_ref = 1;
                obj.Change_ref_im();
                Diff_image_acc = (zeros(size(obj.Images_reconstructed_new{1},[1,2])));
                for i = 1 : length(obj.Images_reconstructed_new) - 1
                    Image_ref = obj.Images_reconstructed_new{i};
                    Image_move = obj.Images_reconstructed_new{i + 1};
                    %% Get and show Boundaries of reconstructed Moving Image
                    BW = im2uint8(rgb2gray(Image_move)); %Transform to Black&White
                    [B, L, ~, ~] = bwboundaries(BW, 'noholes');
                    if(size(B, 1) > 1)
                        for n = 2 : length(B)
                            L([B{n}(:, 1)],[B{n}(:, 2)]); %
                        end
                        B(2 : end) = []; %Set B to only have length 1 (main boundary)

                    end
                    % Showing the boundaries:
                    if obj.plot_images
                        figure(2), imshow(BW); title("Boundary at Moving Image"); hold on;
                        for k=1:length(B)
                          boundary = B{k};
                          plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
                        end
                    end
                    %% Cut Reference Image
                    %Cut Reference Image
                    Image_ref_cut=Image_ref.*uint8(L);

                    %% Get and show Boundaries of cut reference Image
                    BW_ref = im2uint8(rgb2gray(Image_ref_cut)); %Transform to Black&White
                    [B,L_ref,~,~] = bwboundaries(BW_ref,'noholes');
                    if(size(B,1)>1)
                        for n=2:length(B)
                            L_ref([B{n}(:,1)],[B{n}(:,2)]); %
                        end
                        B(2:end)=[]; %Set B to only have length 1 (main boundary)

                    end
                    % Showing the boundaries:
                    if obj.plot_images
                        figure(3), imshow(BW_ref); title("Boundary at Reference Image"); hold on;
                        for k=1:length(B)
                          boundary = B{k};
                          plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
                        end
                    end
                    %% Cut moving Image and normalize moving Image
                    %Cut moving Image
                    Image_move_cut=Image_move.*uint8(L_ref);
                    Image_move_norm = histeq(Image_move_cut,imhist(Image_ref_cut));
                     %Image_move_norm=Image_move_cut;

                    if obj.plot_images
                        figure(4)
                            subplot(2,1,1)
                            imshowpair(Image_ref_cut,Image_move,'montage'); title('Cut Reference Image vs Moving Image')

                            subplot(2,1,2)
                            imshowpair(Image_ref_cut,Image_move_norm,'montage'); title('Cut Reference Image vs Normalized Moving Image')

                        figure(5),imshowpair(Image_ref_cut,Image_move_norm,'diff'); title("Difference Image between Reference and Moving Image")
                    end

                    %% Threshold on change
                    %Calculate absolute pixel difference between reference and moving img
                    Diff_image_iteration=imabsdiff(rgb2gray(Image_ref_cut),rgb2gray(Image_move_norm));

                    Diff_image_acc=Diff_image_acc+im2double(Diff_image_iteration);
                end
                if obj.plot_images
                figure(10)
                imshow(Diff_image_acc);
                end


                [~,Indexes]=sort(Diff_image_acc(:),'ascend');
                Diff_image_acc(Indexes(1:round(numel(Diff_image_acc)*(1 - obj.top_percentage_threshold/100))))=0;


                if obj.plot_images
                figure(11)
                imshow(Diff_image_acc); title("Difference Image with threshold applied");
                end


                %% Mark changes bigger than threshold in reconstructed moving Image in Red
                %Mark changes in red channel of moving img
                Image_Highlights = obj.Images_reconstructed_new{1};
                Image_Marked_red_channel=Image_Highlights(:,:,1);
                Image_Marked_red_channel(Diff_image_acc>0)=255;
                Image_Highlights(:,:,1)=Image_Marked_red_channel;
                obj.Difference_Image_Highlight = Diff_image_acc;


        end
    end
end



