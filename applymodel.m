function Iseg=applymodel(I,GMModel)
    % Number of gaussians in the model
    k=GMModel.NumComponents;
    
    % Reconstruct the channels in F matrix
    I=double(I);
    R=I(:,:,1);
    G=I(:,:,2);
    B=I(:,:,3);

    F=[R(:),G(:),B(:)];
    
    % Scoring each pixel according to the propbability for each gaussian
    scores=zeros(size(F,1),k);
    for i=1:k
        scores(:,i)=GMModel.ComponentProportion(i)*mvnpdf(F,GMModel.mu(i,:),GMModel.Sigma(:,:,i));
    end
    
    % for each pixel find the gaussian that got the max score
    [~,idx]=max(scores,[],2);
    
    Iseg=reshape(idx,size(B));
end