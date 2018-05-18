function answer = computeMV_mom(mvRow)
%Want to transform market value of each row into weights (each row sums to one)
%Input is 1 row of Mom - function called inside loop, passing in each day
%Once this function is called, the data has be cleaned already
sumacross = nansum(mvRow);
%Output - Want it to be a diagonal matrix for regression
answer = diag(mvRow/sumacross);
end
