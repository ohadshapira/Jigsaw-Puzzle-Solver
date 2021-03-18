function tree=build_tree(tree,pieces_array,piece_num,corners_idx,frame_idx,used_pieces,weights,solution_array,row_idx,col_idx,frame,last_corner_loc_r,last_corner_loc_c,count_sec_choise)
    if length([corners_idx,frame_idx])>=piece_num
        if frame==3 && isequal(pieces_array{used_pieces(end)}.type,'corner')
            last_corner_loc_r=size(solution_array,1);
            last_corner_loc_c=1;
        end
        if last_corner_loc_r~=0
            if last_corner_loc_r==row_idx && last_corner_loc_c==col_idx
                choose_type='corner';
            else
                choose_type='frame';
            end
        else
            choose_type='all';
        end
        % find matches
        try
            matches_cell_array=cost_shape(pieces_array,corners_idx,frame_idx,used_pieces,choose_type);
                matches=cell2mat(matches_cell_array);

            % cost by color for every possible piece
            cost_by_color=zeros(size(matches,1),1);
            for optional_piece=1:size(matches,1)
                start_piece=pieces_array{1,used_pieces(end)};
                starting_relevant_face=start_piece.faces{2};

                test_piece=pieces_array{1,matches(optional_piece,1)};
                if isequal(test_piece.type,'corner')
                    test_relevant_face=test_piece.faces{3};
                else
                    test_relevant_face=test_piece.faces{4};
                end

                cost_by_color(optional_piece)=cost_color(starting_relevant_face,test_relevant_face);
            end
%             matches
%             2*cost_by_color
            matches(:,2)=matches(:,2)+2*cost_by_color;
%             matches
            [min_costs, best_connection_idx]=mink(matches(:,2),2);
            
            for i=1:length(min_costs)
                if i~=1
                    count_sec_choisei=count_sec_choise+1;
                else
                    count_sec_choisei=count_sec_choise;
                end
                if count_sec_choisei<=2
                    next_piece=copy_piece(pieces_array{matches(best_connection_idx(i),1)});
                    used_pieces(piece_num)=matches(best_connection_idx(i),1);
                    weights(piece_num)=min_costs(i);
                    solution_array{row_idx,col_idx}=next_piece; % position in the cell array

                     if next_piece.type=="corner" % when got corner - change direction
                        framei=frame+1;
                     else
                         framei=frame;
                     end

                        for rot=1:framei-1
                            next_piece.rotate;
                        end

                        switch framei
                            case 1
                                col_idxi=col_idx+1;
                                row_idxi=row_idx;
                            case 2
                                col_idxi=col_idx;
                                row_idxi=row_idx+1;
                            case 3
                                row_idxi=row_idx;
                                col_idxi=col_idx-1;
                            case 4
                                col_idxi=col_idx;
                                row_idxi=row_idx-1;
                        end
                        tree=build_tree(tree,pieces_array,piece_num+1,corners_idx,frame_idx,used_pieces,weights,solution_array,row_idxi,col_idxi,framei,last_corner_loc_r,last_corner_loc_c,count_sec_choisei);
                end
            end
        catch
            
        end
    else
        if ~isempty(solution_array{2,1})
            
            % store branch, weights and solution in the tree
            tree.branches{end+1,1}=used_pieces;
            tree.weights{end+1,1}=weights;
            tree.solutions{end+1,1}=solution_array;
        end
    end
end