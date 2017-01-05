
clear

Nlags = 5;
Nsubj = 10;
SER = zeros(Nsubj, Nlags+1);
ARR = zeros(Nsubj, Nlags+1);

for delay = 0:Nlags

params = filter_params('delay', delay);
[S, A] = remove_artifacts_allsubjects('eyeblink', params);

SER(:,delay+1) = S;
ARR(:,delay+1) = A;

end

figure
boxplot(SER, 0:Nlags)
xlabel('maximum time delay used [samples]')
ylabel('SER [dB]')
title('SER in function of delays used')
hold on
plot(1:Nlags+1,SER.','.--','MarkerSize',10)

figure
boxplot(ARR, 0:Nlags)
xlabel('maximum time delay used [samples]')
ylabel('ARR [dB]')
title('ARR in function of delays used')
hold on
plot(1:Nlags+1,ARR.','.--','MarkerSize',10)