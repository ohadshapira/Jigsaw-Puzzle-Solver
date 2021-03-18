function corners=get4corners(BW)
% this function will find the 4 corners of the piece and return the
% locations of them.

    B=bwboundaries(edge(BW), 'noholes');
    B=B{1};
    Yc=sum(B(:,1))/length(B(:,1));
    Xc=sum(B(:,2))/length(B(:,2));
    
    % converting to polar around the center of mass
    [teta,rho]=cart2pol(B(:,2)-Xc,Yc-B(:,1));

    d1=gradient(rho,2);

    pattern=[1 1 1 1 1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
    
    d1_wide=[d1(end-9:end);d1;d1(1:10)]';
    si=sign(d1_wide);
    cost=zeros(size(d1));
    for i=1:length(d1)
        cost(i)=sum(pattern.*d1_wide(i:20+i))+0.1*sum(pattern.*si(i:20+i));
    end
    [~,idx]=maxk(cost,40);

    corners_idx=find_corner_idx(idx,size(d1,1));
    
%     figure();plot(teta,rho,'.')
%     hold on
%     plot(teta(corners_idx),rho(corners_idx),'gx')
     
     X=B(:,2);
     Y=B(:,1);
     Xcorners=X(corners_idx);
     Ycorners=Y(corners_idx);
     [~,~,ordered_corners]=classify_corners([Xcorners,Ycorners]);
    corners=ordered_corners;
end

function four_corners_idx=find_corner_idx(max_idx,size_d1)
    min_dist=50;
    four_corners_idx=[];
    
    for i=1:4
        four_corners_idx(i)=max_idx(1);
        
        max_idx=max_idx(abs(max_idx-four_corners_idx(i))>min_dist);
        
        if abs(four_corners_idx(i)-size_d1)<=10 || abs(four_corners_idx(i)-size_d1)<=1
            max_idx=max_idx(max_idx<size_d1-10 & max_idx>10);
        end
    end
end

