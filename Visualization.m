% 3. Display changes of n images in a timelapse or indivudual visualization

% 3.0 Extract years and months from Image Names and save the results to the corresponding arrays:
% Ignore the empty reconstructed images and save the new image cell to the variable 
% Images_reconstructed_new:

% 3.1 Apply Difference Magnitude for Threshold :

% 3.2 : Apply Difference Magnitude function regarding superpixels in a
    % timelapse and differ big, intermediate and small changes from
    % eachother : - red : big changes 
    %             - blue : intermediate changes
    %             - green : small changes
    

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You can see the results from indivudal segments stated above by changing
% the logical values apply_x_y = true/false or comparison_rg_first_img_x_y = true/false
% for example: 
% apply_3_1 = false;
% comparison_rg_first_img_3_1 = true;
%
% You can see all the adjustable parameters in Section 3.0 below :
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        function obj = Visualization(Images_reconstructed, Image_Names, trafos, Images, Image_ref_number)
            logic_vec = logical(zeros(1, length(Images_reconstructed)));
            years = zeros(1, length(Images_reconstructed));
            months = zeros(1, length(Images_reconstructed));
            iter = 1;
            temp_ref = zeros(1, length(Images_reconstructed));
            temp_ref(Image_ref_number) = 1;
            for i = 1 : length(Images_reconstructed)
                year_month_temp = cell2mat(Image_Names(i));
                years(i) = str2double(year_month_temp(1:4));
                months(i) = str2double(year_month_temp(6:7));
                if numel(Images_reconstructed{i}) == 0
                    logic_vec(i) = false;
                    trafos(i,:) = [];
                    trafos(:,i) = [];
                else
                    logic_vec(i) = true;
                    obj.Images_reconstructed_new{iter} = Images_reconstructed{i};
                    obj.Images_new{iter} = Images{i};
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
            obj.trafos_new = trafos;
        end
    
        % Choose the images that you want to analyze/ visualize further :
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
        
        % Define the parameters :
        function define_parameters(obj, varargin)
            default_num_visualization = 1;
            default_chosen_images = "all";
            default_threshold_DM = 50; % threshold for the Difference Magnitude function
            default_comparison_rg_first_img = true; % compare all the images regarding the first image in a timelapse plot
            default_comparison_rg_prev_img = false; % compare all the images regarding the previous image in a timelapse plot
            default_pause_duration = 1.5; % duration/time-difference between two different plots
            default_num_superpixels = 3000;
            default_threshold_SP_big = 30; % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
            default_threshold_SP_intermediate = 50;
            default_threshold_SP_small = 70;
            default_plot_big_changes = true;
            default_plot_intermediate_changes = true;
            default_plot_small_changes = true;
            
            parser = inputParser;
            
            % parameters, which are required everytime :
            addOptional(parser, 'num_visualization', default_num_visualization, @(x) isnumeric(x) && (x > 0) && (x <= 2));
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
            
            % parse the input variables with the defined parser object: 
            parse(parser, varargin{:});
            
            % define the variables in the Visualization Class :
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
        function apply_3_1(obj)
            % Get treshold, segmentation flag (implements segmentation) from GUI
            % and plot flag (plots each processing step)
            figure();
            hold on
            if obj.comparison_rg_prev_img
                title('Changes between Images regarding to their Previous Images');
                for img_num = 1 : length(obj.Images_reconstructed_new) - 1
                    ref_image = obj.Images_reconstructed_new{img_num};
                    moving_image = obj.Images_reconstructed_new{img_num + 1};
                    [ref_image, moving_image] = obj.Align_2_images(img_num, img_num + 1);
                    %Measure runtime and run difference calculation :
                    t_3_1 = tic;
                    [Image_Marked, ~] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag);
                    clf;
                    imshow(Image_Marked);
                    imshowpair(Image_Marked, moving_image, 'montage')
                    pause(obj.pause_duration);
                end
            end
            if obj.comparison_rg_first_img
                obj.Change_ref_im();
                for img_num = 2 : length(obj.Images_reconstructed_new)
                    ref_image = obj.Images_reconstructed_new{1};
                    moving_image = obj.Images_reconstructed_new{img_num};

                    %Measure runtime and run difference calculation
                    t_3_1 = tic;
                    [Image_Marked, ~] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag);
                    clf;
                    title('Changes between Images regarding to first Image');
                    imshowpair(Image_Marked, moving_image, 'montage')
                    pause(obj.pause_duration);
                end 
            end
            obj.duration_3_1 = toc(t_3_1);
            hold off
        end
        
        % 3.2 Apply Difference Magnitude function regarding superpixels in
        % a timelapse :
        function apply_3_2(obj)
            if obj.comparison_rg_prev_img
                t_3_3 = tic;
                figure();
                hold on
                for img_num = 1 : length(obj.Images_reconstructed_new) - 1
                    ref_image = obj.Images_reconstructed_new{img_num};
                    moving_image = obj.Images_reconstructed_new{img_num + 1};
                    [ref_image, moving_image] = obj.Align_2_images(img_num, img_num + 1);
                    [obj.superpixel_pos, N] = superpixels(ref_image, obj.num_superpixels, 'NumIterations', obj.num_iterations_SP);
                    [~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag);
                    Diff_Image_Threshold(Diff_Image_Threshold > 0) = 1;
                    
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
    %                 region_mask_biggest(:,:,1) = region_mask_red;
    %                 region_mask_biggest(:,:,2) = zeros(m, n);
    %                 region_mask_biggest(:,:,3) = zeros(m, n);

                    % intermediate changes -> blue
                    logical_region_mask_intermediate = logical(logical_region_mask_intermediate);
                    region_mask_blue(logical_region_mask_intermediate) = 255;
    %                 region_mask_intermediate(:,:,1) = zeros(m, n);
    %                 region_mask_intermediate(:,:,2) = zeros(m, n);
    %                 region_mask_intermediate(:,:,3) = region_mask_blue;

                    % low changes -> green
                    logical_region_mask_small = logical(logical_region_mask_small);
                    region_mask_green(logical_region_mask_small) = 255;
    %                 region_mask_low(:,:,1) = zeros(m, n);
    %                 region_mask_low(:,:,2) = region_mask_green;
    %                 region_mask_low(:,:,3) = zeros(m, n);

    %                 region_mask = region_mask_biggest + region_mask_intermediate + region_mask_low;

                    BM = boundarymask(obj.superpixel_pos);
        %             imshow(Images_reconstructed_new{1})
        %             figure();
        %             imshow(imoverlay(region_mask, BM, 'cyan'),'InitialMagnification',67)
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
                    % show the overlayed image without boundary mask :
%                     imshow(overlay);
                    imshowpair(overlay, moving_image, 'montage')
                    % show the overlayed image with boundary mask : 
    %                 imshow(imoverlay(overlay, BM, 'cyan'),'InitialMagnification',67);
                end
                hold off
                obj.duration_3_3 = toc(t_3_3);
            end
        
            if obj.comparison_rg_first_img
                obj.Change_ref_im();
                t_3_3 = tic;
                figure();
                hold on
                for img_num = 2 : length(obj.Images_reconstructed_new)
                    [obj.superpixel_pos, N] = superpixels(obj.Images_reconstructed_new{img_num}, obj.num_superpixels, 'NumIterations', obj.num_iterations_SP);
                    ref_image = obj.Images_reconstructed_new{1};
                    moving_image = obj.Images_reconstructed_new{img_num};
                    [~, Diff_Image_Threshold] = Difference_Magnitude(ref_image, moving_image, obj.threshold_DM, obj.plot_images, obj.seg_flag);
%                     boxKernel = ones(5,5); % Or whatever size window you want.
%                     Diff_Image_Threshold = conv2(Diff_Image_Threshold, boxKernel, 'same');
%                     size(Diff_Image_Threshold)
                    Diff_Image_Threshold(Diff_Image_Threshold > 0) = 1;

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
%                         if numel(Diff_Image_Threshold(pos_sp_reg_img)) < ((m * n) / N) * (20/100)
%                             break;
%                         end
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

    %                 region_mask = region_mask_biggest + region_mask_intermediate + region_mask_low;

                    BM = boundarymask(obj.superpixel_pos);
        %             imshow(Images_reconstructed_new{1})
        %             figure();
        %             imshow(imoverlay(region_mask, BM, 'cyan'),'InitialMagnification',67)
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
                    % show the overlayed image without boundary mask :
%                     imshow(overlay);
                    imshowpair(overlay, moving_image, 'montage')
                    % show the overlayed image with boundary mask : 
    %                 imshow(imoverlay(overlay, BM, 'cyan'),'InitialMagnification',67);
                end
                hold off
                obj.duration_3_3 = toc(t_3_3);
            end
        end
    end
end



