function [optK_CH, optK_S] = evaluateOptimalClusterNumber(vectorToCluster, minCluster, maxCluster)

optK_CH = evalclusters(allDemandsW(allDemandsW>0),'kmeans','CalinskiHarabasz','KList',[minCluster:maxCluster]);
optK_S = evalclusters(allDemandsW(allDemandsW>0),'kmeans','silhouette','KList',[minCluster:maxCluster]);

% Visualizing cluster test output
figure;
subplot(121);bar([minCluster:maxCluster], optK_CH.CriterionValues);xlim([minCluster-1,maxCluster-1]);
xlabel('CalinskiHarabasz Cluster number');
ylabel('Criterion value');
hold on;
subplot(122);bar([minCluster:maxCluster], optK_S.CriterionValues);xlim([minCluster-1,maxCluster-1]);
xlabel('Silhouette Cluster number');
ylabel('Criterion value');

end