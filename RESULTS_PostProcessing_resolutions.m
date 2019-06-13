%% --- Fig - median vs mean
numAccounts = length(fieldnames(allAccountsData));
accountNames = fieldnames(allAccountsData);

% Analysis on end-uses (post-processing)
meanEndUse = [];
maxEndUse = [];
freqEndUse = [];

for i =1:numAccounts
    temp = allAccountsData.(accountNames{i}).allData(:,6:end);
    meanEndUse = [meanEndUse mean(temp)'];
    maxEndUse = [maxEndUse max(temp)'];
    freqEndUse = [freqEndUse (sum(temp)./sum(temp>0))'];
end
freqEndUse(isnan(freqEndUse)) = 0;

totMeanEndUse = [];
totMaxEndUse = [];
totFreqEndUse = [];

for i=1:length(sortedDorder)
    currPos = find(idx == sortedDorder(i));
    
    totMeanEndUse(:,i) = median(meanEndUse(:,currPos),2);
    totMaxEndUse(:,i) =  median(maxEndUse(:,currPos),2);
    totFreqEndUse(:,i) =  median(freqEndUse(:,currPos),2);
    
    
end

temp = [2,3,7];
customizedFigureOpen;
for i=1:3
    a = [totMeanEndUse(temp(i),:); totFreqEndUse(temp(i),:)]';
    %subplot(1,3,i);
    sizeTemp = ones(length(a), 1).*30;
    h = scatter(a(:,1), a(:,2),sizeTemp, 'filled'); hold on;
    xlabel('Median hourly use [L/h]');
    ylabel('Median water use per event [L]');
    
    c = h.CData;
    c = repmat(c,[length(a) 1]);
    
    if i ==1
        %title('Shower');
        positions = [1:1];
        c(:,:) = repmat([128 128 128]./256, length(c),1);
        c(:,:) = repmat([135, 206, 250].*1/256, length(c),1);
        sizeTemp(positions) = 600;
    elseif i==2
        % title('Clothes Washer');
        positions = [2];
        c(:,:) = repmat([128 128 128]./256, length(c),1);
        c(:,:) = repmat([255, 165, 0].*1/256, length(c),1);
        sizeTemp(positions) = 600;
    elseif i ==3
        %title('Irrigation');
        positions = [3:4];
        c(:,:) = repmat([128 128 128]./256, length(c),1);
        c(:,:) = repmat([50, 205, 50].*1/256, length(c),1);
        sizeTemp(positions) = 600;
    end
    h = scatter(a(:,1), a(:,2),sizeTemp, 'filled'); hold on;
    % c now contains red, followed by 4 copies of the original color
    h.CData = c;
    for k=1:length(a)
        if sizeTemp(k) == 600
            text(a(k,1),a(k,2),sprintf('P%d',k),'FontSize',14, 'HorizontalAlignment','center')
        end
    end
    
end

%% --- Fig. 5: end use share for each cluster
totEndUse = [];
for i =1:numAccounts
    temp = allAccountsData.(accountNames{i}).allData(:,6:end);
    totEndUse = [totEndUse mean(temp)'];
end

idxForPlot =[];
endUsePercToPlot = [];

for i=1:length(sortedDorder)
    currPos = find(idx == sortedDorder(i));
    totEndUseIdx = totEndUse(:,currPos);
    endUsePerc = sum(totEndUseIdx,2);
    endUsePerc = endUsePerc./sum(endUsePerc);
    
    % Plotting figure
    endUsePercToPlot = [endUsePercToPlot, endUsePerc];
end

toPlot = [endUsePercToPlot(2,:);endUsePercToPlot(3,:);endUsePercToPlot(7,:);endUsePercToPlot(1,:);endUsePercToPlot(4:6,:);endUsePercToPlot(8,:)];
customizedFigureOpen;
bar(toPlot', 'stacked');
ylim([0,1]);
xlim([0.5, 6.5]);
set(gca, 'XTick', 1:6, 'XTickLabel', {'P1','P2','P3', 'P4','P5', ...
    'P6'});
xlabel('Account cluster ID');
ylabel('Average end-use ratio');
legend('Shower', 'Clothes Washer', 'Irrigation', 'Tap', 'Dishwasher', ...
    'Toilet', 'Bathtub', 'Evaporative cooler');


%% Seasonality analysis
load dataStat_PROCESSED.mat

commonStartDate = max(datenum(num2str(dataStat.startDate),'dd mm yyyy'));
commonEndDate = min(datenum(num2str(dataStat.endDate),'dd mm yyyy'));

accountDateIDX = [];
for i=1:numAccounts
    disp(i);
    currAccount = allAccountsData.(accountNames{i}).allData(:,1:3);
    tempStart = find(datenum(num2str(currAccount),'dd mm yyyy') == commonStartDate);
    tempEnd = find(datenum(num2str(currAccount),'dd mm yyyy') == commonEndDate);
    accountDateIDX(i,:) = [tempStart(1) tempEnd(end)];
end

%% Seasonality
selComp = [];
for i=1:numAccounts 
    counter = 0;
    for j=(accountDateIDX(i,1)-1)/24+1:accountDateIDX(i,2)/24
        counter = counter + 1;
        [~, selComp(counter,i)] = min(eigenbehaviorOut.pcaOut(i).score(j,:));
    end
end

positionsS = 1;
positionsCW = [2];
positionsI = [3:4];

allProfiles_std_S = [];
allProfiles_std_CW = [];
allProfiles_std_I = [];

wdIDX = weekday([commonStartDate:commonEndDate]);

allProfiles_S = [];
allProfiles_CW = [];
allProfiles_I = [];

for i=1:numAccounts
    i
    if sum(sortedDorder(positionsS)==idx(i))>0
        
        for dayID = 1:size(selComp,1)
            allProfiles_S = [allProfiles_S eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
    elseif sum(sortedDorder(positionsCW)==idx(i))>0
        for dayID = 1:size(selComp,1)
            allProfiles_CW = [allProfiles_CW eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
    elseif sum(sortedDorder(positionsI)==idx(i))>0
        for dayID = 1:size(selComp,1)
            allProfiles_I = [allProfiles_I eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
    end
end

%% ::: Correlation analysis for periodicity
allCorr_S=[];
allCorr_CW=[];
allCorr_I=[];

counterS=0;
counterCW=0;
counterI=0;

positionsS = 1;
positionsCW = [2];
positionsI = [3:4];

for i=1:numAccounts
    i
    if sum(sortedDorder(positionsS)==idx(i))>0
        allProfiles_S=[];
        counterS = counterS+1;
        for dayID = 1:size(selComp,1)
            allProfiles_S = [allProfiles_S eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
        for nC = 1:size(allProfiles_S,1)
            allCorr_S(nC,:,counterS) = autocorr(allProfiles_S(nC,:),90);
        end
    elseif sum(sortedDorder(positionsCW)==idx(i))>0
        allProfiles_CW=[];
        counterCW = counterCW+1;
        for dayID = 1:size(selComp,1)
            allProfiles_CW = [allProfiles_CW eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
        for nC = 1:size(allProfiles_CW,1)
            allCorr_CW(nC,:,counterCW) = autocorr(allProfiles_CW(nC,:),90);
        end
    elseif sum(sortedDorder(positionsI)==idx(i))>0
        allProfiles_I=[];
        counterI = counterI+1;
        for dayID = 1:size(selComp,1)
            allProfiles_I = [allProfiles_I eigenbehaviorOut.pcaOut(i).coeff(:,selComp(dayID,i))];
        end
        for nC = 1:size(allProfiles_I,1)
            allCorr_I(nC,:,counterI) = autocorr(allProfiles_I(nC,:),90);
        end
    end
end

%% Shower correlations
temp = squeeze(allCorr_S(6,2:end,:));
temp = temp';
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;

[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
customizedFigureOpen;
subplot(321);
h=boxplot(temp(idxT==1,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
currFig = gca; set(currFig, 'XTickLabel',[]);
ylabel('Autocorrelation');xlabel('Time [d]')
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==1,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);
set(findobj(gca,'tag','Median'), 'Color', [30,144,255]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [30,144,255]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end
subplot(322);
h=boxplot(temp(idxT==2,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
currFig = gca; set(currFig, 'XTickLabel',[]);
ylabel('Autocorrelation');xlabel('Time [d]')
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==2,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);

set(findobj(gca,'tag','Median'), 'Color', [30,144,255]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [30,144,255]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

% CW correlations
temp = squeeze(allCorr_CW(10,2:end,:));
temp = temp';
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;

[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
%customizedFigureOpen;
subplot(323);
h=boxplot(temp(idxT==1,:));%,'PlotStyle','compact')
ylabel('Autocorrelation');xlabel('Time [d]')
set(h(5,:),'Visible','off');currFig = gca; set(currFig, 'XTickLabel',[]);
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==1,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);

set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
set(findobj(gca,'tag','Median'), 'Color', [255,165,0]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [255,165,0]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

subplot(324);
h=boxplot(temp(idxT==2,:));%,'PlotStyle','compact')
set(h(5,:),'Visible','off')
currFig = gca; set(currFig, 'XTickLabel',[]);
ylabel('Autocorrelation'); xlabel('Time [d]')
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==2,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);

set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
set(findobj(gca,'tag','Median'), 'Color', [255,165,0]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [255,165,0]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end
% Irrigation correlations
temp = squeeze(allCorr_I(26,2:end,:));
temp = temp';
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;
%
[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
subplot(325);
h=boxplot(temp(idxT==1,:));%,'PlotStyle');%,'compact');set(h(5,:),'Visible','off')
currFig = gca; set(currFig, 'XTickLabel',[]);xlabel('Time [d]')
ylabel('Autocorrelation');
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');
% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==1,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);

set(findobj(gca,'tag','Median'), 'Color', [50,205,50]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [50,205,50]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end


subplot(326);
h=boxplot(temp(idxT==2,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
currFig = gca; set(currFig, 'XTickLabel',[]);
ylabel('Autocorrelation');xlabel('Time [d]')
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(temp(idxT==2,:));%,'PlotStyle','compact');set(h(5,:),'Visible','off')
ylabel('Autocorrelation');xlabel('Time [d]')

currFig = gca; set(currFig, 'XTickLabel',[]);

set(findobj(gca,'tag','Median'), 'Color', [50,205,50]./256, 'linewidth', 1);
set(findobj(gca,'tag','Box'), 'Color', [50,205,50]./256, 'linewidth', 1);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 0.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 0.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 0.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end
%% ::: Evaluating entropy
wdIDX = weekday([commonStartDate:commonEndDate]);

selComp = [];
for i=1:numAccounts
    counter = 0;
    for j=(accountDateIDX(i,1)-1)/24+1:accountDateIDX(i,2)/24
        counter = counter + 1;
        [~, selComp(counter,i)] = min(eigenbehaviorOut.pcaOut(i).score(j,:));
    end
end

% Count the primary behavior for each day
pb = zeros(327,7);

for i=1:size(selComp,2)
    for j=1:7
        pb(i,j) = sum(selComp(wdIDX==j,i)==1);
    end
end
positions =[2:7,1];

positionsS = 1;
positionsCW = [2];
positionsI = [3:4];

pb = pb(:,positions);
pbS = pb(idx==sortedDorder(positionsS),:);
pbCW = pb(idx==sortedDorder(positionsCW),:);
pbI = pb(idx==sortedDorder(positionsI(1)) | idx==sortedDorder(positionsI(2)) ,:);

%%
temp = pbS;
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;
[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
customizedFigureOpen;
A=temp(idxT==1,:);

B=temp(idxT==2,:);
subplot(3,2,1); boxplot(A);
currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);
% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[135,206,250]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(A);
ylim([0,30]);
ylabel('1st eigenbehavior count');
currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});

set(findobj(gca,'tag','Median'), 'Color', [30,144,255]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [30,144,255]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

subplot(3,2,2); boxplot(B); currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);
% Coloring boxes

h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[135,206,250]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(B);
ylim([0,30]);
ylabel('1st eigenbehavior count');
currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});

set(findobj(gca,'tag','Median'), 'Color', [30,144,255]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [30,144,255]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [30,144,255]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [30,144,255]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

temp = pbCW;
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;
[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
A=temp(idxT==1,:);
B=temp(idxT==2,:);
subplot(3,2,3); boxplot(A); currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);
% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[255,215,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(A);
ylim([0,30]);
ylabel('1st eigenbehavior count');

currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
set(findobj(gca,'tag','Median'), 'Color', [255,165,0]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [255,165,0]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

subplot(3,2,4); boxplot(B); currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);
% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[255,215,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(B);
ylim([0,30]);
ylabel('1st eigenbehavior count');

currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
set(findobj(gca,'tag','Median'), 'Color', [255,165,0]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [255,165,0]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [255,165,0]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [255,165,0]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end

temp = pbI;
corrCluster = evalclusters(temp,'kmeans','silhouette','Distance','sqeuclidean','KList',[2:10]);
[~, clNum] = max(corrCluster.CriterionValues);
clNum=clNum+1;
[idxT, centroids] = kmeans(temp,clNum, 'MaxIter', 10000, 'Replicates', 100);
A=temp(idxT==1,:);


B=temp(idxT==2,:);
subplot(3,2,5); boxplot(A); currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==1)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);
% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(A);
ylim([0,30]);
ylabel('1st eigenbehavior count');

currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});

set(findobj(gca,'tag','Median'), 'Color', [50,205,50]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [50,205,50]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end
subplot(3,2,6); boxplot(B);currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
title(sprintf('Household percentage: %.f', sum(idxT==2)./length(idxT)*100), 'FontWeight','Normal');
ylabel('1st eigenbehavior count');ylim([0,30]);

% Coloring boxes
h = findobj(gca,'Tag','Box');
for iH=1:length(h)
    patch(get(h(iH),'XData'),get(h(iH),'YData'),[0,255,0]./256,'FaceAlpha',0.3);
end
hold on;

boxplot(B);
ylim([0,30]);
ylabel('1st eigenbehavior count');

currFig = gca;
set(currFig, 'XTickLabel', {'M','T','W','T','F','S','S'});
set(findobj(gca,'tag','Median'), 'Color', [50,205,50]./256, 'linewidth', 2);
set(findobj(gca,'tag','Box'), 'Color', [50,205,50]./256, 'linewidth', 2);
set(findobj(gca,'tag','Upper Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Whisker'), 'Color', [50,205,50]./256, 'linestyle', '-', 'linewidth', 1.5);
set(findobj(gca,'tag','Upper Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 1.5);
set(findobj(gca,'tag','Lower Adjacent Value'), 'Color', [50,205,50]./256, 'linewidth', 1.5);
h = findobj(gca,'tag','Outliers');
for iH = 1:length(h)
    h(iH).MarkerEdgeColor = [128 128 128]./256;
end