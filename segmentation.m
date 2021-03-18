function [BW,Inew, finalseg]=segmentation(I,puzzle_version)
%%      Ducks
    if puzzle_version==1

        load('model_22_2.mat','model');

        Inew=imresize(I,0.3);

        Iseg=applymodel(Inew,model);

        BW1=Iseg~=1  & Iseg~=4 & Iseg~=5;


%%   chewbacca
    elseif puzzle_version==2
        load('chewbacca/chewbacca_GMModel');
        Inew=I;
        Iseg=applymodel(Inew,model);
        BW1=(Iseg==2 |Iseg==3);
    end
    
    BW2=imfill(BW1,'holes');
    
    se= strel('disk',2);
    BW2=imerode(BW2,strel('disk',1));
    BW=imclose(BW2,se);
    
%     figure();imshow(BW)
    
    seg=zeros(size(Inew));
    for c=1:3
        seg(:,:,c)=double(Inew(:,:,c)).*double(BW);
    end
     finalseg=uint8(seg);
%        figure();imshow(finalseg)

end