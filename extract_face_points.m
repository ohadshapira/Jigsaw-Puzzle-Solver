function [face_points_up,face_points_left,face_points_down,face_points_right]=extract_face_points(points,corners)
% This function allows you to get feature points of each face separatly.

% input- 
%   points as feature points
%   corners_matrix is binary image with 1's where there are corners, 0
%   otherwise

% output-
%   return all faces    face order- {up left down right}


% four_corners=[p1_x ,p1_y;
%               p2_x ,p2_y;
%               p3_x ,p3_y;
%               p4_x ,p4_y]

    [center,teta_corners,~]=classify_corners(corners); 
% this make sure that the corners are in the following order.
%     p1---------p2
%     |           |
%     |           |
%     p4---------p3

    % convert to polar 
    Xc=center(1);
    Yc=center(2);

    teta=cart2pol(points.Location(:,1)-Xc,Yc-points.Location(:,2));
    
    % face up
    face_points_up_idx=[];
    for i=1:length(teta)
        if teta(i)>teta_corners(2) && teta(i)<teta_corners(1)
            face_points_up_idx(end+1)=i;
        end
    end
    face_points_up=points(face_points_up_idx);
    
    % face left
    face_points_left_idx=[];
    for i=1:length(teta)
        if teta(i)>teta_corners(1) || teta(i)<teta_corners(4)
            face_points_left_idx(end+1)=i;
        end
    end
    face_points_left=points(face_points_left_idx);
    
    % face down
    face_points_down_idx=[];
    for i=1:length(teta)
        if teta(i)>teta_corners(4) && teta(i)<teta_corners(3)
            face_points_down_idx(end+1)=i;
        end
    end
    face_points_down=points(face_points_down_idx);
    
    % face right
    face_points_right_idx=[];
    for i=1:length(teta)
        if teta(i)>teta_corners(3) && teta(i)<teta_corners(2)
            face_points_right_idx(end+1)=i;
        end
    end
    face_points_right=points(face_points_right_idx);
    
    
    

    
end