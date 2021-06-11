function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % This function calculates the Sampson distance based on the fundamental matrix F
    e_3 = [0,-1,0;1,0,0;0,0,0];
    sd = rdivide((sum(times(x2_pixel,F*x1_pixel)).^2),((sum((e_3*F*x1_pixel).^2))+(sum((e_3*transpose(F)*x2_pixel).^2))))
end

