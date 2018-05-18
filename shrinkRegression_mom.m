%Third Regression - Note a bit slower
clc;clear all;
%Load Data
load('UK_StandardMomentum.mat') 
load('UK_live.mat')
load('UK_MarketValues.mat')
load('UK_Returns.mat')

%Standardise the Mom exposure
stdmom = standardiseFactor_mom(mom,live);

window=500; [T,N]= size(r); gammaThree=[]; k=1;
%Note we update coVar matrix every day - firstly for accuracy and secondly
%holding it fixed over some period  will cause issues as the next day has different valid stocks

for i = (window+1):6740
%Take the subset of return data (window length)
    returnSubSet = r((i-window):i,1:N);
%Need to get companys (column indexs) that have valid returns for last window days
    validCovStocks = coVarIndex_mom(returnSubSet);
%Need to have valid companies on this trading day (i)
    validCompany = validIndex_mom(stdmom(i,:),live(i,:),r(i+1,:),mv(i,:));
%So want the indexes that are in both these lists to finalise ValidIndex
    validIndex = intersect(validCovStocks,validCompany);
%So here we have valid indexes with clean data and live companies etc

%Now we go get the shrinkage covariance matrix 
[shrinkMatrix,shrinkFactor(k)] = shrinkCoVar_mom(returnSubSet(:,validIndex));

%Then we can run regression as normal
Xt = stdmom(i,validIndex);
Xt = [Xt;ones(1,length(Xt))];
returnYt = r(i+1,validIndex);

regThree = inv(Xt*(inv(shrinkMatrix))*Xt')*Xt*(inv(shrinkMatrix))*returnYt';
gammaThree(:,k) = regThree;
k=k+1;
end

%Risk adjust the factor returns (gammaThree)
riskAdjGammaThree = volScaling_mom(gammaThree(1,:),0.03,250);
 
%Regression Statisitics
gammaStats_mom(gammaThree(1,:),riskAdjGammaThree)

%Plot results
plotGamma_mom(gammaThree(1,:),riskAdjGammaThree,3)
