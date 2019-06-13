function eigenbehaviorOut = eigenbehaviorEvaluator(allBinaryData)

accountNames = fieldnames(allBinaryData);

% Performing PCA and outputting eigenbehaviors
for i = 1 : size(accountNames,1)
    disp(i)
    pcaIn_temp = allBinaryData.(accountNames{i});
    %pcaIn_temp = (pcaIn_temp - mean(pcaIn_temp))./(std(pcaIn_temp));
    %pcaIn_temp(isnan(pcaIn_temp))=0;
    [coeff , score , latent , ~ , ex] = pca(pcaIn_temp,'Centered',true);
    eigenbehaviorOut.pcaOut(i).coeff = coeff;       % eigenvector
    eigenbehaviorOut.pcaOut(i).score = score;       % PCA loadings
    eigenbehaviorOut.pcaOut(i).latent = latent;     % explained variance
    eigenbehaviorOut.pcaOut(i).ex = ex;             % explained variance %
    eigenbehaviorOut.varPerc1(i) = ex(1);
    eigenbehaviorOut.varPerc2(i) = ex(2);
    eigenbehaviorOut.varPerc3(i) = ex(3);
    eigenbehaviorOut.varPerc4(i) = ex(4);
    eigenbehaviorOut.varPerc5(i) = ex(5);
    eigenbehaviorOut.eig1(:,i) = coeff(:,1);            % 1st eigbehavior
    eigenbehaviorOut.eig2(:,i) = coeff(:,2);            % 2nd eigbehavior
    eigenbehaviorOut.eig3(:,i) = coeff(:,3);            % 3rd eigbehavior
    eigenbehaviorOut.eig4(:,i) = coeff(:,4);            % 4th eigbehavior
    eigenbehaviorOut.eig5(:,i) = coeff(:,5);            % 5th eigbehavior
end

end