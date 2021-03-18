classdef puzzle < handle
    
    properties
        number_of_pieces
        BW
        Inewsize
        Isegmentation
        colored_pieces
        bw_pieces
        locations_pieces
        pieces_array
        corners_idx
        frame_idx
        internal_idx
    end
    
    methods
        function obj = puzzle(Image,puzzle_version)
            [obj.BW,obj.Inewsize, obj.Isegmentation]=segmentation(Image,puzzle_version);

            [obj.colored_pieces, obj.bw_pieces, obj.locations_pieces] = get_pieces( obj.Inewsize, obj.BW );

            obj.number_of_pieces=length(obj.bw_pieces);
            obj.corners_idx=[];
            obj.frame_idx=[];
            obj.internal_idx=[];
            max_piece_size=0;
            
            obj.pieces_array=cell(1,obj.number_of_pieces);

            for i=1:obj.number_of_pieces
                disp(['Creating piece number ',num2str(i)])
                bw_piece = obj.bw_pieces{1,i};
                 corners=get4corners(bw_piece)';
                 
                [bw_rotated_piece , colored_rotated_piece, corners] = rotate_piece(corners,bw_piece, obj.colored_pieces{1,i});
                [~,type,faces_structure,center_of_mass] = tag_sides(bw_rotated_piece, corners);
                obj.pieces_array{1,i} = piece(bw_rotated_piece, colored_rotated_piece,corners,center_of_mass);
                obj.pieces_array{1,i}.set_type(type);
                obj.pieces_array{1,i}.set_piece_idx(i);
                obj.pieces_array{1,i}.set_original_location(obj.locations_pieces{1,i});
                obj.pieces_array{1,i}.set_face(faces_structure.up{1},faces_structure.up{2});
                obj.pieces_array{1,i}.set_face(faces_structure.right{1},faces_structure.right{2});
                obj.pieces_array{1,i}.set_face(faces_structure.down{1},faces_structure.down{2});
                obj.pieces_array{1,i}.set_face(faces_structure.left{1},faces_structure.left{2});
                obj.pieces_array{1,i}.standart_shape();
                obj.pieces_array{1,i}.shrink_piece(); % make the pieces mask as small as posible
                max_piece_size=max(max_piece_size, max(size(obj.pieces_array{1,i}.BWimage)));
                
                % map piece by type
                switch type
                    case "internal"
                        obj.internal_idx(end+1)=i;
                    case "frame"
                        obj.frame_idx(end+1)=i;
                    case "corner"
                        obj.corners_idx(end+1)=i;
                end

            end
%             figure()
            for p = 1:obj.number_of_pieces
                obj.pieces_array{1,p}.onesize_piece(max_piece_size+50);
                % Show pieces with corners marks
%                 subplot(4,4,p)
%                 imshow(obj.pieces_array{p}.colored_image)
%                 hold on; plot(obj.pieces_array{1,p}.corners(:,1),obj.pieces_array{1,p}.corners(:,2),'.r')
%                 title(['Piece ' int2str(p)]);
            end  
            
            for i=1:obj.number_of_pieces
                obj.pieces_array{i}.set_color_strip();
            end
        end
        
        function solution_array=solve(obj)
            m=zeros(4,4+length(obj.frame_idx));
            solution_frame=cell(1,4);
            cost=zeros(1,4);
            for i=1:4
                    [solution_frame{1,i},m(i,:),cost(1,i)]=solve_frame2(obj.pieces_array,obj.corners_idx,obj.frame_idx,i);
            end
            
            [~,idx]=min(cost);
            solution_array=solve_internal(solution_frame{1,idx},obj.pieces_array,obj.internal_idx);
        end
        
        
        
    end
    
    methods (Static)
    end
    
end
        