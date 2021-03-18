function [colored_pieces, bw_pieces,locations_pieces] = get_pieces( original_image, BW_image )
    %{
    Input:
    original_image - Original given image
    BW_image - Black and with image of the puzzle

    Output:
    colored_pieces - Cells for each colored pieces
    bw_pieces - Cells for each BW pieces
    %}


    %smoothing the edges of the BW image
    windowSize = 7;
    kernel = ones(windowSize) / windowSize ^ 2;
    blurryImage = conv2(single(BW_image), kernel, 'same');
    BW_image = blurryImage > 0.5; % Rethreshold

    BW_original_image=imclearborder(BW_image);
    BW_original_image= bwareaopen(BW_original_image, 50);

    seperated_pieces= bwlabel(BW_original_image);


    colored_pieces={};
    bw_pieces={};
    locations_pieces={}; %% label_show

    for piece=1:max(seperated_pieces(:))    %real_pieces.NumObjects
        single_piece=zeros(size(BW_original_image));%     single_piece(real_pieces.PixelIdxList{piece})=1;

        single_piece(seperated_pieces==piece)=1;
        if sum(single_piece(:))>3000
            idx_max_col=max(find(sum(single_piece)));
            idx_min_col=min(find(sum(single_piece)));

            idx_max_row=max(find(sum(single_piece')));
            idx_min_row=min(find(sum(single_piece')));
            
            [r_mean, c_mean] = find(single_piece == 1);     %% label_show
            locations_pieces{end+1} = [mean(c_mean), mean(r_mean)];  %% label_show

            % colorful piece
            color_piece=original_image;
            color_piece(logical(1-single_piece))=0;
            single_color_piece=color_piece(idx_min_row-15:idx_max_row+15,idx_min_col-15:idx_max_col+15,1:3); 
              

            % bw piece
            single_bw_piece=single_piece(idx_min_row-15:idx_max_row+15,idx_min_col-15:idx_max_col+15); 
            
            if isempty(bw_pieces)
                colored_pieces{1}=single_color_piece;
                bw_pieces{1}=single_bw_piece;
            else
                colored_pieces{end+1}=single_color_piece;  
                bw_pieces{end+1}=logical(single_bw_piece);
            end

            % separating the background from the puzzle pieces
            for c=1:3
                colored_pieces{end}=uint8(double(colored_pieces{end}).*double(bw_pieces{end}));
            end

        end
    end
        
    
end