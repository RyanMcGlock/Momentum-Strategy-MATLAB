function answer = coVarIndex_mom(returns)
%Returns will be a sub matrix of some window size (500 days for example)
n= size(returns);
validIndex = [];
%We go through each column and see what company has 500 previous returns
%data - simply record index of that column
    for j = 1:n(2)
        if sum(isnan(returns(:,j)))==0
            validIndex = [validIndex,j];
        end
    end
answer = validIndex;
end