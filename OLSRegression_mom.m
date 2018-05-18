clc;clear all;
%Load Data
load('UK_StandardMomentum.mat') 
load('UK_live.mat')
load('UK_MarketValues.mat')
load('UK_Returns.mat')

%Standardise the Momentum Exposure
stdmom = standardiseFactor_mom(mom,live);

%So we call the validIndex function to get the valid indexs on each day
gamma=[]; k=1;
for i = 501:6740
    validIndex = validIndex_mom(stdmom(i,:),live(i,:),r(i+1,:),mv(i,:));
%Now you have the valid index for the day i - can go get your data
    Xt = stdmom(i,validIndex);
%Need to add ones for intercept in regression
    Xt = [Xt;ones(1,length(Xt))];
%Return one period ahead    
    returnYt = r(i+1,validIndex);
%Now run regression
    regOne = inv(Xt*Xt')*Xt*returnYt';
    gamma(:,k) = regOne;
    k=k+1;
end

%Now we want to risk adjust them using the volScaling function
%Currently 4.5% is the target volatility
riskAdjGamma = volScaling_mom(gamma(1,:),0.045,250);

%Regression Statisitics - Outputs table of results
gammaStats_mom(gamma(1,:),riskAdjGamma)

%Plot results
plotGamma_mom(gamma(1,:),riskAdjGamma,1)


