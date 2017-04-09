% Demonstrate distribution of (sorted) eigenvalues for eye blink &
% muscle + eye blink

settings = mwfgui_localsettings;

name = 3; 
artifact = 'eyeblink';
[y, ~,~] = get_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = filter_params('delay', 0);
[w1, GEVL] = filter_compute(y, mask, p);
lambda_eyeblink = diag(GEVL);

artifact = 'muscle';
[y, ~,~] = get_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = filter_params('delay', 0);
[w2, GEVL] = filter_compute(y, mask, p);
lambda_muscle = diag(GEVL);

h = figure;
plot(lambda_eyeblink./max(lambda_eyeblink));
hold on
plot(lambda_muscle./max(lambda_muscle));
xlabel('GEVL number')
ylabel('Normalized GEVLs')
legend('Eye blink artifacts','Eye blink & muscle artifacts')

pf_printpdf(h, fullfile(settings.figurepath,'eigenvalues'))
close(h)
