function [allAccountsData, dataStat] = loadRawEndUseData(rawDataFile, sheetID)

% function [allAccountsData] = loadCWEEwaterData(dirContent)
% Loading raw data from folder rawDataFile. sheetID contains the names of
% the sheets in the input file, one for each user. nUsers is the total
% number of users.

numAccounts = length(sheetID); % Number of accounts
userCount = 1;

for i=2:numAccounts
    tic
    disp(i-1)
    currAccount = xlsread(rawDataFile, sheetID{i}); % Loading data from the current account
    
    if isempty(currAccount) == 0
        currAccount(:,end) = [];
        % Removing partial days
        initHour = find(currAccount(:,4) == 0);
        if initHour(1) > 1
            currAccount(1:initHour(1) - 1, :) = [];
        end
        
        finHour = find(currAccount(:,4) == 23);
        if finHour(end) < size(currAccount,1)
            currAccount(finHour(end) + 1:end, :) = [];
        end
        
        % Storing data for each account
        accountID = sprintf('acc_%d',userCount);
        
        allAccountsData.(accountID).stat.startDate = currAccount(1,1:3);
        allAccountsData.(accountID).stat.endDate = currAccount(end,1:3);
        allAccountsData.(accountID).allData = currAccount;
        
        dataStat.startDate(userCount,:) = currAccount(1,1:3);
        dataStat.endDate(userCount,:) = currAccount(end,1:3);
        dataStat.numDays(userCount) = datenum(num2str(dataStat.endDate(userCount,:)),'dd mm yyyy') - datenum(num2str(dataStat.startDate(userCount,:)),'dd mm yyyy') + 1;
        
        userCount = userCount +1;
        clear currAccount
    end
    toc
end

end