function sortedD = eigenbehaviorPlotterAfterTSNE(eig1, eig2, originPoint, centroids, idx, optSorted, sortedInput)

ref = zeros(192,1);
for i  = 1:size(centroids,1)
    currPos = find(idx == i);
    temp = mean(eig1(:,currPos),2);
    temp = abs(ref - temp);
    temp = temp'.*(ones(1,length(temp))./(1:1:length(temp)));
    distancePoint(i) = sum(temp);
    clear currPos temp
end

if optSorted==0
[~, sortedD] = sort(distancePoint, 'descend');
else 
    sortedD = sortedInput;
end

toPlotEig = [];
endCluster=[];
for i = 1:size(centroids,1)
    toPlotEig = [toPlotEig, eig1(:,idx == sortedD(i))];
    endCluster(i) = size(toPlotEig,2);
end

figure;
set (gcf, 'DefaultTextFontName', 'Verdana', ...
    'DefaultTextFontSize', 13, ...
    'DefaultAxesFontName', 'Verdana', ...
    'DefaultAxesFontSize', 13, ...
    'DefaultLineMarkerSize', 10);imagesc(toPlotEig);
n= 50;
cmap1 = [linspace(1, 1, n); linspace(0, 1, n); linspace(0, 1, n)]';
cmap2 = [linspace(1, 0, n); linspace(1, 0, n); linspace(1, 1, n)]';
cmap = [cmap1; cmap2(2:end, :)];
colormap(vivid(cmap, [0.5 0.5]));
caxis([-0.7 1]);
%colormap(flipud(spectral));colorbar;%colormap(flipud(hot));colorbar;
hold on;
for i = 1:7
    plot([0 size(eig1,2)+10],[24*i+0.3 24*i+0.3],'k','LineWidth',1.5);
end

for i = 1:size(centroids,1)-1
    plot([endCluster(i) endCluster(i)],[0 194],'-.k','LineWidth',2.3);
end
xlabel('Account ID');
c=colorbar;
ylabel(c,'Principal component loading');
set(gca,'YTickLabel',{'0','23','0','23','0','23','0','23','0','23','0','23', '0','23', '0','23'}, ...
    'YTick', [0,23,26,47, 50, 71, 74, 95, 98, 119, 122, 143, 146, 167, 170, 191, 194], 'Ticklength', [0 0]);
end