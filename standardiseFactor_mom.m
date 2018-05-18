function factorStd = standardiseFactor_mom(factorRaw,liveMatrix)
%Inputs - factorRow is the mom (T*N) and liveMatrix is the live (T*N)
row = size(factorRaw,1);
%We find which indexs in the live matrix that are live on that day
%We then use these indexs, and use them to index into mom factor (FactorRaw)
%This means we have mom exposures on that day - that are live
%At this point should be no NaNs, but use nan functions just in case
for i=1:row
    getIndex = find(liveMatrix(i,:)==1);
    avg(i) = nanmean(factorRaw(i,getIndex));
    stdev(i) = nanstd(factorRaw(i,getIndex));
end

factorStd = (factorRaw - (avg')) ./ (stdev');