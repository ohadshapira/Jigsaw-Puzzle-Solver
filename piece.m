classdef piece < matlab.mixin.Copyable
    
    properties
        BWimage     % binary image of the piece
        colored_image % colored image of the piece
        faces={[],[],[],[]}    % face order- {up right down left}
        type        % 'internal','frame','corner'
        corners_mask %[X,Y] corners of the image
        center_of_mass %[X,Y] coordinates of center of mass of the piece
        colored_shrinked_image % colored image of the piece with 5px borders
        corners         % classified corners
        original_location
        target_location
        piece_idx
    end

    methods
        function obj = piece(BW,colored_image,corners,center_of_mass)      % class constructor
            obj.BWimage = BW;
            obj.colored_image = colored_image;
            [~,~,obj.corners] = classify_corners(corners');
            obj.center_of_mass = center_of_mass;
        end
        
        function set_face(obj,face,direction)
            order={'up','right','down','left'};
            
            if ~ismember(direction,order)    % check if direction is valid
                throwAsCaller(MException('','Direction must be one of the following: up,left,down or right'))
                
            elseif ~isa( face, 'face' )      % check if face parameter is instance of face class
                throwAsCaller(MException('','Face must be instance of face class'))
                
            else
                i=find(ismember(order,direction));
                obj.faces{i}=face;
               % obj.distance = distance;
            end
        end
        
        function standart_shape(obj)   %rotating the image to standart shape for each type
            if(strcmp(obj.type,'corner'))
                while(~strcmp(obj.faces{1,1}.type,'flat') || ~strcmp(obj.faces{1,4}.type,'flat'))
                    rotate(obj);
                end

            elseif(strcmp(obj.type,'frame'))
                while(~strcmp(obj.faces{1,1}.type,'flat'))
                    rotate(obj);
                end   
            end
        end
        
        function shrink_piece(obj)   % fix rotating and shrink borders
            face_border_pad = 5;
            
            BW_image=obj.BWimage;
%             optimal_rotation_angle=0;
%             [curr_row_count, curr_col_count] = size(BW_image);
            
            if(~strcmp(obj.type,'internal'))
                    corners=obj.corners';
                    coefficient = (corners(2,2)+2*(corners(2,1)-corners(2,2))-corners(2,1))/(corners(1,2)-corners(1,1));
                    angle = -atan((coefficient))*180/pi;
                    rotated_piece=imrotate(BW_image,angle);
                    
                    j = sum(rotated_piece); 
                    rows_idx = find(j); 
                    min_row = min(rows_idx); 
                    max_row = max(rows_idx);

                    relevant_cols = sum(rotated_piece,2); 
                    cols_idx = find(relevant_cols); 
                    min_col = min(cols_idx); 
                    max_col = max(cols_idx);
                    
                    centerB=size(rotated_piece)'/2;
                    
                    rotated_piece = rotated_piece(min_col-face_border_pad:max_col+face_border_pad,min_row-face_border_pad:max_row+face_border_pad);
                    rotated_colored_piece = imrotate(obj.colored_image,angle);
                    
                    padded_image = rotated_colored_piece(min_col-face_border_pad:max_col+face_border_pad,min_row-face_border_pad:max_row+face_border_pad,:);

                    R=[cosd(angle),-sind(angle);sind(angle),cosd(angle)];
                    ij=[corners(2,:);corners(1,:)];
                    centerA=size(BW_image)'/2;
                    Rotated_corners = flip(R*(ij-centerA)+centerB)-repmat([min_row-face_border_pad;min_col-face_border_pad],[1,4])+1;
                    
                    obj.set_BWimage(rotated_piece)
                    obj.set_colored_image(padded_image)
                    [~,~,obj.corners]=classify_corners(Rotated_corners');
                    obj.set_shrinked_colored_image(padded_image)
            else
                relevant_rows = sum(BW_image); 
                rows_idx = find(relevant_rows); 
                min_row = min(rows_idx); 
                max_row = max(rows_idx);

                relevant_cols = sum(BW_image,2); 
                cols_idx = find(relevant_cols); 
                min_col = min(cols_idx); 
                max_col = max(cols_idx);
                
                bw_piece=BW_image(min_col-face_border_pad:max_col+face_border_pad,min_row-face_border_pad:max_row+face_border_pad);
                padded_image = obj.colored_image(min_col-face_border_pad:max_col+face_border_pad,min_row-face_border_pad:max_row+face_border_pad,:);
                
                obj.corners=obj.corners()-repmat([min_row-face_border_pad,min_col-face_border_pad],[4,1])+1;
                obj.set_BWimage(bw_piece)
                obj.set_colored_image(padded_image)
                obj.set_shrinked_colored_image(padded_image)
            end
            
        end
        
        function onesize_piece(obj, piece_size)   %make piece in same size as the other pieces
            temp_piece = obj.BWimage;
            temp_colored_piece = obj.colored_image;
            [piece_row_num, piece_col_num] = size(temp_piece);
            delta_rows = piece_size-piece_row_num;
            delta_cols = piece_size-piece_col_num;

            if (delta_rows > 0)
                temp_piece = [temp_piece; zeros(delta_rows, piece_col_num)];
                padded_image = uint8(zeros(size(temp_piece,1),size(temp_piece,2),3));
                padded_image(1:size(temp_colored_piece,1),1:size(temp_colored_piece,2),:) = temp_colored_piece;
                temp_colored_piece= padded_image;
            else
                disp('Error row number')
            end

            if (delta_cols > 0)
                temp_piece = [temp_piece, zeros(piece_size, delta_cols)];
                padded_image = uint8(zeros(size(temp_piece,1),size(temp_piece,2),3));
                padded_image(1:size(temp_colored_piece,1),1:size(temp_colored_piece,2),:) = temp_colored_piece;
                temp_colored_piece= padded_image;
            else
                disp('Error col number')
            end
            
            obj.set_BWimage(imfill(temp_piece,'holes'))
            obj.set_colored_image(temp_colored_piece)
        end
        
        function set_BWimage(obj,BW)
            obj.BWimage = logical(round(BW));
        end
        function set_colored_image(obj,color)
            obj.colored_image = color;
        end
        function set_corners_mask(obj,corners)
            obj.corners_mask = logical(corners);
        end
        function set_original_location(obj,original_location)
            obj.original_location = original_location;
        end
        function set_target_location(obj,target_location)
            obj.target_location = target_location;
        end
        function set_piece_idx(obj,piece_idx)
            obj.piece_idx= piece_idx;
        end          
        function set_shrinked_colored_image(obj,shrinked_color)
            obj.colored_shrinked_image = shrinked_color;
        end
        function set_type(obj,input_type) %set the type of the piece (internal, corner or frame)
            valid_types={'internal','frame','corner'};
            if ~ismember(input_type,valid_types)    % check if direction is valid
                throwAsCaller(MException('','Type must be one of the following: internal,frame or corner'))
            else
                obj.type=input_type;
            end
        end
        
        
        function rotate(obj)    % rotates the image clockwise
            obj.BWimage = rot90(obj.BWimage,3);
            obj.colored_image = rot90(obj.colored_image,3);
            obj.corners_mask = rot90(obj.corners_mask,3);
            obj.colored_shrinked_image =rot90(obj.colored_shrinked_image,3);

            j=obj.corners(:,1);
            obj.corners(:,1)=size(obj.BWimage,2)-obj.corners(:,2)+1;
            obj.corners(:,2)=j;
            
            [~,~,obj.corners]=classify_corners(obj.corners);

           % circular clockwise rotation of the faces and their features
           temp = obj.faces{1,4};
           obj.faces{1,4} = obj.faces{1,3};
           obj.faces{1,3} = obj.faces{1,2};
           obj.faces{1,2} = obj.faces{1,1};
           obj.faces{1,1} = temp;
           
           % inside each face, rotate the face points
            for i=1:4
                obj.faces{i}.rotate_face(size(obj.BWimage));
            end

        end
        
        function returned_face=get_face(obj,direction) % get face features easily
            
            order={'up','right','down','left'};
            if ~ismember(direction,order)    % check if direction is valid
                throwAsCaller(MException('','Direction must be one of the following: up,right,down or left'))
            else
                i=find(ismember(order,direction));    
                returned_face=obj.faces{i}.harris_features;
            end
        end
        
        function set_color_strip(obj)
            [up,right,down,left]=get_edge_vec(obj.BWimage,obj.corners(:,1),obj.corners(:,2));
            %set color strip and edge points for face up
            obj.faces{1}.face_points=up;
            obj.faces{1}.color_strip=edgepxls(obj.colored_image,obj.BWimage,up);
            %set color strip and edge points for face right
            obj.faces{2}.face_points=right;
            obj.faces{2}.color_strip=edgepxls(obj.colored_image,obj.BWimage,right);
            %set color strip and edge points for face down
            obj.faces{3}.face_points=down;
            obj.faces{3}.color_strip=edgepxls(obj.colored_image,obj.BWimage,down);
            %set color strip and edge points for face left
             obj.faces{4}.face_points=left;
            obj.faces{4}.color_strip=edgepxls(obj.colored_image,obj.BWimage,left);
        end
        
        function show_piece(obj)
            imshow(obj.colored_shrinked_image)
        end
        
        function newpiece=copy_piece(obj)
            newpiece=copy(obj);
            for i=1:4
                newpiece.faces{i}=copy(obj.faces{i});
            end
        end
    end
    

    
    methods (Static)

    end
    
end
        