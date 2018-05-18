function getIndex = validIndex_Grp7(momRow,liveRow,returnRow,mvRow)
%The inputs is a row vector of the same trading day(1*N)- bar returns
%Want a list of indexes this day to ensure we take data with no NaNs
%Output will just be a row of ValidIndexes only, Therefore samller than N
indexI=[];
for i=1:1605
    if liveRow(i)==1 & isnan(momRow(i))==0 & isnan(returnRow(i))==0 & isnan(mvRow(i))==0
             indexI = [indexI,i];
    end
end
getIndex = indexI;
end