for tau = 1:10
script_MWF_test_lags
tauSER(tau) = SER; tauARR(tau) = ARR;
end

plot(tauSER)
hold on
plot(tauARR,'red')