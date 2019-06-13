home = pwd;
addpath(genpath(pwd));
set(0,'DefaultFigureWindowStyle','docked');

rng(1);

% ::: Loading processed data
load allAccountsData_PROCESSED.mat

numAccounts = length(fieldnames(allAccountsData)); % Number of accounts
accountNames = fieldnames(allAccountsData);

%% ::: Preliminary analysis to chose the best number of clusters and tSNE paramenterization
numHourAgg = [1,3,6];

% Choosing the best (= max silhouette) clustering and tSNE parameterization
for numAggregations = 1:3 % Loop on time aggregation
    allPerformances = [];
    for perplexity=5:5:30 % Loop on perplexity
        
        % Creating binary matrices for eigenbehavior extraction
        windowSize = numHourAgg(numAggregations); % Number of hours for time aggregation
        for i =1:numAccounts
            temp = allAccountsData.(accountNames{i}).allData(:,6:end);
            for j=1:size(temp,2)
                tempEU = temp(:,j);
                if max(tempEU)>=1000
                    tempEU(tempEU==max(tempEU))=0;
                end
                tempEU(tempEU>prctile(tempEU(tempEU>0),95))=0;
                temp(:,j) = tempEU;
            end
            % Reshaping data
            tempAll = [];
            for j = 1:size(temp,2)
                temp1 = sum(reshape(temp(:,j), windowSize, length(temp(:,j))/windowSize)',2);
                temp1 = reshape(temp1, 24/windowSize, length(temp1)/(24/windowSize))';
                tempAll = [tempAll, temp1];
            end
            tempAll(isnan(tempAll)) =0;
            allBinaryData.(accountNames{i}) = tempAll;
            a(i) = size(tempAll,1);
        end
        
        % ::: EIGENBEHAVIOR EXTRACTION
        eigenbehaviorOut = eigenbehaviorEvaluator(allBinaryData);
        
        % ::: tNSE + Kmeans clustering
        
        % --- Computing tSNE on 1st eigenbehavior
        [mapped_data, mapping] = compute_mapping(eigenbehaviorOut.eig1', 'tSNE',2, size(eigenbehaviorOut.eig1,1),perplexity); %, # of dimensions, parameters)
        
        % --- Clustering tSNE output with Kmeans
        % Evaluating number of clusters
        optK_S_tSNE = evalclusters(mapped_data,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:30]);
        allPerformances = [allPerformances; optK_S_tSNE.CriterionValues];
    end
    allPerf{numAggregations} = allPerformances;
end


%% Plotting all performances for algorithm parameter selection
for i=1:3
    [selPerplexity(i), selCluster(i)] = find(allPerf{i}==max(max(allPerf{i})));
end
selPerplexity = selPerplexity.*5;
selCluster = selCluster+1;

customizedFigureOpen;
for i=1:3
    subplot(3,1,i);
    [X, Y] = ndgrid(1:size(allPerf{i},1), 1:size(allPerf{i},2));
    scatter3(X(:),Y(:)+1,allPerf{i}(:), 100, X(:).*5,'filled');
    ylabel('K');
    zlabel('Average silhouette coefficient');
    caxis([0 30]);
    colormap((copper));h=colorbar;
    ylabel(h, 'perplexity');
    view(90,0)
end

%% ::: Running the algorithm with the best settings
idxAll = [];
a = [];
for numAggregations = 1:3 % Loop on time aggregation
    rng(1)
    allPerformances = [];
    
    perplexity =selPerplexity(numAggregations);
    chosenC = selCluster(numAggregations);
    
    % Creating binary matrices for eigenbehavior extraction
    windowSize = numHourAgg(numAggregations); % Number of hours for time aggregation
    for i =1:numAccounts
        temp = allAccountsData.(accountNames{i}).allData(:,6:end);
        for j=1:size(temp,2)
            tempEU = temp(:,j);
            if max(tempEU)>=1000
                tempEU(tempEU==max(tempEU))=0;
            end
            tempEU(tempEU>prctile(tempEU(tempEU>0),95))=0;
            temp(:,j) = tempEU;
        end
        % Reshaping data
        tempAll = [];
        for j = 1:size(temp,2)
            temp1 = sum(reshape(temp(:,j), windowSize, length(temp(:,j))/windowSize)',2);
            temp1 = reshape(temp1, 24/windowSize, length(temp1)/(24/windowSize))';
            tempAll = [tempAll, temp1];
        end
        tempAll(isnan(tempAll)) =0;
        allBinaryData.(accountNames{i}) = tempAll;
        a(i) = size(tempAll,1);
    end
    
    % ::: EIGENBEHAVIOR EXTRACTION
    eigenbehaviorOut = eigenbehaviorEvaluator(allBinaryData);
    
    % ::: tNSE + Kmeans clustering
    % --- Computing tSNE on 1st eigenbehavior
    [mapped_data, mapping] = compute_mapping(eigenbehaviorOut.eig1', 'tSNE',2, size(eigenbehaviorOut.eig1,1),perplexity); %, # of dimensions, parameters)
    
    % --- Clustering tSNE output with Kmeans
    % Evaluating number of clusters
    [idx, centroids] = kmeans(mapped_data,chosenC, 'MaxIter', 300000, 'Replicates', 100);

    
    % --- Sorting eigenbehavior based on tSNE clustering output
    originPoint = min(mapped_data);
    sortedDorder = eigenbehaviorPlotterAfterTSNE_resolutions(eigenbehaviorOut.eig1, eigenbehaviorOut.eig1, originPoint, centroids, idx,0,originPoint, windowSize);
    
    if numAggregations ==1
        sortedDorder = [13 11 22 9 20 1 24 6 10 8 2 21 17 3 19 16 15 14 12 18 4 7 25 5 23];
        [~, allEig]= eigenbehaviorPlotterAfterTSNE_WRRpaper_H(eigenbehaviorOut.eig1, eigenbehaviorOut.eig1, originPoint, centroids, idx,1,sortedDorder);
        
        customizedFigureOpen;
        subplot(3,1,1);
        temp = mean(allEig(:,1:121),2);
        stairs(reshape(temp, 24, length(temp)/24), 'LineWidth',  2.5);
        legend('Tap', 'Shower', 'Washing machine', 'Dishwasher', 'Toilet', 'Bathtub', 'Irrigation', 'Evaporative cooler');
        title('Shower-explained', 'FontWeight','Normal')
        
        subplot(3,1,2);
        temp = mean(allEig(:,122:206),2);
        stairs(reshape(temp, 24, length(temp)/24), 'LineWidth',  2.5);
        legend('Tap', 'Shower', 'Washing machine', 'Dishwasher', 'Toilet', 'Bathtub', 'Irrigation', 'Evaporative cooler');
        title('Clothes washing-explained', 'FontWeight','Normal')
        ylabel('Average principal component loading')
        
        subplot(3,1,3);
        temp = mean(allEig(:,207:290),2);
        stairs(reshape(temp, 24, length(temp)/24), 'LineWidth',  2.5);
        legend('Tap', 'Shower', 'Washing machine', 'Dishwasher', 'Toilet', 'Bathtub', 'Irrigation', 'Evaporative cooler');
        title('Irrigation-explained', 'FontWeight','Normal')
        xlabel('Hour of day');
    elseif numAggregations ==3
        sortedDorder = [1 3 2 6 5 4];
        [~, allEig]= eigenbehaviorPlotterAfterTSNE_WRRpaper_6H(eigenbehaviorOut.eig1, eigenbehaviorOut.eig1, originPoint, centroids, idx,1,sortedDorder);
    end

    idxAll = [idxAll idx];
end