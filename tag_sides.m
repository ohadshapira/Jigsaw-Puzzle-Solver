function [piece_tags,piece_type,faces_structure,center_of_mass] = tag_sides(bw_rotated_piece, corners)

    %this function is labeling each of the sides of the piece to one of 3 categories:
    % head, flat or hole. in addition it returns the type of the piece,
    % meaning if it is corner, frame or internal piece of the puzzle.
    
    %--------------------------------------------------------------------
    %input - bw_rotated_piece: binary image of the puzzle piece, rotated to
    %                          "straight" form (output of "rotate_piece" function)
    %        corners: 4x2 matrix represents the corners' location after
    %                 rotation (output of "rotate_piece" function)
    %
    %output - piece_tags: structure holding the sides' orientation, with
    %                     the fields up,right,down,left
    %         piece_type: type out of the options: corner, internal or
    %                      frame
    %         faces_structure: struct holding the 4 faces of the piece,
    %                          including its features and direction
    %                     
    %---------------------------------------------------------------------
    
    x_vector = corners(1,:);
    y_vector = corners(2,:);
    
    center_of_mass = [round(sum(x_vector)/length(x_vector)),round(sum(y_vector)/length(y_vector))];
    
    up=0;left=0;down=0;right=0;
    
    %calculating the distances from center of piece to an imaginary line
    %going between the two corners of each face
    [~,~,ordered_corners] = classify_corners(corners');

    up_distance = center_of_mass(1) - round((ordered_corners(1,2)+ordered_corners(2,2))/2);
    right_distance = round((ordered_corners(2,1)+ordered_corners(3,1))/2) - center_of_mass(2);
    down_distance = round((ordered_corners(3,2)+ordered_corners(4,2))/2) - center_of_mass(1);
    left_distance = center_of_mass(2) - round((ordered_corners(1,1)+ordered_corners(4,1))/2);
    
    %calculating the length of the face from corner to corner
    up_length = ordered_corners(2,1) - ordered_corners(1,1);
    right_length = ordered_corners(3,2) - ordered_corners(2,2);
    down_length = ordered_corners(3,1) - ordered_corners(4,1);
    left_length = ordered_corners(4,2) - ordered_corners(1,2);
    
    threshold = 20; 
    

    %finding the right tag for each of the four sides of the piece
    for i=1:4
        
        xlocation = center_of_mass(2);
        ylocation = center_of_mass(1);
        
        if (i == 1) %up            
            while(bw_rotated_piece(xlocation,ylocation) == 1)
                xlocation = xlocation - 1;
            end
            
            distance = center_of_mass(1) - xlocation;
            if (up_distance - distance > threshold)
                piece_tags.up = 'hole';
            elseif (up_distance - distance < -threshold)
                piece_tags.up = 'head';
            else
                piece_tags.up = 'flat';
            end
            
            %measuring the distance of the top/bottom part of the face from
            %the center of piece, for later usage of connections
            distance = abs(distance-up_distance);
            if(distance < threshold)
                distance = 0;
            end
            
            faces_structure.up = {face(up,piece_tags.up,distance,up_length),'up'};
            
        
        elseif (i == 2) %right
            while(bw_rotated_piece(xlocation,ylocation) == 1)
                ylocation = ylocation + 1;
            end
            distance = ylocation - center_of_mass(2);
            if (right_distance - distance > threshold)
                piece_tags.right = 'hole';
            elseif (right_distance - distance < -threshold)
                piece_tags.right = 'head';
            else
                piece_tags.right = 'flat';
            end
            
            %measuring the distance of the top/bottom part of the face from
            %the center of piece, for later usage of connections
            distance = abs(distance-right_distance);
            if(distance < threshold)
                distance = 0;
            end
            
            faces_structure.right = {face(right,piece_tags.right,distance,right_length),'right'};
           
        elseif (i == 3) %down
            while(bw_rotated_piece(xlocation,ylocation) == 1)
                xlocation = xlocation + 1;
            end
            distance = xlocation - center_of_mass(1);
            if (down_distance - distance > threshold)
                piece_tags.down = 'hole';
            elseif (down_distance - distance < -threshold)
                piece_tags.down = 'head';
            else
                piece_tags.down = 'flat';
            end

            %measuring the distance of the top/bottom part of the face from
            %the center of piece, for later usage of connections
            distance = abs(distance-down_distance);
            if(distance < threshold)
                distance = 0;
            end
            
            faces_structure.down = {face(down,piece_tags.down,distance,down_length),'down'};
            
        elseif (i == 4) %left
            while(bw_rotated_piece(xlocation,ylocation) == 1)
                ylocation = ylocation - 1;
            end
            distance = center_of_mass(2) - ylocation;
            if (left_distance - distance > threshold)
                piece_tags.left = 'hole';
            elseif (left_distance - distance < -threshold)
                piece_tags.left = 'head';
            else
                piece_tags.left = 'flat';
            end
            
            %measuring the distance of the top/bottom part of the face from
            %the center of piece, for later usage of connections
            distance = abs(distance-left_distance);
            if(distance < threshold)
                distance = 0;
            end
            
            faces_structure.left = {face(left,piece_tags.left,distance,left_length),'left'};
            
        end
        
    end
        
    
    
    %labeling the piece to one of three options: corner, side or middle
    
    if (strcmp(piece_tags.up,'flat'))&&((strcmp(piece_tags.left,'flat') || strcmp(piece_tags.right,'flat')))
          piece_type = 'corner';

    
    
    elseif (strcmp(piece_tags.right,'flat') && strcmp(piece_tags.down,'flat'))
            piece_type = 'corner';
       

    
    elseif (strcmp(piece_tags.down,'flat') && strcmp(piece_tags.left,'flat'))
            piece_type = 'corner';
    
    
    elseif (strcmp(piece_tags.up,'flat') || strcmp(piece_tags.right,'flat') || ...
            strcmp(piece_tags.down,'flat') || strcmp(piece_tags.left,'flat'))
            
            piece_type = 'frame';
            
    else
            piece_type = 'internal';
            
    end

end