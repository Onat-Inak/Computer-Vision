% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30
%-------------------------------------------------------------------------------
%This class implements the GUI creation and offers the user the
%possibility to upload satellite images, select image regions that will be
%segmentated for the analysis, select the visualization mode and change
%parameters, and set the size of the visualization figure. It utilizes
%built-it methods, but also instantiates two classes, Visualization and
%Segmentation, that are needed for the mention sub-tasks. 

classdef GUI < handle
    %Initiliaze GUI properties
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
    HighlightsSlider
    HighlightsSliderTitle
    AreaSlider
    AreaSliderTitle
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
    folderName_processed
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
    ExportButton
    end 
methods (Access = public)
    %Constructor of the GUI, initialize GUI layout and Logos
    function obj =  GUI()
     obj.layoutdef()
     set(obj.gui_fig, 'Visible', 'On');
     imshow("TUM_LOGO.png",'Parent',obj.TUM_Logo);
     imshow("Sat_Logo.png",'Parent',obj.Sat_Logo);
    end
    
    %Method that initializes the graphical elements of the GUI
    function layoutdef(obj)
        %Set size of GUI to the size of screen
        screen_sz = get(0,'ScreenSize');
        %Initialize main GUI figure
        obj.gui_fig = figure('Name', 'Computer Vision Challenge',...
                'Position', [300 200 screen_sz(3) screen_sz(4)],...
                'NumberTitle', 'off',...
                'toolbar', 'none',...
                'Menubar', 'none');
        %Initialize Panel for Logos    
        obj.hp0 = uipanel('Position', [0.05 0.8 0.9 0.15],...
                'Parent', obj.gui_fig);
        %Initialize TUM Logo        
        obj.TUM_Logo = uiaxes('Units', 'normalized',...
                        'Position', [0.1 0.05 0.3 0.99],...
                        'Parent', obj.hp0);
        %Initialize Welcome Title                   
        obj.WelcomeMSG = uicontrol('Style','text',...
                        'String','SATT.io - see how the world changes!',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.4 0.4 0.2 0.2],...
                        'Parent',obj.hp0);
        %Initialize Satellite Logo                               
        obj.Sat_Logo = uiaxes('Units', 'normalized',...
                        'Position', [0.6 0.05 0.3 0.99],...
                        'Parent', obj.hp0); 
        %Initialize Panel for Data import                                           
        obj.hp1 = uipanel('Position', [0.05 0.75 0.9 0.05],...
                        'Title', 'Import Image Data',...
                        'Parent',obj.gui_fig);
        %Initialize Button for satellite image import, callback to import function                                                       
        obj.ImportButton1 = uicontrol('Style', 'pushbutton',...
                        'String', 'Import folder with images',...
                        'Units', 'normalized',...
                        'Position', [0.4 0.05 0.15 0.9],...
                        'parent', obj.hp1,...
                        'Callback', @obj.folderImport,...
                        'FontWeight','bold',... 
                        'ForeGroundColor','#FFFFFF',...
                       'BackgroundColor','#0072BD'); 
        %Initialize Panel for image visualization                                                                  
        obj.hp2 = uipanel('Position', [0.05 0.5 0.45 0.25],...
                       'Title', 'Image Visualization',...
                      'Parent',obj.gui_fig,'Visible','Off');
        %Initialize Title of Image Visualization          
        obj.GraphTitle = uicontrol('Style','text',...
                        'String','Test',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.1 0.9 0.9 0.1],...
                        'Parent',obj.hp2,'Visible','Off');
        %Initialize axes for image visualization            
        obj.ImageGraph =  uiaxes('Units', 'normalized',...
                      'Position', [0.1 0.01 0.9 0.9],...
                      'Parent', obj.hp2,'Visible','Off');
        %Initialize drop down element for image visualization selection           
        obj.DropdownFolder = uicontrol('Style','popupmenu',...
                                        'String','Select image to be visualized',...
                                        'Units','normalized',...
                                        'Position',[0.05 0.3 0.2 0.3],...
                                        'BackgroundColor','white','Parent',obj.hp2,'Callback',@obj.view_img);
        %Initialize panel for image segmentation                             
        obj.hp3 = uipanel('Position', [0.5 0.5 0.45 0.25],...
                       'Title', 'Segmentation of Image Regions',...
                      'Parent',obj.gui_fig,'Visible','Off');
        %Initialize title for segmentated regions                                       
        obj.SegGraphTitle = uicontrol('Style','text',...
                        'String','Test',...
                        'FontWeight','bold',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[0.25 0.9 0.9 0.1],...
                        'Parent',obj.hp3,'Visible','Off');
        %Initialize axes for segmentation image            
        obj.SegImgGraph = uiaxes('Units', 'normalized',...
                      'Position', [0.45 0.01 0.5 0.9],...
                      'Parent', obj.hp3,'Visible','Off');
        %Initialize checkbox for all region selection          
        obj.AllRegionsButton = uicontrol('Style','checkbox',...
                    'String','All regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.8 0.4 0.1],'Parent', obj.hp3,'Callback',@obj.setRegionButttons);
        %Initialize checkbox for land region selection      
        obj.LandButton = uicontrol('Style','checkbox',...
                    'String','Land regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.7 0.4 0.1],'Parent', obj.hp3);
        %Initialize checkbox for sea region selection        
        obj.SeaButton = uicontrol('Style','checkbox',...
                    'String','Sea regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.6 0.4 0.1],'Parent', obj.hp3);
        %Initialize checkbox for city region selection        
        obj.CityButton = uicontrol('Style','checkbox',...
                    'String','City regions',...
                    'Units','normalized',...
                    'Position',[0.05 0.5 0.4 0.1],'Parent', obj.hp3);
        %Initialize checkbox for special landscape selection        
        obj.SpecialLandscapeButton = uicontrol('Style','checkbox',...
                    'String','Special Landscapes',...
                    'Units','normalized',...
                    'Position',[0.05 0.4 0.4 0.1],'Parent', obj.hp3);
        %Initialize run button for image segmentation        
        obj.RunButton1 = uicontrol('Style', 'pushbutton',...
                'String', 'Run Segmentation',...
                'Units', 'normalized',...
                'Position', [0.05 0.2 0.2 0.1],...
                'parent', obj.hp3,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
               'BackgroundColor','#0072BD','Callback',@obj.segment); 
         %Initialize panel for visualization parametrization  
         obj.hp4 =  uipanel('Position', [0.05 0.1 0.55 0.4],...
                        'Title', 'Parametrization',...
                       'Parent',obj.gui_fig,'Visible','Off');   
                   
         %Initialize sub-panel for viz modes
         obj.DisplayButtons = uibuttongroup('Units','normalized',...
            'Position',[0.05 0.05 0.4 0.9],'Title','Select visualization mode','Parent',obj.hp4);
        
         %Initialize radio button for historical timelapse 
         obj.ModeButton1 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Historical timelapse',...
            'Position',[0.1 0.4 0.6 0.15],'Parent',obj.DisplayButtons);
         %Initialize radio button for comparison timelapse 
         obj.ModeButton2 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Comparison timelapse',...
            'Position',[0.1 0.2 0.6 0.15],'Parent',obj.DisplayButtons);
         %Initialize radio button for highlights
         obj.ModeButton3 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Highlights',...
            'Position',[0.1 0.6 0.6 0.15],'Parent',obj.DisplayButtons);
         %Initialize radio button for two image comparison 
         obj.ModeButton4 = uicontrol('Style','radiobutton',...
            'Units','normalized',...
            'String','Two image comparison',...
            'Position',[0.1 0.8 0.6 0.15],'Parent',obj.DisplayButtons);
        %Initialize button for viz mode confirmation
        obj.RunButton2 = uicontrol('Style', 'pushbutton',...
                'String', 'Confirm mode',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'Parent', obj.DisplayButtons,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
               'BackgroundColor','#0072BD','Callback',@obj.setParamPanel);
        %Initialize sub-panel for change parameters       
        obj.ParameterButtons = uibuttongroup('Units','normalized',...
            'Position',[0.45 0.05 0.5 0.9],'Title','Set visualization parameters','Parent',obj.hp4,'Visible','Off');
        %Initialize title for difference intensity slider
        obj.IntensitySliderTitle = uicontrol('Style','text',...
                        'String','Difference intensity (left to right: low to high)',...
                        'Units','normalized',...
                        'Position',[0.2 0.82 0.6 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','Off');
        %Initialize  difference intensity slider            
        obj.IntensitySlider  =  uicontrol('Style','slider',...
                                'min',1,...
                                'max',100,...
                                'SliderStep',[0.1 0.1],...
                                'Value',1,...
                                'Units','normalized',...
                                'Position',[0.25 0.8 0.5 0.05],'Parent',obj.ParameterButtons,'Visible','Off');
        %Initialize title for highlights percentage slider
        obj.HighlightsSliderTitle = uicontrol('Style','text',...
                        'String',"Top percentage of differences (left to right: high to low)",...
                        'Units','normalized',...
                        'Position',[0.2 0.52 0.7 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','Off');
        %Initialize highlights percentage slider         
        obj.HighlightsSlider  =  uicontrol('Style','slider',...
                                'min',0,...
                                'max',20,...
                                'SliderStep',[0.05 0.05],...
                                'Value',10,...
                                'Units','normalized',...
                                'Position',[0.25 0.5 0.5 0.05],'Parent',obj.ParameterButtons,'Visible','Off','Callback',@obj.visualizationCaller);
        %Initialize title for difference area slider                    
        obj.AreaSliderTitle = uicontrol('Style','text',...      
                        'String','Difference area (left to right: small to large)',...
                        'Units','normalized',...
                        'Position',[0.25 0.67 0.5 0.1],...
                        'Parent',obj.ParameterButtons,'Visible','On');
         %Initialize difference area slider           
         obj.AreaSlider =  uicontrol('Style','slider',...
                                'min',1,...
                                'max',201,...
                                'SliderStep',[0.1 0.1],...
                                'Value',1,...
                                'Units','normalized',...
                                'Position',[0.25 0.65 0.5 0.05],'Parent',obj.ParameterButtons);
        %Initialize drop down menu for two image comparison, for the reference image                                              
        obj.RefDropDown = uicontrol('Style','popupmenu',...
                                        'String','Select Reference Image',...
                                        'Units','normalized',...
                                        'Position',[0.25 0.5 0.5 0.05],...
                                        'BackgroundColor','white','Parent',obj.ParameterButtons,'Visible','On');
        %Initialize drop down menu for two image comparison, for the moving image                            
        obj.MovingDropDown = uicontrol('Style','popupmenu',...
                                        'String','Select Comparison Image',...
                                        'Units','normalized',...
                                        'Position',[0.25 0.3 0.5 0.05],...
                                        'BackgroundColor','white','Parent',obj.ParameterButtons,'Visible','On');     
        %Initialize checkbox button for big change selection
        obj.DisplayButton1 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark big changes (red)',...
            'Position',[0.27 0.45 0.7 0.1],'Parent',obj.ParameterButtons);
        %Initialize checkbox button for medium change selection
        obj.DisplayButton2 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark medium changes (blue)',...
            'Position',[0.27 0.35 0.7 0.1],'Parent',obj.ParameterButtons);
        %Initialize checkbox button for small change selection
        obj.DisplayButton3 = uicontrol('Style','checkbox',...
            'Units','normalized',...
            'String','Mark small changes (green)',...
            'Position',[0.27 0.25 0.7 0.1],'Parent',obj.ParameterButtons);
        %Initialize run button for visualization
        obj.RunButton3 = uicontrol('Style', 'pushbutton',...
                'String', 'Run',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
                'Parent',obj.ParameterButtons,...
                'BackgroundColor','#0072BD','Callback',@obj.visualizationCaller);
        %Initialize panel for change visualization image  
        obj.hp5 =  uipanel('Position', [0.6 0.1 0.35 0.4],...
                        'Title', 'Difference Visualization',...
                       'Parent',obj.gui_fig,'Visible','Off');
        %Initialize axes for change visualization image           
        obj.DifferenceImg = uiaxes('Units', 'normalized',...
                      'Position', [0.25 0.1 0.45 0.9],...
                      'Parent', obj.hp5,'Visible','On');
        %Initialize button for fullscreen change visualization image         
        obj.FullScreenButton = uicontrol('Style', 'pushbutton',...
                'String', 'Show Fullscreen',...
                'Units', 'normalized',...
                'Position', [0.3 0.01 0.4 0.1],...
                'Parent', obj.hp5,...
                'FontWeight','bold',... 
                'ForeGroundColor','#FFFFFF',...
                'BackgroundColor','#0072BD','Callback',@obj.fullscreenShow);
        %Initialize button for GUI reset     
        obj.ClearButton  = matlab.ui.control.UIControl('Style', 'pushbutton',...
                    'String', 'Reset GUI',...
                    'Units', 'normalized',...
                    'Position', [0.85 0.03 0.1 0.03],...
                    'Parent', obj.gui_fig,...
                    'FontWeight','bold',... 
                    'ForeGroundColor','#FFFFFF',...
                    'BackgroundColor','#0072BD',...
                    'Callback',@obj.clear_data,'Visible','Off');
        %Initialize button for export of reconstructed images             
        obj.ExportButton  = matlab.ui.control.UIControl('Style', 'pushbutton',...
                    'String', 'Export reconstructed images',...
                    'Units', 'normalized',...
                    'Position', [0.7 0.03 0.15 0.03],...
                    'Parent', obj.gui_fig,...
                    'FontWeight','bold',... 
                    'ForeGroundColor','#FFFFFF',...
                    'BackgroundColor','#0072BD',...
                    'Callback',@obj.export_reconstructed_imgs,'Visible','Off');
    end 
    %Method that clears GUI elements (resets it)
    function clear_data(obj,~, ~)
        clear
        GUI()
    end
    %Method that enables import of folder with satellite images
    function folderImport(obj,~,~)
            % Get images, filenames and read images:
            % From Project specification: Folder of pictures taken of the same location
            % on earth with naming convention YYYY_MM.FORMAT.
            % Loads Images into Cell array of Dimensions 1 x #ofImages, where each
            % entry is of the size the picture has in pixels, so  width x height
            obj.folderName = uigetdir();
            obj.fileNames = {dir(fullfile(obj.folderName,'*')).name};            
            idx = cellfun(@(x) isequal(x,'.') | isequal(x,'..'),obj.fileNames); 
            obj.fileNames(idx)=[];         
            obj.Images=cell(1,length(obj.fileNames));            
            for i=1:length(obj.fileNames)
                obj.Images{i}=imread(fullfile(obj.folderName,obj.fileNames{i}));
            end              
            f = msgbox("Loading images ...");
            %Call image matching and reconstruction pipeline (Module 1, see ReadMe)
            obj.callReconstructImgs()
            %Initialize the Visualization class, that will be needed for
            %the visualization functionalities of Module 2 (see ReadMe)
            obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames, obj.trafos, obj.Images, obj.Image_ref_number);
            %Filter out img and img names that could not be reconstructed
            idx = find(~cellfun(@isempty,obj.Images_reconstructed));
            obj.fileNames_processed = obj.fileNames(idx);
            obj.Images = obj.Images(idx);
            obj.Images_reconstructed = obj.Images_reconstructed(idx);  
            obj.trafos = obj.Visualization_Class.trafos_new;
            obj.Image_ref_number = obj.Visualization_Class.Image_ref_number_new;
            close(f)
            f2 = msgbox("Images loaded!");
            %Visualize GUI elements
            obj.hp2.Visible = 'On';
            obj.hp3.Visible = 'On';
            obj.hp4.Visible = 'On';
            set(obj.ModeButton4,'Value',1)
            %Set filename properties for drop down menu in image visualization           
            obj.fileNames_new = cell(1,size(obj.fileNames_processed,2)+1);
            obj.fileNames_new{1} = obj.DropdownFolder.String;
            obj.fileNames_new(2:end) = obj.fileNames_processed;
            obj.DropdownFolder.String = obj.fileNames_new;
            imshow(obj.Images{1},'Parent',obj.ImageGraph);
            obj.filename = replace(obj.fileNames_processed{1},'_','-');
            title(obj.filename(1:end-4),'Parent',obj.ImageGraph);
            obj.folderName_processed = split(obj.folderName,"/");
            obj.folderName_processed = obj.folderName_processed{end};
            %Set title for image visualization
            obj.GraphTitle.String = "Showing images for " + obj.folderName_processed;
            obj.GraphTitle.Visible = 'On';            
    end
    %Method that checks all boxes if "All regions" are selected
    function setRegionButttons(obj, ~, ~)
        set(obj.LandButton, 'Value',1)
        set(obj.SeaButton, 'Value',1)
        set(obj.CityButton, 'Value',1)
        set(obj.SpecialLandscapeButton, 'Value',1)
    end
    %Method that visualizes the image selected from the drop down menu
    function view_img(obj, ~, ~)
        %Set filename, read image and show
        obj.filename = obj.fileNames_processed{get(obj.DropdownFolder,'Value')-1};
        obj.img = imread(fullfile(obj.folderName,obj.filename));  
        obj.filename = replace(obj.filename,'_','-');
        imshow(obj.img,'Parent',obj.ImageGraph);
        title(obj.ImageGraph,obj.filename(1:end-4),'Parent',obj.ImageGraph);
        obj.folderName_processed = split(obj.folderName,"/");
        obj.folderName_processed = obj.folderName_processed{end};
        obj.GraphTitle.String = "Showing images for " + obj.folderName_processed;
        obj.GraphTitle.Visible = 'On';
    end
    %Method that initializes the segmentation class, based on the
    %checkbox selections runs the k-Means method of Segmentation, together
    %with creating  binary masks for the segmentated regions, used later
    %for the crop of difference pixels.
    function segment(obj,~,~)
        f3 = msgbox("Running image segmentation ...");
        clear obj.Seg_Class
        clear obj.seg_mask
        %Initialize segmentation class
        obj.Seg_Class = Segmentation()
        clf(obj.SegImgGraph)
        %Start measuring run time
        tic
        %Iterate through the reconstructed images
        for i=1:length(obj.fileNames_processed)
            %Set img property of Segmentation class, needed for the
            %segmentation
            obj.Seg_Class.img = obj.Images{i};
            %Check user selection for the desired regions: 
            %If all regions are selected, no segmentation needs to be
            %applied, and binary mask is filled with 1's.
            if logical(get(obj.LandButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && logical(get(obj.CityButton, 'Value')) || logical(get(obj.AllRegionsButton, 'Value'))
                imshow(obj.Images{i},'Parent',obj.SegImgGraph);
                obj.SegGraphTitle.String = "All regions considered!";
                obj.SegGraphTitle.Visible = "On";
                imshow(obj.Images{i},'Parent',obj.ImageGraph);
                obj.Seg_Flag = 0;
            %If two regions are selected (and no city/special landscape), initialize kMeans with 2 cluster centers    
            elseif logical(get(obj.LandButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SpecialLandscapeButton, 'Value')) || logical(get(obj.LandButton, 'Value')) && ~logical(get(obj.CityButton, 'Value')) || logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SpecialLandscapeButton, 'Value'))
                obj.Seg_Class.k = 2;
                obj.Seg_Class.segment_kmeans()
                %Set segmentation flag, indicating that segmentation was
                %applied
                obj.Seg_Flag = 1;
                %Check which region was selected, now more specifically:
                %If Land is selected, only select pixels that are
                %labelled as the cluster center with lower intensities,
                %and highlight those pixels. Create a binary mask for the
                %selected pixels.
                if logical(get(obj.LandButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On";
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                %If Sea is selected, only select pixels that are
                %labelled as the cluster center with higher intensities,
                %and highlight those pixels. Create a binary mask for the
                %selected pixels.
                else 
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On";                    
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                end
            %If City regions are selected, initialize kMeans with 3 cluster centers, to get a meaningful partition for this region.    
            elseif logical(get(obj.CityButton, 'Value'))
                obj.Seg_Class.k = 3;
                obj.Seg_Class.segment_kmeans()
                %Set segmentation flag, indicating that segmentation was
                %applied
                obj.Seg_Flag = 1;
                %Check which region was selected, now more specifically:
                %If only City is selected, only select pixels that are
                %labelled as the cluster center with mid intensities, and
                %highlight those pixels. Create a binary mask for the
                %selected pixels.
                if logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))  && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                %If City and Sea is selected, only select pixels that are
                %labelled as the cluster center with lowest and mid
                %intensities, and highlight those pixels. Create a binary mask for the
                %selected pixels.
                elseif logical(get(obj.CityButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                %If City and Land is selected, only select pixels that are
                %labelled as the cluster center with mid and highest
                %intensities, and highlight those pixels. Create a binary mask for the
                %selected pixels.
                elseif logical(get(obj.CityButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value')) && logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) = 1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) =  1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph); 
                end
            %If special landscapes (such as glaciers) are selected, initialize kMeans with 3 cluster centers, to get a meaningful partition for such regions.    
            elseif logical(get(obj.SpecialLandscapeButton, 'Value'))
                obj.Seg_Class.k = 3;
                obj.Seg_Class.segment_kmeans() 
                %Set segmentation flag, indicating that segmentation was
                %applied
                obj.Seg_Flag = 1;
                %Check which region was selected, now more specifically:
                %%If only Special Landscape is selected, only select pixels that are
                %labelled as the cluster center with highest intensities, and
                %highlight those pixels. Create a binary mask for the
                %selected pixels.
                if logical(get(obj.SpecialLandscapeButton, 'Value')) && ~logical(get(obj.SeaButton, 'Value'))  && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) = 0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                %Check which region was selected, now more specifically:
                %%If Special Landscape and Sea is selected, only select pixels that are
                %labelled as the cluster center with lowest and highest intensities, and
                %highlight those pixels. Create a binary mask for the
                %selected pixels.
                elseif logical(get(obj.SpecialLandscapeButton, 'Value')) && logical(get(obj.SeaButton, 'Value')) && ~logical(get(obj.LandButton, 'Value'))
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 2) =  0;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 1) =  1;
                    obj.Seg_Class.cluster_label(obj.Seg_Class.cluster_label == 3) = 1;
                    obj.seg_mask{i} = obj.Seg_Class.cluster_label;
                    imshow(labeloverlay(obj.Seg_Class.img,obj.Seg_Class.cluster_label),'Parent',obj.SegImgGraph);
                    obj.SegGraphTitle.String = "Example segmentation (regions highlighted)";
                    obj.SegGraphTitle.Visible = "On"; 
                    imshow(obj.Images{i},'Parent',obj.ImageGraph);
                %Check which region was selected, now more specifically:
                %%If Special Landscape and Land is selected, only select pixels that are
                %labelled as the cluster center with mid and highest intensities, and
                %highlight those pixels. Create a binary mask for the
                %selected pixels.
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
        %Stop measuring run time
        time = toc;
        f4 = msgbox("Image Segmentation finished! Runtime: " + num2str(time) + "s");
    end
    %Method that blends in the change parameters needed for the
    %visualization, based on the selected visualization mode
    function setParamPanel(obj, ~, ~)
        %For historical timelapse mode
        if get(obj.ModeButton1, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.IntensitySlider.Visible = 'On';
            obj.IntensitySliderTitle.Visible = 'On';
            obj.HighlightsSlider.Visible = 'Off';
            obj.HighlightsSliderTitle.Visible = 'Off';
            obj.AreaSlider.Visible = 'On';
            obj.AreaSliderTitle.Visible = 'On';
            obj.DisplayButton1.Visible = 'On';
            obj.DisplayButton2.Visible = 'On';
            obj.DisplayButton3.Visible = 'On';
            obj.RunButton3.Visible = "On";
            obj.ParameterButtons.Visible = 'On';
        %For comparison timelapse mode
        elseif get(obj.ModeButton2, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.IntensitySlider.Visible = 'On';
            obj.IntensitySliderTitle.Visible = 'On';
            obj.HighlightsSlider.Visible = 'Off';
            obj.HighlightsSliderTitle.Visible = 'Off';
            obj.AreaSlider.Visible = 'On';
            obj.AreaSliderTitle.Visible = 'On';
            obj.DisplayButton1.Visible = 'On';
            obj.DisplayButton2.Visible = 'On';
            obj.DisplayButton3.Visible = 'On';
            obj.RunButton3.Visible = "On";
            obj.ParameterButtons.Visible = 'On';
        %For highlights mode
        elseif get(obj.ModeButton3, 'Value')
            obj.RefDropDown.Visible = 'Off';
            obj.MovingDropDown.Visible = 'Off';
            obj.AreaSlider.Visible = 'Off';
            obj.AreaSliderTitle.Visible = 'Off';
            obj.IntensitySlider.Visible = 'Off';
            obj.IntensitySliderTitle.Visible = 'Off';
            obj.DisplayButton1.Visible = 'Off';
            obj.DisplayButton2.Visible = 'Off';
            obj.DisplayButton3.Visible = 'Off';
            obj.HighlightsSliderTitle.Visible  = 'On';
            obj.HighlightsSlider.Visible = 'On';
            obj.RunButton3.Visible = "Off";
            obj.ParameterButtons.Visible = 'On';
        %For two image comparison
        elseif get(obj.ModeButton4, 'Value')
            obj.RefDropDown.Visible = 'On';
            obj.MovingDropDown.Visible = 'On'; 
            obj.IntensitySlider.Visible = 'On';
            obj.IntensitySliderTitle.Visible = 'On';
            obj.AreaSlider.Visible = 'On';
            obj.AreaSliderTitle.Visible = 'On';
            obj.HighlightsSlider.Visible = 'Off';
            obj.HighlightsSliderTitle.Visible = 'Off';
            obj.DisplayButton1.Visible = 'Off';
            obj.DisplayButton2.Visible = 'Off';
            obj.DisplayButton3.Visible = 'Off';
            obj.RunButton3.Visible = "On";
            obj.RefDropDown.Visible = 'On';
            obj.MovingDropDown.Visible = 'On';
            %Set filenames used in the two image comparison drow down menus
            %based on the reconstructed images
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
    %Method that calls the image reconstruction pipeline from a callback
    function callReconstructImgs(obj, ~, ~)
            obj.reconstructImages(obj.Images);
    end
    %Method representing Module 1
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
    %Method that calls the visualization pipeline (Module 2)
    function visualizationCaller(obj,~,~)
        %Define the visualization parameters from the user input:
        %Set number of superpixels and thresholds for low,mid and high
        %intensity superpixels
        num_superpixels = 1000; 
        threshold_SP_big = 30;
        threshold_SP_intermediate = 50;
        threshold_SP_small = 70;
        %Check which superpixel type should be shown
        plot_big_changes = logical(get(obj.DisplayButton1, 'Value'));
        plot_intermediate_changes = logical(get(obj.DisplayButton2, 'Value'));
        plot_small_changes = logical(get(obj.DisplayButton3, 'Value'));
        
        %Check special parameters of viz modes
        %For historical timelapse visualization
        if get(obj.ModeButton1, 'Value')
            %Initialize Visualization class, and set threshold parameters required
            %for given viz mode
            obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames, obj.trafos, obj.Images, obj.Image_ref_number);
            threshold_DM = get(obj.IntensitySlider,'Value');
            threshold_l = get(obj.AreaSlider,'Value');
            top_percentage_threshold = 0;
            num_visualization = 2;
            %Choose if all images are inspected or just an array of images
            obj.chosen_images = "all";  
            %Compare all the images regarding the first image in a timelapse plot
            comparison_rg_first_img = true;
            %Compare all the images regarding the previous image in a timelapse plot
            comparison_rg_prev_img = ~comparison_rg_first_img;
        %For comparison timelapse visualization
        elseif get(obj.ModeButton2, 'Value')
            %Initialize Visualization class, and set threshold parameters required
            %for given viz mode
            obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames, obj.trafos, obj.Images, obj.Image_ref_number);
            threshold_DM = get(obj.IntensitySlider,'Value');
            threshold_l = get(obj.AreaSlider,'Value');
            top_percentage_threshold = 0;
            num_visualization = 2;
            %Choose if all images are inspected or just an array of images
            obj.chosen_images = "all";
            %Compare all the images regarding the first image in a timelapse plot
            comparison_rg_first_img = false;
            %Compare all the images regarding the previous image in a timelapse plot
            comparison_rg_prev_img = ~comparison_rg_first_img;
        %For highlights visualization
        elseif get(obj.ModeButton3, 'Value')
            %Choose if all images are inspected or just an array of images
            obj.chosen_images = "all";
            %Set threshold for top difference in highlights image, all
            %other thresholds irrelevant
            threshold_DM = 1;
            threshold_l = 1;
            top_percentage_threshold = get(obj.HighlightsSlider,'Value');
            %Compare all the images regarding the first image in a timelapse plot
            comparison_rg_first_img = true;
            %Compare all the images regarding the previous image in a timelapse plot
            comparison_rg_prev_img = ~comparison_rg_first_img;
        %For two image comparison
        elseif get(obj.ModeButton4, 'Value')
            %Initialize Visualization class, and set threshold parameters required
            %for given viz mode
            obj.Visualization_Class = Visualization(obj.Images_reconstructed, obj.fileNames, obj.trafos, obj.Images, obj.Image_ref_number);
            threshold_DM = get(obj.IntensitySlider,'Value');
            threshold_l = get(obj.AreaSlider,'Value');
            top_percentage_threshold = 0;
            %Set indices of the chosen images from the drop down menu
            obj.chosen_images = [];
            obj.chosen_images = [double(get(obj.RefDropDown,'Value')-1) double(get(obj.MovingDropDown,'Value')-1)];
            %Compare all the images regarding the first image in a timelapse plot
            comparison_rg_first_img = false;
            %Compare all the images regarding the previous image in a
            %timelapse plot (this holds for the comparison, by ordering
            %both images)
            comparison_rg_prev_img = ~comparison_rg_first_img;
        end
         
        %Call parser of the Visualization class
        obj.Visualization_Class.define_parameters(...
                    'chosen_images',obj.chosen_images,...
                    'threshold_DM', threshold_DM,...
                    'comparison_rg_first_img', comparison_rg_first_img ,...
                    'comparison_rg_prev_img', comparison_rg_prev_img ,... 
                    'num_superpixels', num_superpixels ,...
                    'threshold_SP_big', threshold_SP_big ,...
                    'threshold_SP_intermediate', threshold_SP_intermediate ,...
                    'threshold_SP_small', threshold_SP_small ,...
                    'plot_big_changes', plot_big_changes ,...
                    'plot_intermediate_changes',  plot_intermediate_changes ,...
                    'plot_small_changes', plot_small_changes,...
                    'top_percentage_threshold',top_percentage_threshold,...
                    'threshold_l',threshold_l) 
          %For historical timelapse     
          if get(obj.ModeButton1, 'Value')
              %Check if at least one group of superpixels was selected
              if ~logical(get(obj.DisplayButton1, 'Value')) && ~logical(get(obj.DisplayButton2, 'Value')) && ~logical(get(obj.DisplayButton3, 'Value'))
                errordlg("You need to mark at least one change group!")
              end
              f4 = msgbox("Loading historical timelapse...")
              %Run historical timelapse visualization with given superpixel
              %setting, and provide binary masks,if segmentation was applied, with which the calculated
              %differences will be filtered out.
              if obj.Seg_Flag
                obj.Visualization_Class.apply_3_2(obj.seg_mask,obj.folderName_processed);
              else 
                 seg_masks_ones = []; 
                 obj.Visualization_Class.apply_3_2(seg_masks_ones,obj.folderName_processed);
              end
          %For comparison timelapse
          elseif get(obj.ModeButton2, 'Value')
             %Check if at least one group of superpixels was selected
             if ~logical(get(obj.DisplayButton1, 'Value')) && ~logical(get(obj.DisplayButton2, 'Value')) && ~logical(get(obj.DisplayButton3, 'Value'))
                errordlg("You need to mark at least one change group!")
             end
             f4 = msgbox("Loading comparison timelapse...")
             %Run comparison timelapse visualization with given superpixel
             %setting, and provide binary masks, if segmentation was applied, with which the calculated
             %differences will be filtered out.
             if obj.Seg_Flag
                obj.Visualization_Class.apply_3_2(obj.seg_mask,obj.folderName_processed);
              else 
                 seg_masks_ones = []; 
                 obj.Visualization_Class.apply_3_2(seg_masks_ones,obj.folderName_processed);
             end
          %For highlights mode
          elseif get(obj.ModeButton3, 'Value')
              f4 = msgbox("Loading highlights...")
              %Run the Difference Highlights function, used within the
              %Visualization class
              obj.Visualization_Class.apply_3_3()
              close(f4)
              %Select reference image as the first one, the accumulated
              %differences will be mapped to this image
              obj.Image_Highlights = obj.Images{1};
              Image_Marked_red_channel=obj.Image_Highlights(:,:,1);
              %Apply binary mask on differences if segmentation was applied
              if obj.Seg_Flag
                obj.Visualization_Class.Difference_Image_Highlight = bsxfun(@times, obj.Visualization_Class.Difference_Image_Highlight, cast(obj.seg_mask{1}, 'like', obj.Visualization_Class.Difference_Image_Highlight));
              end
              %Mark differences in reference image, and show
              Image_Marked_red_channel(obj.Visualization_Class.Difference_Image_Highlight>0)=255;
              obj.Image_Highlights(:,:,1)=Image_Marked_red_channel;
              imshow(obj.Image_Highlights,'Parent',obj.DifferenceImg)
              title(sprintf('Top %d %% most changed pixels highlighted in red',round(top_percentage_threshold,0)),'Parent',obj.DifferenceImg);
              obj.hp5.Visible = 'On'; 
          %For two image comparison
          elseif get(obj.ModeButton4, 'Value')
              f4 = msgbox("Loading comparison...")
              %Run the Difference Magnitude function on the two images, used within the
              %Visualization class and apply binary mask on differences if segmentation was applied
              if obj.Seg_Flag
                 obj.Visualization_Class.apply_3_1(obj.seg_mask{obj.chosen_images(1)})                  
              else
                 seg_masks_ones = []; 
                 obj.Visualization_Class.apply_3_1(seg_masks_ones)                       
              end
              close(f4)
              %Mark differences in reference image, and show
              obj.Image_Marked = obj.Visualization_Class.Image_Marked;
              imshow(obj.Image_Marked)
              title(sprintf('Showing image comparison for the images: %s and %s',obj.fileNames_processed{obj.chosen_images(1)}(1:end-6),obj.fileNames_processed{obj.chosen_images(2)}(1:end-7)));
              obj.hp5.Visible = 'On'; 
          end
          obj.ClearButton.Visible = 'On'; 
          obj.ExportButton.Visible = 'On';
    end
    %Method that creates a fullscreen representation of the change image
    function fullscreenShow(obj, ~, ~)
        figure()
        %If change image is a higlight, set respective title, otherwise set
        %title as for two image comparison and show
        if ~get(obj.ModeButton4, 'Value')
            imshow(obj.Image_Highlights);
            top_percentage_threshold = obj.Visualization_Class.top_percentage_threshold;
            title(sprintf('Top %d %% most changed pixels highlighted in red ',round(top_percentage_threshold,0)));
            set(gcf, 'Position', get(0, 'Screensize'));
        else
            imshowpair(obj.Image_Marked,obj.Visualization_Class.moving_image,'montage')
            title(sprintf('Showing image comparison for the images: %s and %s',obj.fileNames_processed{obj.chosen_images(1)}(1:end-6),obj.fileNames_processed{obj.chosen_images(2)}(1:end-7)));
            set(gcf, 'Position', get(0, 'Screensize'));
        end
    end
    %Method that exports the reconstructed imgs to img files, by the
    %specified folder name
    function export_reconstructed_imgs(obj, ~, ~)
        mkdir(strcat('Exported_Imgs/',obj.folderName_processed))
        for ever=2:numel(obj.fileNames_new)-1
            filename=strcat('Exported_Imgs/',obj.folderName_processed,'/',obj.fileNames_new{ever});
            imwrite(obj.Images_reconstructed{ever}, filename);
        end

    end
  end
end