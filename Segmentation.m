% Moritz Schneider, Adam Misik, Onat Inak, Robert Jacumet
% Computer Vision Project SS21, Group 30
%-------------------------------------------------------------------------------
%The Segmentation class implements a k-Means based clustering of pixels
%needed for the semantic segmentation task. The resulting cluster centers
%are then sorted based on their intensities in an ascending way. Each
%cluster represents one semantic region, in essence.
classdef Segmentation < handle
    
    properties
        %Initialize properties
        img
        k 
        seg_img
        cluster_label
    end
    methods
        %Method that runs the imsegkmeans algorithm from Matlab (kMeans), based on the
        %user parametrization of k.
        function segment_kmeans(obj,~, ~)
               %Get size of the RGB img
                nrows = size(obj.img,1);
                ncols = size(obj.img,2);
                
                %Run kMeans on input RGB img and user defined k, get
                %cluster centers and labelled img
                [L,centers] = imsegkmeans(obj.img,obj.k);
                
                %Sort cluster centers
                [mu_sort id_sort]=sortrows(centers);

                %Create lookup
                lookup = containers.Map(id_sort, 1:size(mu_sort,1));

                %Relabel the labelled image
                cluster_idx_sort = lookup.values(num2cell(L));
                cluster_idx_sort = [cluster_idx_sort{:}];

                %Reshape back to original image dimensions
                obj.cluster_label = reshape(cluster_idx_sort,nrows,ncols);
                obj.seg_img = labeloverlay(obj.img,obj.cluster_label);
            end
    end
end

