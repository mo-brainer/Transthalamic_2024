lm=function [p, true_estimates,lm] = multiLinRegressPermTest(predictors,Y,nperm)

% Run true regression
lm = fitlm(predictors,Y);
true_estimates = lm.Coefficients.Estimate';
%EDIT: WHICH VALUES ARE USED FOR CREATING NULL DISTRIBUTION
% lm.Coefficients.Estimate
% % lm.Coefficients.SE
% lm.Coefficients.tStat
% lm.Coefficients.pValue

for ii = 1:nperm
    permY = Y(randperm(length(Y)));
    lm_temp = fitlm(predictors,permY);
    estimates_rand(ii,:) = lm_temp.Coefficients.Estimate';
end

pvalues=[.05 .01 .001 .0001];
prctiles = 100 - 100*(pvalues/2);
confI = prctile(estimates_rand,prctiles,1); 

for jj = 1:size(true_estimates,2)
    if abs(true_estimates(jj))>confI(4,jj)
        p(1,jj)=.0001;
    elseif abs(true_estimates(jj))>confI(3,jj)
        p(1,jj)=.001;
    elseif abs(true_estimates(jj))>confI(2,jj)
        p(1,jj)=.01;
    elseif abs(true_estimates(jj))>confI(1,jj)
        p(1,jj)=.05;
    else
        p(1,jj)=1;
    end
end

end