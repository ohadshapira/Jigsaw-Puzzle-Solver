clear all
close all
clc


%%
% Made by Ohad Shapira
% 

puzzle_version=0;
while(~any([1,2]==puzzle_version))
    if (~puzzle_version==0)
        disp('Wrong input, try again')
    end
    prompt = ['Choose puzzle:\n',...
        '1 - Ducks\n',...
        '2 - Chewy\n'];
    puzzle_version = input(prompt);
end


% Every line in the comments are a different  picture that 
% you can try to run the algorithm on, just uncommect and run program. 
% enjoy the results?

if puzzle_version==1
    disp('You chose ducks puzzle, great choice!')
    
    I=imread('Ducks/test2.jpg'); % perfect solution
%     I=imread('Ducks/test3.jpg'); % perfect solution
%     I=imread('Ducks/test5.jpg'); % perfect solution
%     I=imread('Ducks/test7.jpg'); % perfect solution
%     I=imread('Ducks/test10.jpg'); % perfect solution

%     I=imread('Ducks/test1.jpg'); % partial solution
%     I=imread('Ducks/test4.jpg'); % partial solution
%     I=imread('Ducks/test6.jpg'); % partial solution
%     I=imread('Ducks/test8.jpg'); % partial solution
%     I=imread('Ducks/test9.jpg'); % partial solution
elseif puzzle_version==2
    disp('You chose chewbacca puzzle, great choice!')
    I=imread('chewbacca/chewbacca_puzzle2.jpg');
end

figure();imshow(I);title('Input image')

pieces=puzzle(I,puzzle_version);
show_original_image_labeled(pieces.Isegmentation,pieces);
ordered_puzzle=pieces.solve();
[con, lables_locations]=connect_pieces(ordered_puzzle);
show_connected_image_labeled(con, lables_locations);



