function [center,teta_corners,ordered_corners]=classify_corners(corners)
%output points
%p1-------p2
%|         |
%|         |
%p4-------p3

    Xc = round(sum(corners(:,1))/4);
    Yc = round(sum(corners(:,2))/4);
    
    center = [Xc,Yc];
    
    
    teta_corners=cart2pol(corners(:,1)-Xc,Yc-corners(:,2));
    [~,idx]=sort(teta_corners,'descend');
    
    teta_corners=teta_corners(idx);
    ordered_corners=corners(idx,:);
end