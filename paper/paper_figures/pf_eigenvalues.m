% Demonstrate distribution of (sorted) eigenvalues for eye blink &
% muscle + eye blink

settings = mwfgui_localsettings;

name = 3; 
artifact = 'eyeblink';
[y, ~,~] = get_artifact_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = mwf_params('delay', 5);
[W1, GEVL] = mwf_compute(y, mask, p);
lambda_eyeblink = diag(GEVL);

artifact = 'muscle';
[y, ~,~] = get_artifact_data(name, artifact);
mask = get_artifact_mask(name, artifact);
p = mwf_params('delay', 5);
[W2, GEVL] = mwf_compute(y, mask, p);
lambda_muscle = diag(GEVL);

h = figure;
plot((lambda_eyeblink-1),'b','linewidth',2.5);
hold on
plot((lambda_muscle-1),'r-.','linewidth',3);
xlabel('GEVL number')
ylabel('GEVL magnitude')
xlim([-3; 150])
ylim([0; 160])
legend('GEVLs for eye blink artifact EEG', ...
    'GEVLs for eye blink & muscle artifact EEG')
set(gca,'box','off')

pf_printpdf(h, fullfile(settings.figurepath,'eigenvalues'), 'eps')
close(h)
