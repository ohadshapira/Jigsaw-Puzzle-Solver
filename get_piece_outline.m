function outline = get_piece_outline( piece )
    dilate = imdilate(piece, ones(1, 31));
    outline = xor(piece, dilate);
end

