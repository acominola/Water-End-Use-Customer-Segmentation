function [sortedD, toPlotEig] = eigenbehaviorPlotterAfterTSNE_WRRpaper(eig1, eig2, originPoint, centroids, idx, optSorted, sortedInput)

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
toPlotEig(toPlotEig<0)=0;
figure;
set (gcf, 'DefaultTextFontName', 'Verdana', ...
    'DefaultTextFontSize', 13, ...
    'DefaultAxesFontName', 'Verdana', ...
    'DefaultAxesFontSize', 13, ...
    'DefaultLineMarkerSize', 10);imagesc(toPlotEig);
rectangle('Position', [0,0,121,195], 'EdgeColor',[135 206 250 40]./255, 'FaceColor', [135 206 250 40]./255)
hold on;
rectangle('Position', [120.5,0,86,195], 'EdgeColor',[255 165 0 40]./255, 'FaceColor', [255 165 0 40]./255)
rectangle('Position', [205.5,0,85,195], 'EdgeColor',[50 205 50 40]./255, 'FaceColor', [50 205 50 40]./255)

n= 50;
cmap1 = [linspace(1, 1, n); linspace(0, 1, n); linspace(0, 1, n)]';
cmap2 = [linspace(1, 0, n); linspace(1, 0, n); linspace(1, 1, n)]';
cmap = [cmap1; cmap2(2:end, :)];
colormap(vivid(cmap, [0.5 0.5]));
caxis([0 1]);
colormap(flipud(bone));colorbar;%colormap(flipud(hot));colorbar;
hold on;
for i = 1:7
    plot([0 size(eig1,2)+10],[24*i+0.3 24*i+0.3],'Color', [160 160 160]./256,'LineWidth',1.5);
end

for i = 1:size(centroids,1)-1
    plot([endCluster(i) endCluster(i)],[0 194],'-.','Color', [160 160 160]./256, 'LineWidth',2.3);
end
endCluster = [1, endCluster];

xlabel('Account ID');
ylabel('Hour of day');
c=colorbar;
ylabel(c,'Principal component loading');
set(gca,'YTickLabel',{'1','24','1','24','1','24','1','24','1','24','1','24', '1','24', '1','24'}, ...
    'YTick', [1,23,26,47, 50, 71, 74, 95, 98, 119, 122, 143, 146, 167, 170, 191, 194], 'Ticklength', [0 0]);
set(gca, 'XTickLabel',num2cell(endCluster), 'XTick', endCluster, 'XTickLabelRotation', 60);

end