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

        
    




end