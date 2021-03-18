function matches_cell_array = cost_shape(pieces_array,corners_idx,frame_idx,used_pieces,choose_type)
    % This fuction gets a puzzle piece and return the top match from the
    %       right
            
    %--------------------------------------------------------------------
    %input - pieces_array: cell array that include all the pieces
    %        corners_idx, corners_idx: a list that describe the locations 
    %                   of each puzzle type.
    %        choose_type: 'all', 'corner','frame' - will try only certain
    %                    type of piece
    %
    %        used_pieces: the pieces that already have been used
    %output - next_piece_idx: the index of the next piece in the cell array
    %         next_piece_shift: NOT USED YET - the pixel row shift
    %                     
    %---------------------------------------------------------------------
    
% getting the reference piece (the left one) information
starting_piece_idx=used_pieces(end);
starting_piece=copy_piece(pieces_array{starting_piece_idx});

border_idx = frame_idx;
if any(frame_idx==starting_piece_idx) % if the reference piece is a frame (not corner)
    border_idx = [frame_idx corners_idx];
end

matches_cell_array={};
switch choose_type
    case 'all'
        go_over_pieces=border_idx;
    case 'corner'
        go_over_pieces=corners_idx;
    case 'frame'
        go_over_pieces=frame_idx;
end
% figure
for i = 1:length(go_over_pieces)

    temp_piece=copy_piece(pieces_array{go_over_pieces(i)});

    if temp_piece.type=="corner"
         temp_piece.rotate;
         [~, start_y] = find(temp_piece.BWimage);
        shift_temp_piece_by=min(start_y)-5;

        tForm = affine2d([1 0 0; 0 1 0; -shift_temp_piece_by 0 1]);   

        temp_piece_BW=imwarp(temp_piece.BWimage, tForm,'OutputView',imref2d(size(temp_piece.BWimage)));
        temp_piece_colored=imwarp(temp_piece.colored_image, tForm,'OutputView',imref2d(size(temp_piece.BWimage)));

        temp_piece.set_BWimage(temp_piece_BW);
        temp_piece.set_colored_image(temp_piece_colored);
        temp_piece.corners=temp_piece.corners-repmat([shift_temp_piece_by,0],[4,1]);
        for f=1:4
            temp_piece.faces{f}.face_points=temp_piece.faces{f}.face_points-repmat([0 , shift_temp_piece_by],[size(temp_piece.faces{f}.face_points,1),1]);
        end
    end
    
    test_piece = temp_piece.BWimage;
    test_colored_piece = temp_piece.colored_image;    
    
    starting_piece_face=starting_piece.faces(2);
    test_piece_face=temp_piece.faces(4);
    
    
    if (any(go_over_pieces(i) == used_pieces) == 0 && ~strcmp(starting_piece_face{1}.type,test_piece_face{1}.type))
        % align second piece to be connected to the right side of the
        % refference piece
        starting_corner_piece_row_vector = sum(starting_piece.BWimage, 2);
        row_index = find(starting_corner_piece_row_vector, 1, 'first') + 20;


%         row_test = test_piece(row_index, :);
        row_start = starting_piece.BWimage(row_index, :);
        
        % this hold the left piece relevant edge
        starting_piece_right_edge = find(row_start, 1, 'last');

        num_points=15;
        leng_right=size(temp_piece.faces{4}.face_points,1);
        leng_left=size(starting_piece.faces{2}.face_points,1);
        movingPoints=temp_piece.faces{4}.face_points(round((1:num_points)*leng_right/(num_points+1)),:);
        
        fixedPoints=flip(starting_piece.faces{2}.face_points(round((1:num_points)*leng_left/(num_points+1)),:),1)...
                    +repmat([0 1],[num_points,1]);
                
        tForm = fitgeotrans(flip(movingPoints,2),flip(fixedPoints,2),'NonreflectiveSimilarity');
        test_piece_move=imwarp(test_piece, tForm,'OutputView',imref2d(size(test_piece)));
%         test_colored_piece_move=imwarp(test_colored_piece, tForm,'OutputView',imref2d(size(test_piece)));%,'OutputView',sameAsInput);
        
        
        
        
        % show images connected
%         subplot(4,4,i) %%% delete in future steps
%         imshow(starting_piece.colored_image+test_colored_piece_move);
% 
%         title(['Piece  ', int2str(starting_piece_idx), ' with ', int2str(go_over_pieces(i))])

        
        % calculate cost function
        and_pieces=test_piece_move&starting_piece.BWimage;
        and_overlap = sum(and_pieces(:));

        starting_piece_outline = get_piece_outline(starting_piece.BWimage);
        starting_piece_outline(:, starting_piece_right_edge-5:starting_piece_right_edge+5) = 0;
        
        and_dilate=test_piece_move&starting_piece_outline;
        dilate_overlap =  3*sum(and_dilate(:));

        overlap_cost = dilate_overlap - and_overlap;
        
        matches_cell_array{i,1}=go_over_pieces(i);
        matches_cell_array{i,2}=-overlap_cost/sum(starting_piece.BWimage(:));
    end
end

end
    