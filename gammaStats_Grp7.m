function Statistics = gammaStats_Grp7(gamma, RiskAdjGamma)
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