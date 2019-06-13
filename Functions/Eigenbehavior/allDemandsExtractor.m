function [allDemandsW, allDemandsE] = allDemandsExtractor(allAccountsWE, nUsersRaw)

% Creating matrices with all users demands
allDemandsW = [];
allDemandsE = [];
for i=1:nUsersRaw
    userID = sprintf('user_%d',i);  % Current account name
    if ismember(userID,fieldnames(allAccountsWE))
        allDemandsW = [allDemandsW; allAccountsWE.(userID).hourlyDemandW];
        allDemandsE = [allDemandsE; allAccountsWE.(userID).hourlyDemandE];
    end
end
end
