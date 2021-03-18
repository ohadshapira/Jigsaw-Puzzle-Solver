function cost=cost_color(face1,face2)
    v1=face1.color_strip(:,:,:);
    v2=face2.color_strip(:,:,:);
    v1_flip=flip(v1,2);
    v2_flip=flip(v2,1);

    v1_mean=mean(v1_flip,2)/255;
    v2_mean=mean(v2_flip,2)/255;
    N=size(v1,1);
    cost=reshape((v1_mean-v2_mean).^2,[N,3])/(3*N);
    cost=sum(cost(:));

end