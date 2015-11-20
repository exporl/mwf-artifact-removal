for taumax = 1:15
tic
script_MWF_test_lags
tauSER(taumax) = SER; tauARR(taumax) = ARR;
time(taumax) = toc;
end

plot(tauSER)
hold on
plot(tauARR,'red')

figure
plot(time)