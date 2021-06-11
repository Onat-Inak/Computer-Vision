function [correspondences_robust, largest_set_F] = F_ransac(correspondences, varargin)
    % This function implements the RANSAC algorithm to determine 
    % robust corresponding image points
       
    %% Input parser
    % Known variables:
    % epsilon       estimated probability
    % p             desired probability
    % tolerance     tolerance to belong to the consensus-set
    % x1_pixel      homogeneous pixel coordinates
    % x2_pixel      homogeneous pixel coordinates
    epsilon = 0.5;
    p = 0.5;
    tolerance = 0.01;
        
    %% RANSAC algorithm preparation
    % Pre-initialized variables:
    % k                     number of necessary points
    % s                     iteration number
    % largest_set_size      size of the so far biggest consensus-set
    % largest_set_dist      Sampson distance of the so far biggest consensus-set
    % largest_set_F         fundamental matrix of the so far biggest consensus-set
    
    
    %% RANSAC algorithm
    %Get number of correspondences and initialize consensus set
    numCorr = size(correspondences,2);
    consSet = [];
    total_dist = 0;
    
    %Start Ransac iterations
    for i = 1:s
        %Choose k random correspondence points from the given correspondences
        numRanCorr = randperm(numCorr,k);
        for j=1:k
            CorrRansac(:,j) = correspondences(:,numRanCorr(j));
        end
        %Calculate the fundamental matrix F based on the random correspondence points, 
        %then calculate sampson distance for all points with F
        F = epa(CorrRansac);
        samps_dist = sampson_dist(F,[correspondences(1:2,:);ones(1,numCorr)],[correspondences(3:4,:);ones(1,numCorr)]);
        counter = 0;
       
        for d=1:numCorr
            %Check if sampson distance of correspondence is below threshold, 
            %increase counter and sum up sampson distances
            if samps_dist(d) < tolerance
                consSet(:,counter+1) = correspondences(:,d);
                counter = counter +1;
                total_dist = total_dist + samps_dist(1);
            end
        end
        %Get size of current consensus set
        consSet_size = size(consSet,2);
        %For first iteration, set is the biggest one
        if i==1
            largest_set_size = consSet_size;
            largest_set_dist = total_dist;
            largest_set_F = F;
        %If current size is the largest, update 
        elseif consSet_size > largest_set_size
            largest_set_size = consSet_size;
            largest_set_dist =  total_dist;
            largest_set_F = F;
            correspondences_robust = consSet;
        %If equal, compare total distances and update
        elseif consSet_size == largest_set_size
            if total_dist < largest_set_size
                largest_set_size = consSet_size;
                largest_set_dist = total_dist;
                largest_set_F = F;
                correspondences_robust = consSet;
            end
        end
    end
