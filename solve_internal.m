function ordered_puzzle = solve_internal(frame_ordered,pieces_array,internal_idx)
    curr_position=[2,2];
    ordered_puzzle=frame_ordered;
    internal_pieces=pieces_array(internal_idx);
    

    
    while ~isempty(internal_pieces)
        
        num_not_used=length(internal_pieces);
        costs=zeros(num_not_used,4);
        % if the current location is empty
        if isempty(ordered_puzzle{curr_position(1),curr_position(2)})
            
            % check neighbors
            [left,up,right,down]=check_neigh(ordered_puzzle,curr_position);
            
            % loop over not used pieces
            for p=1:length(internal_pieces)
                
                % loop over all four sides for each piece
                for s=1:4
                    costs(p,s)=check_piece(internal_pieces{p},left,up,right,down);
                    internal_pieces{p}.rotate();
                end
            end
            % find best fit piece (lowest cost and allowed connection)
            [~,idx]=min(costs(:));
            [idxp,idxs]=ind2sub(size(costs),idx);
            
            % rotate piece to the correct position
            if idxs>1
                for i=1:idxs-1
                    internal_pieces{idxp}.rotate();
                end
            end
            % place piece at the location in the puzzle
            
            ordered_puzzle{curr_position(1),curr_position(2)}=internal_pieces{idxp};
            
            % remove piece from cell of not used pieces
            internal_pieces(idxp)=[];
            
            % move to the next piece on the right
            curr_position(2)=curr_position(2)+1;
        else
            % move to the next row
            curr_position(2)=2;
            curr_position(1)=curr_position(1)+1;
        end
        
        
    end
    
end



function [left,up,right,down]=check_neigh(frame_ordered,location)
    up=[]; right=[]; down=[]; left=[];
    
    %left
    if ~isempty(frame_ordered{location(1),location(2)-1})
        left=frame_ordered{location(1),location(2)-1}.faces{2};
    end
    
    %up
    if ~isempty(frame_ordered{location(1)-1,location(2)})
        up=frame_ordered{location(1)-1,location(2)}.faces{3};
    end
    
    %right
    if ~isempty(frame_ordered{location(1),location(2)+1})
        right=frame_ordered{location(1),location(2)+1}.faces{4};
    end
    
    %down
    if ~isempty(frame_ordered{location(1)+1,location(2)})
        down=frame_ordered{location(1)+1,location(2)}.faces{1};
    end
               
end

function cost=check_piece(piece,left,up,right,down)
    cost=2;
    if ~isempty(left)
        
        % get current piece faces
        left_face=piece.faces{4};
        
        if ~allowed_connection(left_face,left)
            return
        end
        
        % check the cost for left face
        cost_left=cost_color(left_face,left);
    else
        cost_left=0;
    end
    
    if ~isempty(up)
        % get current piece faces
        up_face=piece.faces{1};
        
        if ~allowed_connection(up_face,up)
            return
        end
        
        % check the cost for up face
        cost_up=cost_color(up_face,up);
        
    else
        cost_up=0;
    end
    
    if ~isempty(right)
        % get current piece faces
        right_face=piece.faces{2};
        
        if ~allowed_connection(right_face,right)
            return
        end    
        
        % check the cost for right face
        cost_right=cost_color(right_face,right);
    else
        cost_right=0;
    end
    
    if ~isempty(down)
        % get current piece faces
        down_face=piece.faces{3};

        if ~allowed_connection(down_face,down)
            return
        end    
        
        % check the cost for down face
        cost_down=cost_color(down_face,down);
        
    else
        cost_down=0;
    end
    
    % calculate cost
    cost=cost_left+cost_up+cost_right+cost_down;
end

function val=allowed_connection(f1,f2)
    % fgddf
    if (f1.type=='head' & f2.type=='hole') | (f1.type=='hole' & f2.type=='head')
        val=true;
    else
        val=false;
    end
end


