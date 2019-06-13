function sortedProfiles = representPersonalities(eig1, chosenC, sortedD, idx, totalDemandPerUserW, totalDemandPerUserE, peakDemandPerUserW, peakDemandPerUserE, sortingOption, hourlyDemandW, hourlyDemandE)

switch sortingOption
    case 'tSNE'
        
        % Water
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            temp2 = eig1(:,idx == sortedD(i));
            perCapitaClusterDemandW = sum(totalDemandPerUserW(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
            NU = sum(idx == sortedD(waterConservationPositions(i)));
            subplot(5,4,i);
            temp = median(temp2, 2);
            plot(temp(1:24),'Color', [102 178 255]./255, 'LineWidth',0.5); hold on;
            plot(temp(25:48),'Color', [102 204 0]./255, 'LineWidth',1.5); hold on;
            plot(temp(49:72),'Color', [255 0 0]./255, 'LineWidth',2.0); hold on;
            xlim([1,24]);
            ylim([0 0.2]);
            titleName=['PC-WD:' num2str(perCapitaClusterDemandW, '%.1f'), '#U:' num2str(NU, '%.1f')];
            title(titleName)
            %xlabel('Hour of day');
            %ylabel('Principal component coefficient weight');
        end
        hL=legend('Zero demand', 'Low-medium demand', 'High demand');
        newPosition = [0.6 0.15 0 0];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);
        
        % Energy
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            temp2 = eig1(:,idx == sortedD(i));
            perCapitaClusterDemandE = sum(totalDemandPerUserE(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
            NU = sum(idx == sortedD(waterConservationPositions(i)));
            subplot(5,4,i);
            temp = median(temp2,2);
            plot(temp(73:96),'Color', [102 178 255]./255, 'LineWidth',0.5); hold on;
            plot(temp(97:120),'Color', [102 204 0]./255, 'LineWidth',1.5); hold on;
            plot(temp(121:144),'Color', [255 0 0]./255, 'LineWidth',2.0); hold on;
            xlim([1,24]);
            ylim([0 0.2]);
            titleName=['PC-ED:' num2str(perCapitaClusterDemandE, '%.1f'), '#U:' num2str(NU, '%.1f')];
            title(titleName)
        end
        hL=legend('Low demand', 'Medium demand', 'High demand');
        newPosition = [0.6 0.15 0 0];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);
        
        sortedProfiles = sortedD;
        
    case 'WaterConservation'
        for i = 1:chosenC
            perCapitaClusterDemandW(i) = sum(totalDemandPerUserW(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
            perCapitaClusterDemandE(i) = sum(totalDemandPerUserE(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
        end
        
        refEig = [ones(24,1).*0.2; zeros(48,1)];
        [~, waterConservationPositions] = sort(perCapitaClusterDemandW, 'descend');
        sortedProfiles = sortedD(waterConservationPositions);
        
        %% New Addition :::::
        %clear distFromRef
        %for i = 1:chosenC
        %    temp2 = eig1(:,idx == sortedD(i));
        %    temp = median(temp2,2);
        %    distFromRef(i)= sum(abs(refEig(1:24) - temp(1:24))) + sum(abs(refEig(25:48) - temp(25:48)).*2) + sum(abs(refEig(49:72) - temp(49:72)).*4);
        %end
        %[~, waterConservationPositions] = sort(distFromRef, 'descend');
        %sortedProfiles = sortedD(waterConservationPositions);
        
        % ::::::::::::::::::::
        
        % Water
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            temp2 = eig1(:,idx == sortedD(waterConservationPositions(i)));
            perCapitaClusterDemandW(i) = sum(totalDemandPerUserW(idx == sortedD(waterConservationPositions(i))))/sum(idx == sortedD(waterConservationPositions(i)))/164;
            NU = sum(idx == sortedD(waterConservationPositions(i)));
            subplot(5,4,i);
            clear distFromRef
            for j = i:size(temp2, 2)
                distFromRef(j)= sum(abs(refEig(1:24) - temp2(1:24,j))) + sum((refEig(25:48) - temp2(25:48,j)).^2) + sum((refEig(49:72) - temp2(49:72,j)).^3);
            end
            temp = median(temp2,2);
            tempForNorm = temp(1:72);
            tempForNorm = reshape(tempForNorm, 24, length(tempForNorm)/24);
            tempForNorm = sum(tempForNorm,2);
            plot(temp(1:24),'Color', [0 128 255]./255, 'LineWidth',0.5); hold on;
            plot(temp(25:48),'Color', [102 204 0]./255, 'LineWidth',1); hold on;
            plot(temp(49:72),'Color', [255 0 0]./255, 'LineWidth',2.0); hold on;
            xlim([1,24]);
            ylim([0 0.2]);
            grid on
            %titleName=['PC-WD:' num2str(perCapitaClusterDemandW(i), '%.1f'), '#U:' num2str(NU, '%.0f')];%, 'D:' num2str(mean(distFromRef), '%.1f')];
            %title(titleName)
            %xlabel('Hour of day');
            %ylabel('Principal component coefficient weight');
        end
        %hL=lgend('Zero demand', 'Low-medium demand', 'High demand');
        %newPosition = [0.6 0.15 0 0];
        %newUnits = 'normalized';
        %set(hL,'Position', newPosition,'Units', newUnits);
        
        % Energy
        %figure;
        %set (gcf, 'DefaultTextFontName', 'Verdana', ...
        %    'DefaultTextFontSize', 10, ...
        %    'DefaultAxesFontName', 'Verdana', ...
        %    'DefaultAxesFontSize', 10, ...
        %    'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            temp2 = eig1(:,idx == sortedD(waterConservationPositions(i)));
            perCapitaClusterDemandE(i) = sum(totalDemandPerUserE(idx == sortedD(waterConservationPositions(i))))/sum(idx == sortedD(waterConservationPositions(i)))/164;
            NU = sum(idx == sortedD(waterConservationPositions(i)));
            subplot(5,4,i);
            clear distFromRef
            for j = i:size(temp2, 2)
                distFromRef(j)= sum(abs(refEig(1:24) - temp2(73:96,j))) + sum((refEig(25:48) - temp2(97:120,j)).^2) + sum((refEig(49:72) - temp2(121:144,j)).^3);
            end
            temp = median(temp2, 2);
            
            % Normalization
            tempForNorm = temp(73:144);
            tempForNorm = reshape(tempForNorm, 24, length(tempForNorm)/24);
            tempForNorm = sum(tempForNorm,2);
            
            plot(temp(73:96),'-.','Color', [0 128 255]./255, 'LineWidth',0.5); hold on;
            plot(temp(97:120),'-.','Color', [102 204 0]./255, 'LineWidth',1); hold on;
            plot(temp(121:144),'-.','Color', [255 0 0]./255, 'LineWidth',2.0); hold on;
            xlim([1,24]);
            set(gca,'YTick',0:0.1:0.2);
            titleName=['P', num2str(waterConservationPositions(i), '%d'), ', Num accounts:' num2str(NU, '%.0f')];%['PC-ED:' num2str(perCapitaClusterDemandE(i), '%.1f'), '#U:' num2str(NU, '%.0f')];%, 'D:' num2str(mean(distFromRef), '%.1f')];
            title(titleName)
            grid on
        end
        hL=legend('Zero demand W', 'Low-medium demand W', 'Medium-high demand W', ...
            'Low demand E', 'Medium demand E', 'High demand E');
        newPosition = [0.6 0.15 0 0];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);
        
        % Cluster per capita water and energy demands
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 12, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 12, ...
            'DefaultLineMarkerSize', 10);
        
        perCapitaClusterDemandWTemp =(perCapitaClusterDemandW.*28.317)./1000;
        scatter(perCapitaClusterDemandWTemp, perCapitaClusterDemandE,30,'filled');
        xlabel('Water demand [m^3/day]');
        ylabel('Electricity demand [kWh/day]');
        a = waterConservationPositions'; b = num2str(a); c = cellstr(b);
        dx = 0.01; dy = 0.1; % displacement so the text does not overlay the data points
        text(perCapitaClusterDemandWTemp+dx, perCapitaClusterDemandE+dy, c);
        %subplot(211); bar(perCapitaClusterDemandW);xlim([1 chosenC]);
        %ylabel('Water demand [cf/day]');
        %title('Average per capita water demand for each cluster');
        
        %subplot(212); bar(perCapitaClusterDemandE);xlim([1 chosenC]);
        %ylabel('Electricity demand [kWh/day]');
        %title('Average per capita electricity demand for each cluster');
        
        
        
        % Water
        customizedFigureOpen;
        colours = parula(chosenC+3);
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            %subplot(5,4,i);
            tempToPlot=hourlyDemandW(:,idx == sortedD(waterConservationPositions(i)));
            tempToPlot=tempToPlot(:);
            h(i) = cdfplot(tempToPlot);hold on;
            set(h(i),'Color',colours(i,:));
            set(h(i),'LineWidth',2);
            xlim([0, 20]);
            ylim([0.5, 1]);
            grid off
        end
        colormap(parula(chosenC))
        cbh = colorbar('XTick', 0:1/chosenC:1/chosenC*(chosenC-1))
        set(cbh,'XTickLabel',{'1','2', '3', '4', '5', '6', '7', '8', '9', '10','11', '12', '13', '14', '15', '16', '17', '18'})
        
        
        
        % Electricity
        figure;
        colours = parula(chosenC);
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            %subplot(5,4,i);
            tempToPlot=hourlyDemandE(:,idx == sortedD(waterConservationPositions(i)));
            tempToPlot=tempToPlot(:);
            h(i) = cdfplot(tempToPlot);hold on;
            set(h(i),'Color',colours(i,:));
            set(h(i),'LineWidth',2);
            xlim([0, 10]);
            ylim([0, 1]);
            grid off
        end
        colormap(parula(chosenC))
        cbh = colorbar('XTick', 0:1/chosenC:1/chosenC*(chosenC-1))
        set(cbh,'XTickLabel',{'1','2', '3', '4', '5', '6', '7', '8', '9', '10','11', '12', '13', '14', '15', '16', '17', '18'})
        
        
        
        
    case 'WaterPeakShifting'
        clear perCapitaClusterDemandW perCapitaClusterDemandE
        for i = 1:chosenC
            perCapitaClusterDemandW(i) = sum(peakDemandPerUserW(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
            perCapitaClusterDemandE(i) = sum(peakDemandPerUserE(idx == sortedD(i)))/sum(idx == sortedD(i))/164;
        end
        
        [~, waterConservationPositions] = sort(perCapitaClusterDemandW, 'descend');
        sortedProfiles = sortedD(waterConservationPositions);
        refEig = [ones(24,1).*0.2; zeros(48,1)];
        
        %% New Addition :::::
        %clear distFromRef
        %for i = 1:chosenC
        %    temp2 = eig1(:,idx == sortedD(i));
        %    temp = median(temp2,2);
        %    distFromRef(i)= sum(abs(refEig(6:10) - temp(6:10))) + sum(abs(refEig(30:34) - temp(30:34)).*2) + sum(abs(refEig(54:58) - temp(54:58)).*4);
        %end
        %[~, waterConservationPositions] = sort(distFromRef, 'descend');
        %sortedProfiles = sortedD(waterConservationPositions);
        
        % ::::::::::::::::::::
        
        % Water
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            temp2 = eig1(:,idx == sortedD(waterConservationPositions(i)));
            perCapitaClusterDemandW(i) = sum(peakDemandPerUserW(idx == sortedD(waterConservationPositions(i))))/sum(idx == sortedD(waterConservationPositions(i)))/164;
            NU = sum(idx == sortedD(waterConservationPositions(i)));
            subplot(5,4,i);
            temp = median(temp2,2);
            plot(temp(1:24),'Color', [102 178 255]./255, 'LineWidth',0.5); hold on;
            plot(temp(25:48),'Color', [102 204 0]./255, 'LineWidth',1.5); hold on;
            plot(temp(49:72),'Color', [255 0 0]./255, 'LineWidth',2.0); hold on;
            xlim([1,24]);
            ylim([0 0.2]);
            grid on
            titleName=['PC-WD:' num2str(perCapitaClusterDemandW(i), '%.1f'), '#U:' num2str(NU, '%.0f')];
            title(titleName)
            %xlabel('Hour of day');
            %ylabel('Principal component coefficient weight');
        end
        hL=legend('Zero demand', 'Low-medium demand', 'High demand');
        newPosition = [0.6 0.15 0 0];
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);
        
        % Cluster per capita water and energy peak demands
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 12, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 12, ...
            'DefaultLineMarkerSize', 10);
        
        subplot(211); bar(perCapitaClusterDemandW);xlim([1 chosenC]);
        ylabel('Water demand [cf/day]');
        title('Average per capita peak water demand for each cluster');
        
        for i = 1:chosenC
            perCapitaClusterDemandW(i) = sum(totalDemandPerUserW(idx == sortedD(waterConservationPositions(i))))/sum(idx == sortedD(waterConservationPositions(i)))/164;
        end
        
        subplot(212); bar(perCapitaClusterDemandW);xlim([1 chosenC]);
        ylabel('Water demand [cf/day]');
        title('Average per capita total water demand for each cluster');
        
        
        % Water
        colours = parula(chosenC);
        figure;
        set (gcf, 'DefaultTextFontName', 'Verdana', ...
            'DefaultTextFontSize', 10, ...
            'DefaultAxesFontName', 'Verdana', ...
            'DefaultAxesFontSize', 10, ...
            'DefaultLineMarkerSize', 10);
        for i = 1:chosenC
            %subplot(5,4,i);
            h(i) = cdfplot(peakDemandPerUserW(idx == sortedD(waterConservationPositions(i))));hold on;
            xlim([0,8000]);
            %ylim([0.5, 1]);
            set(h(i),'Color',colours(i,:));
            set(h(i),'LineWidth',2);
            grid off
        end
        colormap(parula(chosenC))
        cbh = colorbar('XTick', 0:1/chosenC:1/chosenC*(chosenC-1))
        set(cbh,'XTickLabel',{'1','2', '3', '4', '5', '6', '7', '8', '9', '10','11', '12', '13', '14', '15', '16', '17', '18'})
        
end
end