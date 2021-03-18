function [Iconnected, solution_lables]=connect_pieces(solution_original)
    % copy solution
    solution=cell(size(solution_original));
    solution_lables=cell(size(solution_original));

    for row=1:size(solution,1)
        for col=1:size(solution,2)
            solution{row,col}=copy_piece(solution_original{row,col});
        end
    end
    
    size_rows=100;
    for i=1:size(solution,1)
        size_rows=size_rows+size(solution{i,1}.colored_shrinked_image,1);
    end
    size_cols=100;
    for j=1:size(solution,2)
        size_cols=size_cols+size(solution{1,j}.colored_shrinked_image,2);
    end
    
    % changing pieces sizes to fit the whole puzzle
    
    for p=1:length(solution(:))
        l=solution(p);
        l=l{1};
        l.onesize_piece(max(size_rows,size_cols))
    end
%      figure();hold on
    num_points=15;
    for r=1:size(solution,1)
        for c=1:size(solution,2)

                  % if this is the first row
            if r==1

                % if this is the first piece
                if c==1 
                    Iconnected=solution{1,1}.colored_image;
                    init_location=floor(size(solution{1, 1}.colored_shrinked_image)/2);
                    solution_lables{1,1}={solution{r,c}.piece_idx init_location(1:2)};
                else
                    % first row but not first piece

                    movingPoints=get_face_points([r,c],solution,'this',num_points);

                    fixedPoints=get_face_points([r,c],solution,'left',num_points)...
                                 +zeros(num_points,2)...
                                 +repmat([1 0],[num_points,1]);

                    solution{r,c}.corners=fixedPoints;
                    [solution{r,c}.colored_image, target_location]=aff_trans(solution{r,c},movingPoints(1:num_points,:),fixedPoints);
                    solution_lables{r,c}={solution{r,c}.piece_idx target_location};
                    Iconnected=Iconnected+solution{r,c}.colored_image;
                    
                end
                % any row except the first 
            else
                % first pieces in row > 1
                if c==1 
                    movingPoints=get_face_points([r,c],solution,'this',num_points);

                    fixedPoints=get_face_points([r,c],solution,'up',num_points)+repmat([1 0],[num_points,1]);
                    
                    [solution{r,c}.colored_image, target_location]=aff_trans(solution{r,c},movingPoints(num_points+1:end,:),fixedPoints);
                    solution_lables{r,c}={solution{r,c}.piece_idx target_location};
                    Iconnected=Iconnected+solution{r,c}.colored_image;
                else
                    % not first piece in row > 1
                    movingPoints=get_face_points([r,c],solution,'this',num_points);

                    fixedPoints=[get_face_points([r,c],solution,'left',num_points);...
                                 get_face_points([r,c],solution,'up',num_points)];

                    [solution{r,c}.colored_image, target_location]=aff_trans(solution{r,c},movingPoints,fixedPoints);
                    solution_lables{r,c}={solution{r,c}.piece_idx target_location};
                    Iconnected=Iconnected+solution{r,c}.colored_image;
                end
            end
%              imshow(Iconnected)
        end
    end
    % crop image
    binaryImage=rgb2gray(Iconnected);
    [r, c] = find(binaryImage);
    row1 = min(r);
    row2 = max(r);
    col1 = min(c);
    col2 = max(c);
    Iconnected = Iconnected(row1:row2, col1:col2,:);
%      imshow(Iconnected);
end


function [piece_move,target_location]=aff_trans(piece,movingPoints,fixedPoints)
    I=piece.colored_image;
    I_bw=piece.BWimage;
    
    tForm = fitgeotrans(movingPoints,fixedPoints,'affine');%'affine'  'NonreflectiveSimilarity'
    piece_move=imwarp(I, tForm,'OutputView',imref2d(size(I)));
    bw_piece_move=imwarp(I_bw, tForm,'OutputView',imref2d(size(I_bw)));
    for i=1:4
        new_face_points=transformPointsForward(tForm,flip(piece.faces{i}.face_points,2));
        piece.faces{i}.face_points=flip(new_face_points,2);
    end

    [r_mean, c_mean] = find(bw_piece_move == 1);
    target_location=[mean(c_mean), mean(r_mean)];
end


function face_points=get_face_points(location,solution,side,num_points)
    switch side
        case "this"
            leng_left=size(solution{location(1),location(2)}.faces{4}.face_points,1);
            face_points_left=solution{location(1),location(2)}.faces{4}.face_points(round((1:num_points)*leng_left/(num_points+1)),:);
            leng_up=size(solution{location(1),location(2)}.faces{1}.face_points,1);
            face_points_up=solution{location(1),location(2)}.faces{1}.face_points(round((1:num_points)*leng_up/(num_points+1)),:);
            face_points=flip([flip(face_points_left,1);flip(face_points_up,1)],2);
        case "left"
            leng=size(solution{location(1),location(2)-1}.faces{2}.face_points,1);
            face_points=flip(solution{location(1),location(2)-1}.faces{2}.face_points(round((1:num_points)*leng/(num_points+1)),:),2);
        case "up"
            leng=size(solution{location(1)-1,location(2)}.faces{3}.face_points,1);
            face_points=flip(solution{location(1)-1,location(2)}.faces{3}.face_points(round((1:num_points)*leng/(num_points+1)),:),2);
    end
end