classdef GUI < handle
    properties (Access = public)
    gui_fig
    hp0
    TUM_Logo
    WelcomeMSG
    Sat_Logo
    hp1
    ImportButton1
    DropdownFolder
    hp2
    ImageGraph
    GraphTitle
    SegGraphTitle
    hp3
    SegImgGraph
    AllRegionsButton
    LandButton
    SeaButton
    CityButton
    SpecialLandscapeButton
    RunButton1
    hp4
    IntensitySlider
    IntensitySliderTitle
    AreaSlider
    AreaSliderTitle
    SpeedSlider
    SpeedSliderTitle
    DisplayButtons
    DisplayButton1
    DisplayButton2
    DisplayButton3
    ModeButton1
    ModeButton2
    ModeButton3
    ModeButton4
    ParameterButtons
    RunButton2
    RunButton3
    hp5
    folderName
    fileNames
    fileNames_new
    fileNames_processed
    fileNames_processed1
    fileNames_processed2
    filename
    img
    Seg_Class
    Visualization_Class   
    Images
    Images_reconstructed
    Images_reconstructed_processed
    chosen_images
    RefDropDown
    MovingDropDown
    trafos
    Image_ref_number
    seg_mask
    Seg_Flag
    FullScreenButton
    Image_Highlights
    Image_Marked
    DifferenceImg
    ClearButton
    end 
methods (Access = public)
    
    function obj =  GUI()
         obj.layoutdef()
         set(obj.gui_fig, 'Visible', 'On');
         imshow("TUM_LOGO.png",'Parent',obj.TUM_Logo);
         imshow("Sat_Logo.png",'Parent',obj.Sat_Logo);
    end
    
    function layoutdef(obj)
        screen_sz = get(0,'ScreenSize');
        
        obj.gui_fig = figure('Name', 'Computer Vision Challenge',...
                'Position', [300 200 screen_sz(3) screen_sz(4)],...
                'NumberTitle', 'off',...
                'toolbar', 'none',...
                'Menubar', 'none');
            
        obj.hp0 = uipanel('Position', [0.05 0.8 0.9 0.15],...
                'Parent', obj.gui_fig);
            
        obj.TUM_Logo = uiaxes('Units', 'normalized',...
                        'Position', [0.1 0.05 0.3 0.99],...
                        'Parent', obj.hp0);
                    
        obj.WelcomeMSG = uicontrol('Style','text',...
                        'String','SATT.io - see how the world changes!',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.4 0.4 0.2 0.2],...
                        'Parent',obj.hp0);
                    
        obj.Sat_Logo = uiaxes('Units', 'normalized',...
                        'Position', [0.6 0.05 0.3 0.99],...
                        'Parent', obj.hp0); 
                    
        obj.hp1 = uipanel('Position', [0.05 0.75 0.9 0.05],...
                        'Title', 'Import Image Data',...
                        'Parent',obj.gui_fig);
                    
        obj.ImportButton1 = uicontrol('Style', 'pushbutton',...
                        'String', 'Import folder with images',...
                        'Units', 'normalized',...
                        'Position', [0.4 0.05 0.15 0.9],...
                        'parent', obj.hp1,...
                        'Callback', @obj.folderImport,...
                        'FontWeight','bold',... 
                        'ForeGroundColor','#FFFFFF',...
                       'BackgroundColor','#0072BD'); 
                   
        obj.hp2 = uipanel('Position', [0.05 0.5 0.45 0.25],...
                       'Title', 'Image Visualization',...
                      'Parent',obj.gui_fig,'Visible','Off');
                  
        obj.GraphTitle = uicontrol('Style','text',...
                        'String','Test',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.1 0.9 0.9 0.1],...
                        'Parent',obj.hp2,'Visible','Off');
                    
        obj.ImageGraph =  uiaxes('Units', 'normalized',...
                      'Position', [0.1 0.01 0.9 0.9],...
                      'Parent', obj.hp2,'Visible','Off');
                  
        obj.DropdownFolder = uicontrol('Style','popupmenu',...
                                        'String','Select image to be visualized',...
                                        'Units','normalized',...
                                        'Position',[0.05 0.3 0.2 0.3],...
                                        'BackgroundColor','white','Parent',obj.hp2,'Callback',@obj.view_img);
                                    
        obj.hp3 = uipanel('Position', [0.5 0.5 0.45 0.25],...
                       'Title', 'Segmentation of Image Regions',...
                      'Parent',obj.gui_fig,'Visible','Off');
                  
        obj.SegGraphTitle = uicontrol('Style','text',...
                        'String','Test',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.25 0.9 0.9 0.1],...
                        'Parent',obj.hp3,'Visible','Off');
                    
        obj.SegImgGraph = uiaxes('Units', 'normalized',...
                      'Position', [0.45 0.01 0.5 0.9],...
                      'Parent', obj.hp3,'Visible','On');
                  
        obj.AllRegionsButton = uicontrol('Style','checkbox',...
                    'String','All regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.8 0.4 0.1],'Parent', obj.hp3,'Callback',@obj.setRegionButttons);
                
        obj.LandButton = uicontrol('Style','checkbox',...
                    'String','Land regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.7 0.4 0.1],'Parent', obj.hp3);
                
        obj.SeaButton = uicontrol('Style','checkbox',...
                    'String','Sea regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.6 0.4 0.1],'Parent', obj.hp3);
                
        obj.CityButton = uicontrol('Style','checkbox',...
                    'String','City regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.5 0.4 0.1],'Parent', obj.hp3);
                
        obj.SpecialLandscapeButton = uicontrol('Style','checkbox',...
                    'String','Special Landscapes',...
                    'Units','normalized',...
                    'Position',[0.05 0.4 0.4 0.1],'Parent', obj.hp3);
                
        obj.RunButton1 = uicontrol('Style', 'pushbutton',...
                'String', 'Run Segmentation',...
                'Units', 'normalized',...
                'Position', [0.05 0.2 0.2 0.1],...
                'parent', obj.hp3,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
               'BackgroundColor','#0072BD','Callback',@obj.segment); 
           
         obj.hp4 =  uipanel('Position', [0.05 0.1 0.55 0.4],...
                        'Title', 'Parametrization',...
                       'Parent',obj.gui_fig,'Visible','Off');   
                   
         %Add Radio button group for signal magnitude setting
        obj.DisplayButtons = uibuttongroup('Units','normalized',...
            'Position',[0.05 0.05 0.4 0.9],'Title','Select visualization mode','Parent',obj.hp4);
        
        %Add Radio button 1 for raw data selection
        obj.ModeButton1 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Historical timelapse',...
            'Position',[0.1 0.8 0.6 0.15],'Parent',obj.DisplayButtons);
        
        obj.ModeButton2 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Comparison timelapse',...
            'Position',[0.1 0.6 0.6 0.15],'Parent',obj.DisplayButtons);
        
        obj.ModeButton3 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Highlights',...
            'Position',[0.1 0.4 0.6 0.15],'Parent',obj.DisplayButtons);
        
        obj.ModeButton4 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Two image comparison',...
            'Position',[0.1 0.2 0.6 0.15],'Parent',obj.DisplayButtons);
        
        obj.RunButton2 = uicontrol('Style', 'pushbutton',...
                'String', 'Confirm mode',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'Parent', obj.DisplayButtons,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
               'BackgroundColor','#0072BD','Callback',@obj.setParamPanel);
        
        
        obj.ParameterButtons = uibuttongroup('Units','normalized',...
            'Position',[0.45 0.05 0.5 0.9],'Title','Set visualization parameters','Parent',obj.hp4,'Visible','Off');
        
        obj.IntensitySliderTitle = uicontrol('Style','text',...
                        'String','Difference intensity',...
                        'Units','normalized',...
                        'Position',[0.2 0.82 0.6 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','On');
                    
         obj.IntensitySlider  =  uicontrol('Style','slider',...
                                'min',0,...
                                'max',100,...
                                'SliderStep',[0.05 0.05],...
                                'Value',50,...
                                'Units','normalized',...
                                'Position',[0.25 0.8 0.5 0.05],'Parent',obj.ParameterButtons);
                            
        obj.AreaSliderTitle = uicontrol('Style','text',...
                        'String','Difference area',...
                        'Units','normalized',...
                        'Position',[0.25 0.67 0.5 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','On');
                    
         obj.AreaSlider =      uicontrol('Style','slider',...
                                'min',1,...
                                'max',201,...
                                'SliderStep',[0.1 0.1],...
                                'Value',100,...
                                'Units','normalized',...
                                'Position',[0.25 0.65 0.5 0.05],'Parent',obj.ParameterButtons);
                            
        obj.SpeedSliderTitle = uicontrol('Style','text',...
                        'String','Timelapse speed (left to right: fast to slow)',...
                        'Units','normalized',...
                        'Position',[0.25 0.52 0.5 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','On'); 
                    
        obj.SpeedSlider =      uicontrol('Style','slider',...
                                'min',0.1,...
                                'max',3,...
                                'SliderStep',[0.5 0.5],...
                                'Tooltip','Set speed of the time lapse, from slow (left) to fast (right)',...
                                'Value',1.5,...
                                'Units','normalized',...
                                'Selected','On',...
                                'Position',[0.25 0.5 0.5 0.05],'Parent',obj.ParameterButtons);
                            
        obj.RefDropDown = uicontrol('Style','popupmenu',...
                                        'String','Select Reference Image',...
                                        'Units','normalized',...
                                        'Position',[0.25 0.5 0.5 0.05],...
                                        'BackgroundColor','white','Parent',obj.ParameterButtons,'Visible','On');
                                    
        obj.MovingDropDown = uicontrol('Style','popupmenu',...
                                        'String','Select Comparison Image',...
                                        'Units','normalized',...
                                        'Position',[0.25 0.3 0.5 0.05],...
                                        'BackgroundColor','white','Parent',obj.ParameterButtons,'Visible','On');     
   
        obj.DisplayButton1 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark big changes (red)',...
            'Position',[0.05 0.35 0.7 0.1],'Parent',obj.ParameterButtons);
       
        obj.DisplayButton2 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark medium changes (blue)',...
            'Position',[0.05 0.25 0.7 0.1],'Parent',obj.ParameterButtons);
        
        obj.DisplayButton3 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark small changes (green)',...
            'Position',[0.05 0.15 0.7 0.1],'Parent',obj.ParameterButtons);
        
        obj.RunButton3 = uicontrol('Style', 'pushbutton',...
                'String', 'Run',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
                'Parent',obj.ParameterButtons,...
                'BackgroundColor','#0072BD','Callback',@obj.visualizationCaller);
           
       obj.hp5 =  uipanel('Position', [0.6 0.1 0.35 0.4],...
                        'Title', 'Difference Visualization',...
                       'Parent',obj.gui_fig,'Visible','Off');
                   
       obj.DifferenceImg = uiaxes('Units', 'normalized',...
                      'Position', [0.25 0.1 0.45 0.9],...
                      'Parent', obj.hp5,'Visible','On');
                  
       obj.FullScreenButton = uicontrol('Style', 'pushbutton',...
                'String', 'Show Fullscreen',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'Parent', obj.hp5,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
                'BackgroundColor','#0072BD','Callback',@obj.fullscreenShow);
            
            
       obj.ClearButton  = matlab.ui.control.UIControl('Style', 'pushbutton',...
                    'String', 'Reset GUI',...
                    'Units', 'normalized',...
                    'Position', [0.85 0.03 0.1 0.03],...
                    'Parent', obj.gui_fig,...
                    'FontWeight','bold',... 
                    'ForeGroundColor','#FFFFFF',...
                    'BackgroundColor','#0072BD',...
                    'Callback',@obj.clear_data,'Visible','Off');
    end 
    function clear_data(obj,~, ~)
        clear
        GUI()
    end
    function folderImport(obj,~,~)
            obj.folderName = uigetdir();
            obj.fileNames = {dir(fullfile(obj.folderName,'*')).name};            
            idx = cellfun(@(x) isequal(x,'.') | isequal(x,'..'),obj.fileNames); 
            obj.fileNames(idx)=[];
            
            obj.Images=cell(1,length(obj.fileNames));
            
            for i=1:length(obj.fileNames)
                obj.Images{i}=imread(fullfile(obj.folderName,obj.fileNames{i}));
            end   
            
            f = msgbox("Loading images ...");
            obj.callReconstructImgs()
     
            obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames, obj.trafos, obj.Images, obj.Image_ref_number);
            idx = find(~cellfun(@isempty,obj.Images_reconstructed));
            obj.fileNames_processed = obj.fileNames(idx);
            obj.Images = obj.Images(idx);
            obj.Images_reconstructed = obj.Images_reconstructed(idx);
            
            close(f)
            f2 = msgbox("Images loaded!");
            obj.hp2.Visible = 'On';
            obj.hp3.Visible = 'On';
            
            
            obj.fileNames_new = cell(1,size(obj.fileNames_processed,2)+1);
            obj.fileNames_new{1} = obj.DropdownFolder.String;
            obj.fileNames_new(2:end) = obj.fileNames_processed;
            obj.DropdownFolder.String = obj.fileNames_new;
            imshow(obj.Images{1},'Parent',obj.ImageGraph);
            obj.filename = replace(obj.fileNames_processed{1},'_','-');
            title(obj.filename(1:end-4),'Parent',obj.ImageGraph);
            folderName = split(obj.folderName,"/");
            obj.GraphTitle.String = "Showing images for " + folderName{end};
            obj.GraphTitle.Visible = 'On';            
    end

    function view_img(obj, ~, ~)
        obj.filename = obj.fileNames_processed{get(obj.DropdownFolder,'Value')-1};
        obj.img = imread(fullfile(obj.folderName,obj.filename));  
        obj.filename = replace(obj.filename,'_','-');
        imshow(obj.img,'Parent',obj.ImageGraph);
        title(obj.ImageGraph,obj.filename(1:end-4),'Parent',obj.ImageGraph);
        folderName = split(obj.folderName,"/");
        obj.GraphTitle.String = "Showing images for " + folderName{end};
        obj.GraphTitle.Visible = 'On';
    end
    
    function fullscreenShow(obj, ~, ~)
        figure()
        if ~get(obj.ModeButton4, 'Value')
            imshow(obj.Image_Highlights);
            top_percentage_threshold = obj.Visualization_Class.top_percentage_threshold;
            title(sprintf('Top %d %% most changed pixels highlighted in red ',top_percentage_threshold));
            set(gcf, 'Position', get(0, 'Screensize'));
        else
            imshowpair(obj.Image_Marked,obj.Visualization_Class.moving_image,'montage')
            title(sprintf('Showing image comparison'));
            set(gcf, 'Position', get(0, 'Screensize'));
        end
    end
    
    function segment(obj,~,~)
        %Segmentation
        %To Do for und if tauschen
        f3 = msgbox("Running image segmentation ...");
        clear obj.Seg_Class
        clear obj.seg_mask
        obj.Seg_Class = Segmentation()
        clf(obj.SegImgGraph)
        tic
        for i=1:length(obj.fileNames_processed)
            obj.Seg_Class.img = obj.Images{i};
            if logical(get(obj.LandButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && logical(get(obj.CityButton, 'Value')) || logical(get(obj.AllRegionsButton, 'Value'))
                imshow(obj.Images{i},'Parent',obj.SegImgGraph);
                obj.SegGraphTitle.String = "All regions considered!";
                obj.SegGraphTitle.Visible = "On";
                imshow(obj.Images{i},'Parent',obj.ImageGraph);
            elseif logical(get(obj.LandButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.CityButton, 'Value')) || logical(get(obj.LandButton, 'Value')) && ~logical(get(obj.CityButton, 'Value')) || logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.CityButton, 'Value'))
                obj.Seg_Class.k = 2;
                obj.Seg_Class.segment_kmeans()
                obj.Seg_Flag = 1;
                if logical(get(obj.LandButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On";
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                else 
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On";                    
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                end
            elseif logical(get(obj.CityButton, 'Value'))
                obj.Seg_Class.k = 3;
                obj.Seg_Class.segment_kmeans() 
                obj.Seg_Flag = 1;
                if logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))  && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                elseif logical(get(obj.CityButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                elseif logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value')) && logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph); 
                end
            elseif logical(get(obj.SpecialLandscapeButton, 'Value'))
                obj.Seg_Class.k = 3;
                obj.Seg_Class.segment_kmeans() 
                obj.Seg_Flag = 1;
                if logical(get(obj.SpecialLandscapeButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))  && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                elseif logical(get(obj.SpecialLandscapeButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                elseif logical(get(obj.SpecialLandscapeButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value')) && logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph); 
                end   
            end
        end
        close(f3)
        f4 = msgbox("Image Segmentation finished!");
        obj.hp4.Visible = 'On';
        display("Segmentation runtime: %d s", toc)
    end
    
    function setRegionButttons(obj, ~, ~)
        set(obj.LandButton, 'Value',1)
        set(obj.SeaButton, 'Value',1)
        set(obj.CityButton, 'Value',1)
        set(obj.SpecialLandscapeButton, 'Value',1)
    end
    
    function setParamPanel(obj, ~, ~)
        if get(obj.ModeButton1, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.AreaSlider.Visible = 'On';
            obj.AreaSliderTitle.Visible = 'On';
            obj.SpeedSliderTitle.Visible = 'On';
            obj.SpeedSlider.Visible = 'On';
            obj.SpeedSliderTitle.Visible = 'On';
            obj.DisplayButton1.Visible = 'On';
            obj.DisplayButton2.Visible = 'On';
            obj.DisplayButton3.Visible = 'On';
            obj.IntensitySliderTitle.String = "Difference intensity (left to right: low to high)";
            obj.SpeedSliderTitle.Visible = 'On';
            obj.AreaSliderTitle.String = "Difference area (left to right: small to large)";
            obj.RunButton3.Visible = "On";
            obj.ParameterButtons.Visible = 'On';
        elseif get(obj.ModeButton2, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.AreaSlider.Visible = 'On';
            obj.AreaSliderTitle.Visible = 'On';
            obj.SpeedSliderTitle.Visible = 'On';
            obj.SpeedSlider.Visible = 'On';
            obj.SpeedSliderTitle.Visible = 'On';
            obj.DisplayButton1.Visible = 'On';
            obj.DisplayButton2.Visible = 'On';
            obj.DisplayButton3.Visible = 'On';
            obj.IntensitySliderTitle.String = "Difference intensity (left to right: low to high)";
            obj.RunButton3.Visible = "On";
            obj.SpeedSliderTitle.Visible = 'On';
            obj.AreaSliderTitle.String = "Difference area (left to right: small to large)";
            obj.ParameterButtons.Visible = 'On';
        elseif get(obj.ModeButton3, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.AreaSlider.Visible = 'Off';
            obj.AreaSliderTitle.Visible = 'Off';
            obj.SpeedSliderTitle.Visible = 'Off';
            obj.SpeedSlider.Visible = 'Off';
            obj.SpeedSliderTitle.Visible = 'Off';
            obj.DisplayButton1.Visible = 'Off';
            obj.DisplayButton2.Visible = 'Off';
            obj.DisplayButton3.Visible = 'Off';
            obj.IntensitySliderTitle.String = "Top percentage of differences (left to right: high to low)";
            obj.IntensitySliderTitle.Position = [0.15 0.82 0.7 0.1]
            obj.RunButton3.Visible = "On";
            obj.ParameterButtons.Visible = 'On';          
        elseif get(obj.ModeButton4, 'Value')
            obj.RefDropDown.Visible = 'On';
            obj.MovingDropDown.Visible = 'On'; 
            obj.IntensitySliderTitle.String = "Difference intensity (left to right: low to high)";
            obj.AreaSlider.Visible = 'On';
            obj.SpeedSliderTitle.Visible = 'On';
            obj.AreaSliderTitle.String = "Difference area (left to right: small to large)";
            obj.AreaSliderTitle.Visible = 'On';
            obj.SpeedSlider.Visible = 'Off';
            obj.SpeedSliderTitle.Visible = 'Off';
            obj.DisplayButton1.Visible = 'Off';
            obj.DisplayButton2.Visible = 'Off';
            obj.DisplayButton3.Visible = 'Off';
            obj.RunButton3.Visible = "On";
            obj.RefDropDown.Visible = 'On';
            obj.MovingDropDown.Visible = 'On';
            obj.fileNames_processed1 = cell(1,size(obj.Visualization_Class.Image_Names_new,2)+1);
            obj.fileNames_processed1{1} = obj.RefDropDown.String;
            obj.fileNames_processed1(2:end) = obj.fileNames_processed;
            obj.RefDropDown.String = obj.fileNames_processed1;
            obj.fileNames_processed2 = cell(1,size(obj.Visualization_Class.Image_Names_new,2)+1);
            obj.fileNames_processed2{1} = obj.MovingDropDown.String;
            obj.fileNames_processed2(2:end) = obj.Visualization_Class.Image_Names_new;
            obj.MovingDropDown.String = obj.fileNames_processed2;
            obj.ParameterButtons.Visible = 'On'; 
        end
    end 
    
    function callReconstructImgs(obj, ~, ~)
            obj.reconstructImages(obj.Images);
    end
    
    function reconstructImages(obj,imgs)
        % 2.1) Choose Reference Image as the middle Image
        obj.Image_ref_number=ceil(length(imgs)/2);
        Image_ref=(imgs{obj.Image_ref_number}); %choose Image_ref as the middle Image
        obj.Images_reconstructed=cell(1,length(imgs));
        obj.trafos=cell(length(imgs));

        % For reference picture we already know transform and reconstructed Image
        obj.trafos{obj.Image_ref_number,obj.Image_ref_number} = projective2d;
        obj.Images_reconstructed{obj.Image_ref_number}=Image_ref;

        concatenation=mat2cell(zeros(length(imgs),(length(imgs)-1)),ones(length(imgs),1));%save the chains
        Trafo_status=zeros(1,length(imgs)); %array, 1 at pos j if Trafo from image j to Image_ref worked, 0 else
        Trafo_status(obj.Image_ref_number)=1;

        % 2.2.) Try x-step transform
        % Idea: Try all 1-step transformations to the reference picture first.
        % At pictures where we could not find a 1-step transform, try a
        % 2-step Transform, meaning we transform the image to the next image where
        % we were able to find a 1-step transform to the Reference Image. For
        % efficiency we try the neighboring images first, then the ones a bit
        % further away and so on. In most cases we get a 2-step transform first try!
        % If the two step transforms did not work we try all possible 3-step
        % transforms that could potentially yield a working chaining of trafos.
        % The logic for selecting which of the transformations are left to be
        % calculated is based on graph theory and guarantees that all possible
        % combinations are tried!

        for x_step_transform=1:length(imgs)-1 %max is a length(Images)-1 step transform

            errors_pre_step=find(~Trafo_status); %List that contains all idx of pictures where we could not find a (x-1)-step trafo
            for Error_Image_idx=errors_pre_step %for all pictures where (x-1)-step trafo did not work we try to find a x-step trafo
        
        
            % 2.2.1 Logic to find transformations
            % Find all potentially successfull transformations with as little
            % calculations as possible. idx_try_find_trafo contains all destinations
            % of transformations that could work, starting from the Image we
            % are currently trying to adapt to the reference picture in
            % x_step_transform steps
        
                if(x_step_transform==1) %We only try a direct trafo to the reference Image in a 1-step trafo
                    idx_try_find_trafo=obj.Image_ref_number;
                else %if we need to concatenate at least 2 transforms
                    %Make a list (idx_try_step) of single-step trafos to next intermediate image to try, sorted by likelihood
                    %First we try close ones, then the pcitures further away
                    upstep=Error_Image_idx+1:length(imgs); 
                    upstep(upstep==obj.Image_ref_number)=[]; % do not try the reference image
                    downstep=Error_Image_idx-1:-1:1;
                    downstep(downstep==obj.Image_ref_number)=[];% do not try the reference image
                     if length(downstep)>length(upstep)
                         upstep =[upstep zeros(1,length(downstep)-length(upstep))]; %pad to make same size
                     else
                         downstep =[downstep zeros(1,length(upstep)-length(downstep))]; %pad to make same size
                     end
                    idx_try_find_trafo=[upstep;downstep]; 
                    idx_try_find_trafo=idx_try_find_trafo(idx_try_find_trafo(:)~=0)';  %filter out padding zeros
                    idx_try_find_trafo(~cellfun('isempty',obj.trafos(idx_try_find_trafo,Error_Image_idx)))=[]; %filter out previously tried trafos
                    idx_try_find_trafo(ismember(idx_try_find_trafo,errors_pre_step))=[];%This is a list that gives an order to choose the middle image
                end
        
                if(isempty(idx_try_find_trafo))
                    break %no transformation for that image could be found with x_step_transform steps
                end
    
        
                % 2.2.2 Calculating the needed transforms and concatenation of them
                % We calculate all the transforms, specified by idx_try_find_trafo. So
                % we only calculate 1-step transforms from our current moving image
                % to the intermediate image specified in idx_try_find_trafo and
                % from there go the x_step_transform -2 transfroms that are already
                % calculated! This is a very efficient and extensive way!


                % Calculate and checking the transformation
                for inter_image_idx=idx_try_find_trafo   %try all of the trafos possible, until one works, in efficient order      
                    if Trafo_status(inter_image_idx) %Check if Trafo from that intermediate image to reference Image worked

                         [tform_indirect_step1] = SURF_MSAC(imgs{inter_image_idx},imgs{Error_Image_idx}); %get transform

                         if isempty(tform_indirect_step1) || ~Check_Transform(tform_indirect_step1)%Check if a trafo could not be found
                          % if isempty(tform_indirect_step1) %Check if a trafo could not be found
                             obj.trafos{inter_image_idx,Error_Image_idx}="not Working";
                             Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work
                             continue %we can go to next for loop interation
                         else
                             obj.trafos{inter_image_idx,Error_Image_idx}=tform_indirect_step1;
                             concatenation{Error_Image_idx}(x_step_transform)=inter_image_idx;
                             Trafo_status(Error_Image_idx)=1;
                         end

                         % go along the chain of transforms:
                         concatenation{Error_Image_idx}=concatenation{Error_Image_idx}+concatenation{inter_image_idx};
                         transform_chain=tform_indirect_step1; %just an initialization of transform_chain

                         % Concatenate the transform from moving Image ->intermediate Image and the x-2 step one from
                         % intermediate Image --> reference Image
                         transform_chain.T = obj.trafos{inter_image_idx,Error_Image_idx}.T * obj.trafos{obj.Image_ref_number,inter_image_idx}.T;
                         obj.Images_reconstructed{Error_Image_idx} = apply_transformation(Image_ref,imgs{Error_Image_idx},transform_chain);

                         % Check if everything worked
                         if ~sum(obj.Images_reconstructed{Error_Image_idx}(:)) %Checks if Images_normalized is only black
                            Trafo_status(Error_Image_idx)=0; %Only Black --> Trafo did not work. Go to step 1.3 (2-step Trafos)
                            obj.trafos{inter_image_idx,Error_Image_idx}="not Working";
                            concatenation{Error_Image_idx}(:)=0;
                            obj.Image_ref_number{Error_Image_idx}=[];
                         else
                            Trafo_status(Error_Image_idx)=1;
                            obj.trafos{obj.Image_ref_number,Error_Image_idx}=transform_chain;
                            break %We can break the for loop if we found a working 2-step trafo
                         end
                    end
                end
            end
        end 
    end 
    
    function visualizationCaller(obj,~,~)
        % Create a class for the visualization of the image differences :
        %obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames_processed, obj.trafos, obj.Images, obj.Image_ref_number);
        % Define the parameters :       
        threshold_DM = get(obj.IntensitySlider,'Value'); % threshold for the Difference Magnitude function
        %comparison_rg_first_img = true; % compare all the images regarding the first image in a timelapse plot
        %comparison_rg_prev_img = ~comparison_rg_first_img; % compare all the images regarding the previous image in a timelapse plot
        pause_duration = get(obj.SpeedSlider,'Value'); % duration/time-difference between two different plots
        num_superpixels = 1000; 
        threshold_SP_big = 30; % threshold (in comparison to the most changed superpixel) in percent for seperating superpixels, which have more difference per pixel than the threshold value in comparison to the others for timelapse
        threshold_SP_intermediate = 50;
        threshold_SP_small = 70;
        plot_big_changes = logical(get(obj.DisplayButton1, 'Value'));
        plot_intermediate_changes = logical(get(obj.DisplayButton2, 'Value'));
        plot_small_changes = logical(get(obj.DisplayButton3, 'Value'));
        top_percentage_threshold = threshold_DM;
        threshold_l = get(obj.AreaSlider,'Value');
        
        f4 = msgbox("Running visualization ...");
        if get(obj.ModeButton1, 'Value')
            num_visualization = 2;
            chosen_images = "all"; % "all" or [vector contains image_numbers]
            comparison_rg_first_img = true;
            comparison_rg_prev_img = ~comparison_rg_first_img;
        elseif get(obj.ModeButton2, 'Value')
            chosen_images = "all"; % "all" or [vector contains image_numbers]
            comparison_rg_first_img = false;
            comparison_rg_prev_img = ~comparison_rg_first_img;
        elseif get(obj.ModeButton3, 'Value')
            chosen_images = "all"; % "all" or [vector contains image_numbers]
            top_percentage_threshold = get(obj.IntensitySlider,'Value');
            comparison_rg_first_img = true;
            comparison_rg_prev_img = ~comparison_rg_first_img;
        elseif get(obj.ModeButton4, 'Value')
            chosen_images = [double(get(obj.RefDropDown,'Value')-1) double(get(obj.MovingDropDown,'Value')-1)];
            comparison_rg_first_img = false;
            comparison_rg_prev_img = ~comparison_rg_first_img;
        end
               
        obj.Visualization_Class.define_parameters(...
                    'chosen_images', chosen_images ,...
                    'threshold_DM', threshold_DM,...
                    'comparison_rg_first_img', comparison_rg_first_img ,...
                    'comparison_rg_prev_img', comparison_rg_prev_img ,... 
                    'pause_duration', pause_duration ,...
                    'num_superpixels', num_superpixels ,...
                    'threshold_SP_big', threshold_SP_big ,...
                    'threshold_SP_intermediate', threshold_SP_intermediate ,...
                    'threshold_SP_small', threshold_SP_small ,...
                    'plot_big_changes', plot_big_changes ,...
                    'plot_intermediate_changes',  plot_intermediate_changes ,...
                    'plot_small_changes', plot_small_changes,...
                    'top_percentage_threshold',top_percentage_threshold) 
                
          if get(obj.ModeButton1, 'Value')
              if obj.Seg_Flag
                obj.Visualization_Class.apply_3_2(obj.seg_mask);
              else 
                 seg_masks_ones = []; 
                 obj.Visualization_Class.apply_3_2(seg_masks_ones);
              end
          elseif get(obj.ModeButton2, 'Value')
             if obj.Seg_Flag
                obj.Visualization_Class.apply_3_2(obj.seg_mask);
              else 
                 seg_masks_ones = []; 
                 obj.Visualization_Class.apply_3_2(seg_masks_ones);
              end
          elseif get(obj.ModeButton3, 'Value')
              obj.Visualization_Class.apply_3_3()
              close(f4)
              obj.Image_Highlights = obj.Images{1};
              Image_Marked_red_channel=obj.Image_Highlights(:,:,1);
              if obj.Seg_Flag
                obj.Visualization_Class.Difference_Image_Highlight = bsxfun(@times, obj.Visualization_Class.Difference_Image_Highlight, cast(obj.seg_mask{1}, 'like', obj.Visualization_Class.Difference_Image_Highlight));
              end
              Image_Marked_red_channel(obj.Visualization_Class.Difference_Image_Highlight>0)=255;
              obj.Image_Highlights(:,:,1)=Image_Marked_red_channel;
              imshow(obj.Image_Highlights,'Parent',obj.DifferenceImg)
              title(sprintf('Top %d %% most changed pixels highlighted in red',top_percentage_threshold),'Parent',obj.DifferenceImg);
          elseif get(obj.ModeButton4, 'Value')
              obj.Visualization_Class.apply_3_1()    
              close(f4)
              if obj.Seg_Flag
                obj.Visualization_Class.Diff_Image_Comparison = bsxfun(@times, obj.Visualization_Class.Diff_Image_Comparison, cast(obj.seg_mask{chosen_images(1)}, 'like', obj.Visualization_Class.Diff_Image_Comparison));
              end
              obj.Image_Marked = obj.Images{chosen_images(1)};
              Image_Marked_red_channel=obj.Image_Marked(:,:,1);
              Image_Marked_red_channel(obj.Visualization_Class.Diff_Image_Comparison>0)=255;
              obj.Image_Marked(:,:,1)=Image_Marked_red_channel;
              imshowpair(obj.Image_Marked,obj.Visualization_Class.moving_image,'montage')
              title(sprintf('Showing image comparison'));
          end
          obj.hp5.Visible = 'On'; 
          obj.ClearButton.Visible = 'On'; 
      end
   end
end