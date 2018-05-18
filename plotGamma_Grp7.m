function plotter = plotGamma_Grp7(gamma,riskAdjGamma,regNumber)
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
