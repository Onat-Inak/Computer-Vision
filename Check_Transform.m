function is_valid_trans=Check_Transform(trans)
%Output: Logical value if transform could be valide
%Input: transformation cell in projective2d format

%This function is used to spot wrong 2D Transformations obtained in
%previous steps.

%Basic Idea: as satalite images are taken nearly perpendicular to the
%surface of the earth, most of the rotation between two images must take
%place along the z-axis. Strong rotation along x and y are an indication that
%the estimated trasformation is wrong.
%The exact criteria would be: H proportional rotational matrix of a rotation along z and
%translation (along x,y,z), i.e.: H~[a,b,x;-b,a,y;0,0,1] has to be statisfied (so: check(a,a) and (b,-b), as well as a^2+b^2=1)
%play with thresholds, keep in mind that z<<x_max&z<<<y_max due to projection to
%1 in homogenous coordinates-> reasonable threshold values tend to be small
is_valid_trans=0;
if not(isempty(trans))
H=(trans.T)';    %extract trafo matrix and transpose it to obtain the desired trafo matrix

%so far used criteria:
is_valid_trans=(abs((H(3,1))+abs(H(3,2)))/abs(H(3,3)))<0.0005;%(H(3,1) and H(3,2) have to be zero for a 2D in-plane transform in the image plane

%possible improvement (to be evaluated in depth):
% is_valid_trans=is_valid_trans&(abs((H(1,1)-H(2,2))/H(3,3))<0.01)&(abs((H(1,2)+H(2,1))/H(3,3))<0.01); % check (a,a) and (b,-b)

%not properly working yet:
% is_valid_trans=is_valid_trans&(abs(((H(1,1)/H(3,3))^2+(H(2,1)/H(3,3))^2)-1)<0.01);%using:sin^2+cos^2=1
end
end
