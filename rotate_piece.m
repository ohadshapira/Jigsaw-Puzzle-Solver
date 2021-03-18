function [bw_rotated_piece , colored_rotated_piece, Rotated_corners] = rotate_piece(corners,bw_piece, colored_piece)

    %this function rotates a piece, making it straight and horizontal to
    %the X,Y axes
    
    %---------------------------------------------------------
    %input - corners: 2x4 matrix, holding the [X,Y] values of each corner
    %                 (output of "draw_corners" function)
    %        bw_piece: binary image of the puzzle piece
    %        colored_piece: rgb image of the puzzle piece
    
    %output - bw_rotated_piece: binary rotated puzzle piece
    %         colored_rotated_piece: colored rotated puzzle piece
    %         Rotated_corners: 4x2 matrix represents the corners' location after
    %                  rotation
    %---------------------------------------------------------


%     point1 = corners(:,1);
%     point2 = corners(:,2);
    coefficient = (corners(2,2)+2*(corners(2,1)-corners(2,2))-corners(2,1))/(corners(1,2)-corners(1,1));
    angle = -atan((coefficient))*180/pi;
    bw_rotated_piece=imrotate(bw_piece,angle);
    colored_rotated_piece = imrotate(colored_piece,angle);
    
    R=[cosd(angle),-sind(angle);sind(angle),cosd(angle)];
    ij=[corners(2,:);corners(1,:)];
    centerA=size(bw_piece)'/2;
    centerB=size(bw_rotated_piece)'/2;
    Rotated_corners = flip(R*(ij-centerA)+centerB);
