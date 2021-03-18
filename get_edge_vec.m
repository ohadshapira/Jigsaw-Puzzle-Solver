function [edge_vector_up,edge_vector_right,edge_vector_down,edge_vector_left]=get_edge_vec(BW,cornersX,cornersY)
%   this function is finding the exact location points of the edge of a BW
%   image of a piece.
%   the output is 4 vectors - for each face. each vector is going over all
%   face points from corner to corner and containing the x,y locations of
%   each points.


    [~,~,ordered_corners]=classify_corners([cornersX,cornersY]);
%order corners:
%p1-------p2
%|         |
%|         |
%p4-------p3

ordered_corners=round(ordered_corners);
    %% up

    %start point
    start_point=find_start_point(ordered_corners(1,:),BW);
    
    %end point
    end_point=find_end_point(ordered_corners(2,:),BW);

    % travel on the up edge
    edge_vector_up=travel_on_edge(start_point,end_point,BW);

    %% right
    %start point
    start_point=find_start_point(ordered_corners(2,:),BW);
    
    %end point
    end_point=find_end_point(ordered_corners(3,:),BW);

    % travel on the right edge
    edge_vector_right=travel_on_edge(start_point,end_point,BW);
    %% down
    %start point
    start_point=find_start_point(ordered_corners(3,:),BW);
    
    %end point
    end_point=find_end_point(ordered_corners(4,:),BW);
    
    % travel on the down edge
    edge_vector_down=travel_on_edge(start_point,end_point,BW);
    %% left
    %start point
    start_point=find_start_point(ordered_corners(4,:),BW);
    
    %end point
    end_point=find_end_point(ordered_corners(1,:),BW);
    
    % travel on the left edge
    edge_vector_left=travel_on_edge(start_point,end_point,BW);
end

%% internal functions

function [row,col]=get_point_from_kernel(kernel)
% this function finds the edge point from a 3x3 kernel
% using the following transformation:
%
%5 4 3
%6   2
%7 8 1
%=>[1 2 3 4 5 6 7 8]
    
    tr=[6 9 8 7 4 1 2 3 6 9];
    v=kernel(:);
    v_tr=v(tr)';
    locations=strfind(v_tr,[1 1 0]);
%     disp(locations)
    if isempty(locations)
        locations=strfind(v_tr,[1 0]);
            if isempty(locations)
                m=0;
            end
        [row,col]=ind2sub([3 3],tr(locations(1)));
    else
        [row,col]=ind2sub([3 3],tr(locations(1)+1));
    end

    
end

function start_point=find_start_point(corner,BW)
% find start point on the BW image
    corner_start_r=corner(1,2);
    corner_start_c=corner(1,1);
    kernel=BW(corner_start_r-1:corner_start_r+1,corner_start_c-1:corner_start_c+1);
    if  all(kernel(:))==1 || all(~kernel(:))==1
        kernel5=BW(corner_start_r-2:corner_start_r+2,corner_start_c-2:corner_start_c+2);
        tr=[2 1 6 11 16 21 22 23 24 25 20 15 10 5 4 3 2 1 6];
        v=kernel5(:);
        v_tr=v(tr)';
        locations=strfind(v_tr,[0 1 1]);
        [r,c]=ind2sub([5 5],tr(locations(1)+1));
        start_point(1,1:2)=[corner_start_r+r-3,corner_start_c+c-3];
            
    elseif BW(corner_start_r,corner_start_c)==0
        [r,c]=get_point_from_kernel(kernel);
        
        start_point(1,1:2)=[corner_start_r+r-2,corner_start_c+c-2];
        
    else
        start_point(1,1:2)=[corner_start_r,corner_start_c];
    end
end

function end_point=find_end_point(corner,BW)
% find end point on the BW image 
    corner_end_r=corner(1,2);
    corner_end_c=corner(1,1);
    kernel=BW(corner_end_r-1:corner_end_r+1,corner_end_c-1:corner_end_c+1);
    if all(kernel(:))==1 || all(~kernel(:))==1
        kernel5=BW(corner_end_r-2:corner_end_r+2,corner_end_c-2:corner_end_c+2);
        tr=[2 1 6 11 16 21 22 23 24 25 20 15 10 5 4 3 2 1 6];
        v=kernel5(:);
        v_tr=v(tr)';
        locations=strfind(v_tr,[0 1 1]);
        [r,c]=ind2sub([5 5],tr(locations(1)+1));
        end_point(1,1:2)=[corner_end_r+r-3,corner_end_c+c-3];
        
    elseif BW(corner_end_r,corner_end_c)==0
        [r,c]=get_point_from_kernel(kernel);
        end_point=[corner_end_r+r-2,corner_end_c+c-2]; 
            
    else
        end_point=[corner_end_r,corner_end_c];
        
    end
end

function edge_vector=travel_on_edge(start_point,end_point,BW)
% this function is traveling on the edge of the BW piece and storing the
% locations from start to end.
    edge_vector=start_point;
    while edge_vector(end,1)~=end_point(1,1) || edge_vector(end,2)~=end_point(1,2)
        if close_to_end(edge_vector(end,:),end_point)
            edge_vector(end+1,:)=end_point;
        else
            kernel=BW(edge_vector(end,1)-1:edge_vector(end,1)+1,edge_vector(end,2)-1:edge_vector(end,2)+1);

            [r,c]=get_point_from_kernel(kernel);

            edge_vector(end+1,:)=[edge_vector(end,1)+r-2,edge_vector(end,2)+c-2];
        end
    end
end

function val=close_to_end(edge_vec,endp)
    r=edge_vec(1,1);
    c=edge_vec(1,2);
    val=false;
    if (r+1==endp(1,1)&&c+1==endp(1,2)) || (r==endp(1,1)&&c+1==endp(1,2)) ||(r-1==endp(1,1)&&c+1==endp(1,2))...
        ||(r+1==endp(1,1)&&c==endp(1,2)) || (r-1==endp(1,1)&&c==endp(1,2)) ...
        ||(r+1==endp(1,1)&&c-1==endp(1,2)) ||(r==endp(1,1)&&c-1==endp(1,2)) || (r-1==endp(1,1)&&c-1==endp(1,2)) 
        val=true;
    end
end
    