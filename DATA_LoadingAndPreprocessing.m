clear
clc

home = pwd;
addpath(genpath(pwd));
set(0,'DefaultFigureWindowStyle','docked')
rng(1);

%% ::: RAW DATA LOADING :::
rawDataFile = ('raw_data.xlsx');
[~,sheetID] = xlsfinfo(rawDataFile);
numAccounts = length(sheetID); % From row data

[allAccountsData, dataStat] = loadRawEndUseData(rawDataFile, sheetID);

save allAccountsData.mat allAccountsData
save dataStat.mat dataStat

%% ::: DATA PRE-PROCESSING :::
load allAccountsData.mat
load dataStat.mat

% --- Plotting raw data stats
customizedFigureOpen;
subplot(1,3,1); ecdf(dataStat.numDays);
subplot(1,3,2); ecdf(datenum(num2str(dataStat.endDate(:,:)),'dd mm yyyy'));
subplot(1,3,3); ecdf(datenum(num2str(dataStat.startDate(:,:)),'dd mm yyyy'));

startEndStats(1,:) = datevec(min(datenum(num2str(dataStat.startDate(:,:)),'dd mm yyyy')));
startEndStats(2,:) = datevec(max(datenum(num2str(dataStat.startDate(:,:)),'dd mm yyyy')));
startEndStats(3,:) = datevec(min(datenum(num2str(dataStat.endDate(:,:)),'dd mm yyyy')));
startEndStats(4,:) = datevec(max(datenum(num2str(dataStat.endDate(:,:)),'dd mm yyyy')));

% --- Removing users with poor data

% Checking NaNs
numAccounts = length(fieldnames(allAccountsData)); % Number of accounts
accountNames = fieldnames(allAccountsData);
for i =1:numAccounts
    currAccount = allAccountsData.(accountNames{i}).allData(:,6:end);
    numNans(i) = sum(sum(isnan(currAccount)));
end

% Removing accounts with less than 192 observed days (8 end uses x 24
% hour/day)
positionsToRemove = find(dataStat.numDays < 192);

dataStat.numDays(positionsToRemove) = [];
dataStat.startDate(positionsToRemove,:) = [];
dataStat.endDate(positionsToRemove,:) = [];
allAccountsData = rmfield(allAccountsData, accountNames(positionsToRemove));

cd(home);
cd('./DATA/');
save('allAccountsData_PROCESSED.mat', 'allAccountsData');
save('dataStat_PROCESSED.mat', 'dataStat');