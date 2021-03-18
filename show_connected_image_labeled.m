function show_connected_image_labeled(I, locations)
    image_annotations=I;
    for r=1:size(locations,1)
        for c=1:size(locations,2)
            relevant_piece=locations{r,c};
            image_annotations=insertText(image_annotations, relevant_piece{2},relevant_piece{1});
        end
    end
    figure; 
    imshow(image_annotations);
    title('Solved puzzle')
end