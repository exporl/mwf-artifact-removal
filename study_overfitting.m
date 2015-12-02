% study effects of time lag on SER and ARR and possible overfitting on
% training data effect

clear

for subject = 1:9

switch subject
    case 1
        name = 'alex';
    case 2
        name = 'anneleen';
    case 3
        name = 'hanneke';
    case 4
        name = 'jan-peter';
    case 5
        name = 'jeroen';
    case 6
        name = 'jonas';
    case 7
        name = 'lorenz';
    case 8
        name = 'otto';
    case 9
        name = 'steven';
end

for taumax = 0:15
script_MWF_study_overfitting
tauSER(taumax+1) = SER; tauARR(taumax+1) = ARR;
tauSER_full(taumax+1) = SER_full; tauARR_full(taumax+1) = ARR_full;
tauSER_back(taumax+1) = SER_back; tauARR_back(taumax+1) = ARR_back;

end

figure
subplot(2,1,1)
plot(0:15,tauSER,0:15,tauSER_full,'red',0:15,tauSER_back,'green')
title(['SER for training data and full data - ' name])
legend('training data(0-30s)','full dataset','non-training data','Location','northwest')

subplot(2,1,2)
plot(0:15,tauARR,0:15,tauARR_full,'red',0:15,tauARR_back,'green')
title(['ARR for training data and full data - ' name])
legend('training data(0-30s)','full dataset','non-training data','Location','northwest')

end
