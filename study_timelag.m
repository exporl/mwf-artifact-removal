
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

for taumax = 0:10
tic
script_MWF_test_lags
tauSER(taumax+1) = SER; tauARR(taumax+1) = ARR;
time(taumax+1) = toc;
end

figure(1)
hold on
plot(0:taumax,tauSER)

figure(2)
hold on
plot(0:taumax,tauARR,'red')

figure(3)
hold on
plot(0:taumax,time)

end
