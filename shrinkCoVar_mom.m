function [answer,shrinkage] = shrinkCoVar_mom(returns)
%First step - this function is called after cleaning that data
%So can can calulate the S - sample covariance matrix
S = cov(returns);
%Now want to create a structured estimator based on avg corr model
C = corr(returns);
%Want to sum and average either side of the corr matrix to get the avg corr coefficent
len = length(C);
totSum = sum(sum(triu(C)))-(len);
avgCorr = totSum / (((len*len) - len)/2);
%The structured estimator has a diagonal of variances and the avg coefficent in coVars
%Create F, using equations provided in the report
F = nan(size(S));
    for i= 1:size(S,1)
        for j = 1:size(S,2)
            if i==j
                F(i,j) = S(i,j);
            else
                F(i,j) = avgCorr * sqrt(S(i,i)*S(j,j));
            end
        end
    end

%Now conduct Ledoit and Wolf Shrinkage Intensity    
[T,N] = size(S);    
d = 1/N*norm(S-F,'fro')^2; 
y = returns.^2; 
r2 = 1/N/T^2*sum(sum(y'*y))-1/N/T*sum(sum(S.^2)); 
shrinkage = max(0,min(1,r2/d));
%shrikage is also an output for plotting reasons
answer = shrinkage*F+(1-shrinkage)*S;

end
