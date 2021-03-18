function [EdgeColorPixels]=edgepxls(Icolor,BW,points)
% this function will get the 5 near pixels from a feature point on the edge with the same orientation.
% Input- 
%   Icolor-the colored image of the piece
%   BW- binary mask of the piece
%   points- feature points on the edge

% Output- 
%   EdgeColorPixels- matrix with the size (num of points)*5*3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    N=100;
    EdgeColorPixels=zeros(N,5,3);
    
    BWedge=edge(BW);

    for i=1:N
        p=round(i*length(points)/N);
        
        i1=points(p,1);
        j1=points(p,2);
        % get 5x5 around pixel
        k=BWedge(round(i1-2):round(i1+2),round(j1-2):round(j1+2));
        theta=regionprops(k,'Orientation');
        
        theta=theta.Orientation;
        
        if posdirection(BW,i1,j1,theta)
            dir=90;
        else
            dir=-90;
        end

        for r=1:5
            
            if theta~=0
                t=theta+dir;
                x1=j1;
                y1=-i1;
                if t>=-90 && t<=90
                    s=1;
                else 
                    s=-1;
                end
                x2=(s*(r+1)/(sqrt(1+tand(t)^2)))+x1;
                y2=y1+(x2-x1)*tand(t);
                j2=x2;
                i2=-y2;

                EdgeColorPixels(i,r,:)=Icolor(round(i2),round(j2),:);
            else

                EdgeColorPixels(i,r,:)=Icolor(round(i1-r*sign(dir)),round(j1),:);
            end
        end

    end
        

end

function ispositive=posdirection(BW,i1,j1,theta)
    r=3;
    t=theta+90;
    x1=j1;
    y1=-i1;

    if t~=90 && t~=-90
        if t>-90 && t<90
            s=1;
        elseif t>90 || t<-90
            s=-1;
        end
        x2=(s*r/(sqrt(1+tand(t)^2)))+x1;
        y2=y1+(x2-x1)*tand(t);
        j2=x2;
        i2=-y2;

        ispositive=BW(round(i2),round(j2));
    %     figure();imshow(BW);hold on;plot(j2,i2,'ro');plot(j1,i1,'bo')
    else
        ispositive=BW(round(i1-r),round(j1));
    end

end