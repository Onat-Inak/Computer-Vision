# Computer Vision Challenge
This is the final project of Team 30, consisting of R.Jacumet, M.Schneider, O.Inak and A.Misik. The goal of the Computer Vision Challenge is to develop an application capable of visualizing the changes between two or more satellite images of the same scene on Earth. It is assumed that the changes represent ecosystem changes induced mainly by human activity. 


## Environment
Following Matlab Version and Toolboxes are needed:

- MATLAB R2019a or higher
- Computer Vision Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

## How to run
Add folder to local path, run the *main.m* function to open our graphical user interface, defined in the *GUI.m* class. This interface bundles all functionalities implemented within our project. 

## Data 
Besides using the baseline data provided after the project kick-off, we created 4 more datasets that can be tested with our software:

- Schiphol
- Singapur
- Beirut
- Garching

The datasets differ in complexity and are thus suitable for investigating the performance characteristics of the functions.

## Functions
On a more granular level, our software can be divided into three functional groups: Module 1, Image Segmentation and Module 2. While Module 1 corresponds to image preprocessing and image matching, Module 2 includes functionalities for the change analysis and visualization.

### Module 1 
Module 1 deals with normalizing the input images, so that they are rotated and translated to the same perspective.
All images will be aligned to a reference image from the set of images and the transformed images will be returned.
In order to align the images with respect to each other, SURF features are extracted, matched and given to the the MATLAB function *estimateGeometricTransform2D*, which is used to estimate the transformations between the images.
This MATLAB function uses the MSAC algorithm to further enhance robustness of the estimation of transformations.
Although the SURF extractor in combination with the MSAC algorithm have a high robustness, some estimations are wrong.
For that purpose a function checking the validity of transformations has been implemented.
A graph search has been implemented to find chained transformations in cases, where no valid direct transformation was found.
The transformations resulting from the graph search are applied to the images and both are returned for further processing.

Module one is called when the images are fist loaded inside the GUI, so that the images are normalized for further visualization.

Module 1 consists of the following functions:
- *Reconstruct_Images.m*: Reconstructs images so that they are all adapted to the Reference Image, meaning they are taken from the same point in space, showing the same location.
Here we have the graph logic implemented to efficiently call our estimations of transformations. The function calls SURF_MSAC for the actual estimation of transformation between two images.
- *SURF_MSAC.m*: Extracts and matches SURF features and then uses them to estimate the transformations between two images with the MATLAB function *estimateGeometricTransform2D*.
This function has implemented both, the calculation of an estimation, as well as the MSAC algorithm on the upper level.
- *Check_Transform.m*: This function is used to spot a wrong 2D transformation obtained from *SURF_MSAC.m*.
- *apply_transformatio.m*: Used to apply the estimated transformations to the images.

### Image Segmentation
In the image segmentation task, a class *Segmentation.m* has been implemented. The Segmentation class implements a k-Means based clustering of pixelsneeded for the semantic segmentation task. The resulting cluster centers are then sorted based on their intensities in an ascending way. Each
cluster represents one semantic region, in essence. The properties of the class consist of:

- Input image,
- Number of cluster centers,
- Segmentated image,
- Label matrix, with the dimension of the input image. 

The class has one method that implements a k-Means clustering on images with MATLAB's *imsegkmeans* function. Afterwards, the cluster centers are sorted by their intensities, and the segmentated images relabelled.

The approach works particularly well for city regions in Dubai, for the glacier region (special landscape) in Columbia Glacier, or the forest/land areas in Brazilian Rainforest.
 
### Module 2
For Module 2, a class called Visualization is implemented. This class is defined in the file *Visualization.m*. All the different visualization options are implemented as methods of this class using the properties of this class. 
Methods:
- Constructor: All the preprocessing regarding the parameters obtained from the Module 1 is done here. The images, by which no transformation is found, are eliminated and the transformation matrices are changed accordingly etc.

- choose_images: The images, which are chosen by the user in two image comparison mode, are defined as properties of the class and used in the following of the code.

- define_parameters: A parser for the Visualization class. All the parameters set by the user are obtained by this function as it's input and with the implemented parser method, the correctness of the given input by the user is investigated. If a wrong parameter is given by the user, an error feedback is given to the user.

- Align_2_images: This function has two inputs. The first input is the new reference image and the second input is the new moving image, which must be transformed regarding the new reference image. This function transforms the second image regarding the first image, thus align them perfectly and make them ready to visualize differences between them.

- Change_ref_im: All the images are transformed with respect to the class property 'ind_new_ref' with tThis function.

- *Difference Magnitude.m*: This function sets the overlaping boundaries of two images, calculates the absolute differences within the boundaries, and thresholds these differences based on the (intensity and area) thresholds given by the user.

- *Difference Highlights.m*: This function is similar to the Difference Magnitude function. The difference here is that we iterate over all images in a for loop, calculate the absolute differences respectively and save these differences in an accumulator array. The accumulator array can then be thresholded, based on the top percentage treshold given by the user.

- apply_3_1: Difference Magnitude function is called for change visualization of the two input images (is used for two image comparison).

- apply_3_2: Apply Difference Magnitude function regarding superpixels in a timelapse and differ big, intermediate and small changes from each other :
			 - red : big changes 
    	     - blue : intermediate changes
    	     - green : small changes

- apply_3_3: Apply Difference Highlights function and determine the most changed pixels between chosen images 

### GUI 
The graphical  user interface represents an integration of all the mentioned functional groups and is implemented within *GUI.m*. The utilization of the interface can be described by a happy path, i.e. a list of steps required to accomplish the task of change visualization in satellite images:

- Upload image folder
- (optional) Visualize uploaded images
- (optional) Select image regions used for semantic segmentation
- Select visualization mode
- Set change and visualization parameters
- Run visualization option
- (optional) Show change image in fullscreen format
- (optional) Export reconstructed images to files

If the happy path was finished for one image folder, it is recommended to use the Reset button for experiments on new folders.
Please also note that when first loading the images, the normalization of perspective takes place. Therefore a short waiting period might occur.

## Work distribution
R.Jacumet: set up the image loading and processing pipeline, and extensively worked on the feature extractor used in Module 1. Furthermore, Robert implemented a pixel difference calculation function and created a visualization method for the difference highlights. Robert also implemented the graph search algorithm used when no direct transformation to the reference image was possible.

M.Schneider: Moritz built the transformation chain and validation methods, needed for perspective normalization of image scenes. Moritz also developed the graph search logic to obtain chained transformations, where no direct transformation was found. He also wrote a function for filtering image differences according to their absolute area.

O.Inak: Onat has implemented most of the functions within module 2. These include the two time-lapse variants and the visualization mode for comparing two images. In addition, Onat has investigated how superpixels can be used to give more semantic meaning to the calculated differences and how they can be color coded according to their intensity.

A.Misik: Adam worked on the image segmentation pipeline, which is used for semantic segmentation of image regions within satellite images. He also worked on the graphical user interface, integrating functionalities from the other modules into one structure.


## References 
[1] H.  Bay,  T.  Tuytelaars,  and  L.  Van  Gool,  ???Surf:  Speeded  up  robustfeatures,??? inComputer Vision ??? ECCV 2006, A. Leonardis, H. Bischof,and A. Pinz, Eds.   Berlin, Heidelberg: Springer Berlin Heidelberg, 2006,pp. 404???417.

[2]    P.   Torr   and   A.   Zisserman,   ???Mlesac:   A   new   robust   estimator   withapplication to estimating image geometry,???Computer Vision and ImageUnderstanding,  vol.  78,  no.  1,  pp.  138???156,  2000.  [Online].  Available:https://www.sciencedirect.com/science/article/pii/S1077314299908329

[3]    M. Barthakur and K. K. Sarma, ???Semantic segmentation using k-meansclustering  and  deep  learning  in  satellite  image,???  in2019 2nd Interna-tional Conference on Innovations in Electronics, Signal Processing andCommunication (IESC), 2019, pp. 192???196.
 
