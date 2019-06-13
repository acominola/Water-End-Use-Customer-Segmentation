function success = eigenbehaviorPlotter(eig1, varPerc)

% Representing PCA output
D = squareform(pdist(eig1', 'correlation'));

[~, positionsForPlot] = sort(D(:,1), 'ascend');
temp = eig1(:, positionsForPlot);

% Eigenbehavior imagesc
Eigbeh = figure;
set (gcf, 'DefaultTextFontName', 'Verdana', ...
    'DefaultTextFontSize', 14, ...
    'DefaultAxesFontName', 'Verdana', ...
    'DefaultAxesFontSize', 18, ...
    'DefaultLineMarkerSize', 10);
imagesc(temp(1:24*8,:));colormap(flipud(hot));colorbar;
xlabel('Account ID');
c=colorbar;
ylabel(c,'Principal component weight');
set(gca,'YTickLabel',{'1','24','24','24', '24','24','24','24','24'}, ...
    'YTick', 0:24:size(eig1,1));
hold on;
for i = 1:7
    plot([0 size(eig1,2)],[24*i+0.3 24*i+0.3],'k','LineWidth',2.2);
end

% Explained variance
ExVariance = figure;
set (gcf, 'DefaultTextFontName', 'Verdana', ...
    'DefaultTextFontSize', 14, ...
    'DefaultAxesFontName', 'Verdana', ...
    'DefaultAxesFontSize', 15, ...
    'DefaultLineMarkerSize', 10);
hist(varPerc);
xlabel('Exaplained variance by 1st Eigenbehavior [%]');
ylabel('Users count');%


success = 1;
end
