
clear

Nlags = 10;
Nsubj = 10;
SER = zeros(Nsubj, Nlags+1);
ARR = zeros(Nsubj, Nlags+1);
time = zeros(Nsubj, Nlags+1);

for delay = 0:Nlags

params = mwf_params('delay', delay, 'rank', 'poseig');
[S, A, t] = remove_artifacts_allsubjects('muscle', params);

SER(:,delay+1) = S;
ARR(:,delay+1) = A;
time(:,delay+1) = t;

end

% SER(8,:) = [];
% ARR(8,:) = [];
% SER(3,:) = [];
% ARR(3,:) = [];

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

figure
boxplot(time, 0:Nlags)
xlabel('maximum time delay used [samples]')
ylabel('computation time [s]')
title('computation time in function of delays used')