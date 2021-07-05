classdef Segmentation < handle
    
    properties
        img
        k 
        seg_img
        cluster_label
    end
    methods
        function segment_kmeans(obj,~, ~)
                nrows = size(obj.img,1);
                ncols = size(obj.img,2);

                [L,centers] = imsegkmeans(obj.img,obj.k);

                [mu_sort id_sort]=sortrows(centers);

                %// New - Create lookup
                lookup = containers.Map(id_sort, 1:size(mu_sort,1));

                %// Relabel the vector
                cluster_idx_sort = lookup.values(num2cell(L));
                cluster_idx_sort = [cluster_idx_sort{:}];

                %// Reshape back to original image dimensions
                obj.cluster_label = reshape(cluster_idx_sort,nrows,ncols);
                obj.seg_img = labeloverlay(obj.img,obj.cluster_label);
            end
    end
end

