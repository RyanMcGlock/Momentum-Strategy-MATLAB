clc;clear all;
%Second Regression
%Load Data
load('UK_StandardMomentum.mat') 
load('UK_live.mat')
load('UK_MarketValues.mat')
load('UK_Returns.mat')

%Standardise the Mom exposures
stdmom = standardiseFactor_Grp7(mom,live);

gammaTwo=[]; k=1;
for i = 501:6740
    validIndex = validIndex_Grp7(stdmom(i,:),live(i,:),r(i+1,:),mv(i,:));
    Xt = stdmom(i,validIndex);
    Xt = [Xt;ones(1,length(Xt))];
    
    %Get Market Value as diagonal matrix
    MV = computeMV_Grp7(mv(i,validIndex));
    
    returnYt = r(i+1,validIndex);
    
    %Run regression
    regTwo = inv(Xt*MV*Xt')*Xt*MV*returnYt';
    gammaTwo(:,k) = regTwo;
    k=k+1;
end

%Risk adjust the factor returns (gammas)
%Target is 8 percent here
riskAdjGammaTwo = volScaling_Grp7(gammaTwo(1,:),0.08,250);

%Regression Statisitics
gammaStats_Grp7(gammaTwo(1,:),riskAdjGammaTwo)

%Plot results
plotGamma_Grp7(gammaTwo(1,:),riskAdjGammaTwo,2)



