%This is the code for my approach on the orientating problem
%The four point algorithm serves as the basis for aligning the images and
    %is paired with a standard RANSAC
%So far only two pictures can be compared at once, as this only serves an evaluation of
%this approach
%sorry for the messed up image names and that you have to manually read
%them in





%Steps: 
%1.Extract features (Candidates: SURF,...)
%2.: Match features
%3.: 4PA on the features (Ransac for robustness) -> H
        % 4PA works without knowledge of K
%4.: Interpolate the Pixel values from its maped coordinates into the other
%Picture %as a step between: Scale the mapping into the other picture, so that third component of
%image coordinate is 1 (aka. is in the image plane)

%Evaluation:
%-Has problems finding enough feature points on images with strong
    %intensity changes, solution: probably split into R,G,B
%-Has Problems with frauenkirche-> to much perspective for 4PA, another
%algortihm might be desirable

%Special aspects:
%so far only the black and white image was used for feature matching
%Advantage: faster than all colours while probably equally precise
%put it in a function

%Currently, on some images not enough feature points are detected
%possible solutions:
    %1.:Adapt brightness(result of this was rather poor, so discard that)
    %2.:Also use colour information(e.g. as error handling use red, green,
        %blue instead of the initial gray or collect their locations from the beginning on and put them together into one 'correspondences vector)
        %This lead to slight improvement
    %3.:change the matching threshold and metric, etc (currently: MaxRatio
        %increased to 0.69 has yielded more image points)
    %4.:Use different descriptor(Porbably not desirable, SURF is fairly robust
        %to changes in iluminatioin)
 %2.&3. (especially 2.) seemed to be the most promising

 
 
close all;
close all hidden;
%1.: Feature extraction:
%first image:
I1 = imread('Plane (2).jpg'); %this needs to be adapted to: the file names and multile possible data formats
I1=im2double(I1);
if length(size(I1))>2
I1=rgb2gray(I1);
end
%second image:
I2 = imread('Plane (3).jpg');%this needs to be adapted to: the file names and multile possible data formats
I2=im2double(I2);
if length(size(I2))>2
I2=rgb2gray(I2);
end


%SURF DETECTOR:
pointsSURF1 = detectSURFFeatures(I1);
pointsSURF2 = detectSURFFeatures(I2);

[featuresSURF1,pointsSURF1]=extractFeatures(I1,pointsSURF1); %for a reduced amount of points (discarding e.g. those close to a boarder): obtain descriptor, as well as position
[featuresSURF2,pointsSURF2]=extractFeatures(I2,pointsSURF2);

index_match=matchFeatures(featuresSURF1,featuresSURF2,'Metric', 'SAD', 'MatchThreshold', 100, 'MaxRatio', 0.69); %match features to each other and ordering them by how well they are matched
pointsSURF1=pointsSURF1(index_match(:,1));%selecting and sorting matched features
pointsSURF2=pointsSURF2(index_match(:,2));%selecting and sorting matched features
showMatchedFeatures(I1,I2,pointsSURF1,pointsSURF2, 'montage'); %Display resutl of matching

pos1=double((pointsSURF1.Location)');%extracting positions in image1 for 4PA
pos2=double((pointsSURF2.Location)');%extracting positions in image2 for 4PA



%3.: 4PA:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-Kill the logo, kill those close to the border
%So far the scale on the right has not made any problems so I will keep it

%Determine index of of undesired x-coordinates(logo):
shall_delete1=(pos1(1,:)<160)&(pos1(2,:)>990);
shall_delete2=(pos2(1,:)<160)&(pos2(2,:)>990);
%delete them
pos1=pos1(:,~(shall_delete1|shall_delete2)); %delete BOTH: Feature in this region and corresponding region in the other picture
pos2=pos2(:,~(shall_delete1|shall_delete2)); 

%4PA with RANSAC:
correspondences=[pos1(1:2,:);pos2(1:2,:)];
[~, H_ran] = H_ransac(correspondences); %to do: adapt distance measure (e.g.: distance on image plane)
%pos1 and pos2 no longer changed in the code below-> coordinates in image 2
%get maped on Image 1
x1_pixel_homogen=[pos1;ones(1,size(pos1,2))];
x2_pixel_new_hom=H_ran*x1_pixel_homogen; 
x2_pixel_new_hom=x2_pixel_new_hom./x2_pixel_new_hom([3,3,3],:);%deviding so that on image plane
x2_pixel_new=x2_pixel_new_hom(1:2,:);%last step: going from homogen to normal coordinates

figure()
imshow(I2)
hold on;
plot(pos2(1,:),pos2(2,:),'rx');
plot(pos1(1,:),pos1(2,:),'bx');
plot(x2_pixel_new(1,:),x2_pixel_new(2,:),'go');
txt=string(1:size(pos1,2));
text(x2_pixel_new(1,:),x2_pixel_new(2,:),txt);
text(pos2(1,:),pos2(2,:),txt);
hold off;



%Reorientating the image corresponds to interpolation at the transformed positions:
%Map all pixel locations (rectangular grid) of image 1 onto image 2 and determine their values
%based on interpolation in image 2
%These values correspond to the values of the reoriented image 2 in the (at
%first used) pixel locations
%Image 2 gets aligned with Image 1

%possibility 1: use bilinear interpolation of interp2

%gernerate image coordinates in picture 1:
sz=size(I2);
[X,Y]=meshgrid((1:sz(2)),(1:sz(1))); %generate rectangular grid with locations representing the Image coordinates
gridcord=[reshape(X,1,[]);reshape(Y,1,[]);ones(1,(sz(1)*sz(2)))];%brings it to the form [[x1;y1;1],[x2;y2;1],...] of coordinates in Image plane
%i.e.: [[1;1;1],[1;2;1],[1;3;1],...,[2;1;1],[2;2;1],[2;3;1],...]
%Map coordinates on image 2:
mapped_gridcord=H_ran*gridcord; %remember: H_ran: transform form image 1 to image 2
%mapped_gridcord=gridcord; %for testing purpose only
mapped_gridcord=mapped_gridcord./mapped_gridcord([3,3,3],:);%deviding so that point are on image plane


%interpolate values based on those coordinates:
Im_inter=interp2(I2,mapped_gridcord(1,:),mapped_gridcord(2,:),'linear');%speed?:nearest,resolution?:cubic
%this results in the values of the reoriented image in gridcord(1:2,:)

%reshape into image format, to obtain the reorientated/aligned image 2:
reoriented_Im2=reshape(Im_inter,sz(1),sz(2));
comp=zeros([sz,3]);
comp(:,:,1)=I1;
comp(:,:,2)=reoriented_Im2;
figure();
imshow(comp);
title('reoriented image and the image it is to be oriented to');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%functions:
function H= fpa(pos1,pos2,K)
%use 4 Point algorithm to determine A Homographe matrix
%pos1: Matrix of x-y-coordinates 
%K: K Matrix (Kalibration-Matrix of the camera)
    %K is not necessary for this challenge, as 4PA works without K
%If K not known use: Identity or [1,0,ox;0,1,oy;0,0,1] with ox and oy the center of the
%image. For 4 Point Algortihm (depending on further use, this probably will not matter)
%perhaps:leave it out, because 4PA works equally on image plane and pixel
%coordinates


n=size(pos1,2);

%transform pixel coordinates to homogenous image plane coordinates:
x1=K\[double(pos1);ones(1,n)]; % compare lecture: x=K^-1*x'
%x1=[[x1;y1;z1],[x2;y2;z2],...]
x2=K\[double(pos2);ones(1,n)]; %see x1


%Building A:
A=zeros(3*n,9);
for i=1:n
%Cross-Product:
x2_hat=[0,-x2(3,i), x2(2,i);...
        x2(3,i),0,-x2(1,i);...
        -x2(2,i),x2(1,i),0];
Bi=kron(x1(:,i),x2_hat);
A(((3*(i-1)+1):(3*i)),:)=Bi'; %A corresponds to: [B1';B2';...]
end


%solution via SVD:
[~,~,VG]=svd(A);
%Least squares solution corresponds to V(9)
H=reshape(VG(:,9),3,3);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RANSAC:
function [correspondences_robust, largest_set_H] = H_ransac(correspondences, varargin)
    % This function implements the RANSAC algorithm to determine 
    % robust corresponding image points for the 4 Point Algorithm
    % corespondences should have the form: [[x1;y1;x2;y2],[x1;y1;x2;y2],...]
    % optional inputs: see below
    %This is mor or less the function written vor the Grader Homework
    
   default_epsilon= 0.6;    %expected probability of having an outlier in the current set, for later determening s
   default_p= 0.95;          %expected/desired probability of obtaining a result free of outliers, for later determening s
   default_tolerance= 2; %theshold of the now used distance to determine whether a point belongs to a consensus set
   %This now is pixel coordinates, thus the extrem high value
   parser = inputParser;
   valid_epsilon= @(x) isnumeric(x) && (x < 1)&&(x > 0);
   valid_p= @(x) isnumeric(x) && (x < 1)&&(x > 0);
   valid_tolerance = @(x) isnumeric(x);
   
   addRequired(parser,'correspondences');
   addOptional(parser,'epsilon',default_epsilon,valid_epsilon);
   addOptional(parser,'p',default_p,valid_p);
   addOptional(parser,'tolerance',default_tolerance,valid_tolerance);
   parse(parser,correspondences, varargin{:});
   epsilon=parser.Results.epsilon;
   p=parser.Results.p;
   tolerance=parser.Results.tolerance;
   
   numcorr=size(correspondences,2);
   x1_pixel=[correspondences(1:2,:);ones(1,numcorr)];
   x2_pixel=[correspondences(3:4,:);ones(1,numcorr)];
   
   %equivalently to Task4
   k=4; %%4PA: 4, 8PA:8
   s=log(1-p)/log(1-(1-epsilon)^k);
   largest_set_size=0;
   largest_set_dist=inf;
   largest_set_H=zeros(3);
   
   %equivalently to Task6:
   numcorr=size(correspondences,2);
   index_sample=zeros(1,k);
   for i=1:s    %because i not used in loop-> this is eqivalent to ceil(s)
       %choosing samples:
       j=1;
       if(numcorr<k) %the loop below will not finish
           error('Not enought feature points detected. At least 4 are required');
           %Hier könnte Ihre Werbung/Fehlermeldung stehen
       end
       while j<=k
           helpvar=randi(numcorr);%randomly pick samples among the correspondence vectors
           if (all((index_sample(1:(j-1)))~=helpvar)) %check if used befor;
                index_sample(j)=helpvar;
                j=j+1;%only then go on
           end
       end
       x1_samples=x1_pixel(:,index_sample); %Using selection
       x2_samples=x2_pixel(:,index_sample);
       H=fpa(x1_samples(1:2,:),x2_samples(1:2,:),eye(3));%finding H for given selection
       
      %Sampson distance not suitable, changed it to pixel distance
       sd = some_dist(H, x1_pixel, x2_pixel);%calculating distances of all points
      Set_select=sd<tolerance;
       Set=[x1_pixel(:,Set_select);x2_pixel(:,Set_select)]; %selecting consensus set
       dist_new=sum(some_dist(H, Set(1:3,:), Set(4:6,:)));%sum of distance
       
       if((largest_set_size<size(Set,2))||((largest_set_size==size(Set,2))&&(largest_set_dist>dist_new)))%check wheter it has a bigger set size or if it has the same size, if the distance is better
            %(epa is least squares)
            largest_set_H=H;
            %updating comparison varables and Set:
            largest_set_size=size(Set,2);
            correspondences_robust=Set([1,2,4,5],:);%only image coordinates
            largest_set_dist=dist_new;
       end
    end
end
   

function sd = some_dist(H_ran, x1_pixel, x2_pixel)
% This function calculates the pixel distance of the resal position and the
%position of the estimation based on the H matrix
%thus this corresponds to the error


x2_pixel_new_hom=H_ran*x1_pixel; 
x2_pixel_new_hom=x2_pixel_new_hom./x2_pixel_new_hom([3,3,3],:);%deviding so that on image plane

%calculating distance
sd=x2_pixel_new_hom-x2_pixel; %difference, still in homogen coordinates, but does not matter
sd=sqrt(sum(sd.*sd,1)); % to obtain vector of individual distance measurements
%no normalisation needed, as this is the distance in pixel coordinates and
%therefore independent of scaling of H
%Adapted threshold to pixel-distance in H_ransac function
end