function [Isegmentation,GMModel]=GMMseg(I,k)
    % Reconstruct the channels in F matrix
    I=double(I);
    R=I(:,:,1);
    G=I(:,:,2);
    B=I(:,:,3);

    F=[R(:),G(:),B(:)];
    
    
    % Find GM model in the Features space
    GMModel=fitgmdist(F,k,'Options',statset('Display','final','MaxIter',1000)); 
    
    % Number of gaussians in the model (if the number of gaussians was changed)
    k=GMModel.NumComponents;
    
    % Scoring each pixel according to the propbability for each gaussian
    scores=zeros(size(F,1),k);
    
    for i=1:k
        scores(:,i)=GMModel.ComponentProportion(i)*mvnpdf(F,GMModel.mu(i,:),GMModel.Sigma(:,:,i));
    end
    
    % for each pixel find the gaussian that got the max score
    [~,idx]=max(scores,[],2);
    Isegmentation=reshape(idx,size(R));
end