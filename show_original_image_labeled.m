function show_original_image_labeled(I, pieces)
    image_annotations=I;
    for p=1:length(pieces.pieces_array)
        image_annotations=insertText(image_annotations, pieces.pieces_array{p}.original_location,pieces.pieces_array{p}.piece_idx,'FontSize',30);
    end
    figure; imshow(image_annotations);
    title('Labeled pieces after segmentation')
end