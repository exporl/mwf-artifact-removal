% Demonstrate distribution of (sorted) eigenvalues for eye blink &
% muscle + eye blink

settings = mwfgui_localsettings;

name = 3; 
artifact = 'eyeblink';
[y, ~,~] = get_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = filter_params('delay', 5);
[w1, GEVL] = filter_compute(y, mask, p);
lambda_eyeblink = diag(GEVL);

artifact = 'muscle';
[y, ~,~] = get_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = filter_params('delay', 5);
[w2, GEVL] = filter_compute(y, mask, p);
lambda_muscle = diag(GEVL);

h = figure;
plot((lambda_eyeblink-1),'linewidth',2);
hold on
plot((lambda_muscle-1),'linewidth',2);
xlabel('GEVL number')
ylabel('GEVLs')
xlim([-3; size(w1,1)+3])
ylim([-1; 160])
legend('Eye blink artifacts','Eye blink & muscle artifacts')
set(gca,'box','off')

pf_printpdf(h, fullfile(settings.figurepath,'eigenvalues'))
close(h)
