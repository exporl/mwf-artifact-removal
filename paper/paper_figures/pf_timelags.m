% Demonstrate effect of time lags on SER and ARR
clear

settings = mwfgui_localsettings;
artifact = 'muscle';
rank = 'poseig'; % 'full', 'poseig'

Nlags = 15;
Nsubj = 10;
SER = zeros(Nsubj, Nlags+1);
ARR = zeros(Nsubj, Nlags+1);

for delay = 0:Nlags

params = mwf_params('delay', delay, 'rank', rank);
[S, A, t] = remove_artifacts_allsubjects(artifact, params);

SER(:,delay+1) = S;
ARR(:,delay+1) = A;

end

hSER = figure;
boxplot(SER, 0:Nlags, 'Colors', 'k')
xlabel('Time delay [samples]')
ylabel('SER [dB]')
hold on
plot(1:Nlags+1,SER.','.--','MarkerSize',10)
set(gca,'box','off')
pf_printpdf(hSER, fullfile(settings.figurepath,'timelag_SER'), 'eps')
close(hSER)

hARR = figure;
boxplot(ARR, 0:Nlags, 'Colors', 'k')
xlabel('Time delay [samples]')
ylabel('ARR [dB]')
hold on
plot(1:Nlags+1,ARR.','.--','MarkerSize',10)
set(gca,'box','off')
pf_printpdf(hARR, fullfile(settings.figurepath,'timelag_ARR'), 'eps')
close(hARR)
