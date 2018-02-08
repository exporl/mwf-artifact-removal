
clear

Nmu = 10;
Nsubj = 10;
SER = zeros(Nsubj, Nmu);
ARR = zeros(Nsubj, Nmu);

for mu = 1:Nmu

params = mwf_params('mu', mu);
[S, A] = remove_artifacts_allsubjects('muscle', params);

SER(:,mu) = S;
ARR(:,mu) = A;

end

figure
boxplot(SER, 1:Nmu)
xlabel('maximum noise weighting parameter mu used [-]')
ylabel('SER [dB]')
title('SER in function of noise weighting used')
hold on
plot(1:Nmu,SER.','.--','MarkerSize',10)

figure
boxplot(ARR, 1:Nmu)
xlabel('maximum noise weighting parameter mu used [-]')
ylabel('ARR [dB]')
title('ARR in function of noise weighting used')
hold on
plot(1:Nmu,ARR.','.--','MarkerSize',10)