# Momentum-Strategy-MATLAB-
##### Goal of the project was to analyse momentum as a factor in the UK with 1605 funds. It was applied by the use of fama macbeth (cross-sectional) regressions in three ways.
##### 1) Typical OLS form, regressing momemtum factor returns on the day ahead returns
##### 2) GLS form, where I included a Market Weight matrix for each company in the regressions
##### 3) Using a Risk adjusted CoVariance matrix, a Ledoit and Wolf shrinkage approach was used to calculate a CoVaraince matrix with less estimation error
##### All files are attached and displayed below, note the report with all methods and results is attached - Quant_MomentumReport

```matlab
%Momemtum Strategy Analysis
%Note I have 3 separate scripts for each regression attached (OLS,GLS,shrink)
%could easily put it all in one (more efficient,not calling certain functions 3 times)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  Regression One - OLS  %%%%%%
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Regression Two - GLS %%%%%%%%
gammaTwo=[]; k=1;
for i = 501:6740
    validIndex = validIndex_mom(stdmom(i,:),live(i,:),r(i+1,:),mv(i,:));
    Xt = stdmom(i,validIndex);
    Xt = [Xt;ones(1,length(Xt))];
    
    %Get Market Value as diagonal matrix
    MV = computeMV_mom(mv(i,validIndex));
    
    returnYt = r(i+1,validIndex);
    
    %Run regression
    regTwo = inv(Xt*MV*Xt')*Xt*MV*returnYt';
    gammaTwo(:,k) = regTwo;
    k=k+1;
end

%Risk adjust the factor returns (gammas)
%Target is 8 percent here for example
riskAdjGammaTwo = volScaling_mom(gammaTwo(1,:),0.08,250);

%Regression Statisitics
gammaStats_mom(gammaTwo(1,:),riskAdjGammaTwo)

%Plot results
plotGamma_mom(gammaTwo(1,:),riskAdjGammaTwo,2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Third Regression - GLS with risk adjusted CoVar%%%%%%%
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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Below are the function called in above Regressions

%standardiseFactor
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

%validIndex
function getIndex = validIndex_mom(momRow,liveRow,returnRow,mvRow)
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

%CoVarIndex
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

%computeMV
function answer = computeMV_mom(mvRow)
%Want to transform market value of each row into weights (each row sums to one)
%Input is 1 row of Mom - function called inside loop, passing in each day
%Once this function is called, the data has be cleaned already
sumacross = nansum(mvRow);
%Output - Want it to be a diagonal matrix for regression
answer = diag(mvRow/sumacross);
end

%Vol Scaling
function scaledGamma = volScaling_mom(gammas,targetVol,windowLength)
%Now can scale our gammas (factor returns)
%On each day get the S.D for the window length. 
%So this create a vector with the daily standard deviation for window size

N = length(gammas);
for j = flip(windowLength+1:N)
    %nanstd just incase - this should be same length of gammas
    std(j) = sqrt(nansum((gammas(j-windowLength:j).^2)/250))*sqrt(250);
end

%Cheating a little as for first 250 days there no previous gammma
%So we set the first 250 to the 251 days - in report
std(1:windowLength)=std(windowLength+1);

%Get the ratio of TargetVol/std
std = targetVol./std;

%Finally multiple by gamma to scale them
scaledGamma = gammas.*std;


%plotGamma
function plotter = plotGamma_mom(gamma,riskAdjGamma,regNumber)
%plot gamma and risk adjusted gamma - factor returns
plot(cumsum(gamma))
hold on
plot(cumsum(riskAdjGamma))
hold off
xlabel('Number of Days') % x-axis label
ylabel('Return') % y-axis label

%Put legend in top left of graph - NorthWest
legend('Regression','Risk Adjusted','Location','NorthWest')
if regNumber==1
    title('OLS Regression')
elseif regNumber==2
    title('GLS Regression')
elseif regNumber==3
    title('Shrink Co-Variance Regression')
end

%Statistics
function Statistics = gammaStats_mom(gamma, RiskAdjGamma)
    %Obtain stats for both gamma and risk adjusted gamma
    tstat = nanmean(gamma(1,:)) / (nanstd(gamma(1,:))/sqrt(length(gamma(1,:))));
    tstatRiskAdj = nanmean(RiskAdjGamma) / (nanstd(RiskAdjGamma)/sqrt(length(RiskAdjGamma)));
    tstat = [tstat; tstatRiskAdj];
    
    kurt = [kurtosis(gamma(1,:)); kurtosis(RiskAdjGamma)];
    skew = [skewness(gamma(1,:)); skewness(RiskAdjGamma)];
    
    average = [mean(gamma(1,:))*250; mean(RiskAdjGamma)*250];
    average = average*100;
    %multiply be 100 for percentage, using 250 to annualise figures
    stdev = [std(gamma(1,:))*sqrt(250); std(RiskAdjGamma)*sqrt(250)];
    stdev = stdev*100;
    
    %Need to convert the cumlative sum to double for maxdrawdown function
    %Arthimetic will report the actual real number
    drawdown = [maxdrawdown(double(cumsum(gamma(1,:))),'arithmetic'); ...
        maxdrawdown(double(cumsum(RiskAdjGamma)),'arithmetic')];
    drawdown = drawdown*100;
    
    %Using a risk free rate of 2.5%
    SharpeRatio = [sharpe(double(cumsum(gamma(1,:))),0.025); ...
        sharpe(double(cumsum(RiskAdjGamma)),0.025)];
    
    Type = ['Regression'; 'RiskAdjust'];
    T = table(Type, tstat, average, stdev, skew, kurt, drawdown, SharpeRatio);
    
    T.Properties.VariableNames = {'GammaType','tstat','Mean', 'StandardDev', ...
        'Skewness','Kurtosis', 'MaxDrawdown', 'SharpeRatio'}
end

```
