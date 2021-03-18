function [solution_array,frame_order,min_cost] = solve_frame2(pieces_array,corners_idx,frame_idx,start)
% function to solve the frame of the puzzle by building a binary tree of
% possible solutions starting from a spessific corner.

    tree.branches={};
    tree.weights={};
    tree.solutions={};

    frame=1;
    row=1;
    col=2;
    tic
    tree=build_tree(tree,pieces_array,2,corners_idx,frame_idx,corners_idx(start),0,{pieces_array{corners_idx(start)}},row,col,frame,0,0,0);
    toc

    % pick the best solution- minimum cost for all pieces
    
    m=cell2mat(tree.weights);
    s=sum(m,2);
    [min_cost,idx]=min(s);
    solution_array=tree.solutions{idx,1};
    order=cell2mat(tree.branches);
    frame_order=order(idx,:);
end