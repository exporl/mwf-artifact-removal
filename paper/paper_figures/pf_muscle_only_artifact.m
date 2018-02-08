% Create figure for movement artifact removal

settings = mwfgui_localsettings;

% Get data and mask for muscle + eye blink artifact data
[y, Fs, ~] = get_artifact_data(1,'muscle');
L = load('muscle_artifact_figure_mask.mat');
mask = L.mask;

% Remove artifacts
p = mwf_params('delay', 5, 'rank', 'poseig');
W = mwf_compute(y, mask, p);
[n, d] = mwf_apply(y, W);

% Generate figure
range = 44*200:48*200;
spacing = 150;
h = figure; hold on
t = linspace(0,numel(range)/Fs,numel(range));
leg1 = plot(t,y(33,range)+2*spacing,'blue'); %Fpz
plot(t,y(34,range)+spacing,'blue') %Fp2
plot(t,y(35,range),'blue') %AF8
plot(t,y(36,range)-spacing,'blue') %AF4
plot(t,y(37,range)-2*spacing,'blue') %AFz
leg2 = plot(t,n(33,range)+2*spacing,'green');
plot(t,n(34,range)+spacing,'green')
plot(t,n(35,range),'green')
plot(t,n(36,range)-spacing,'green')
plot(t,n(37,range)-2*spacing,'green')

% legend and axis labels
legend([leg1, leg2],'Original','Filtered')
xlim([0 4])
ylim([-450 450])
box off
ax = gca;
ax.YTick = [-300, -150, 0, 150, 300];
ax.YTickLabel = {'AFz','AF4','AF8','Fp2','Fpz'};
ylabel('Channel')
xlabel('Time [s]')

% voltage scale
plot([0.2 0.2],[-120 -20],'k-')
plot([0.18 0.22],[-20 -20],'k-')
plot([0.18 0.22],[-120 -120],'k-')
text(0.24,-70,'100 \muV')

% Save figure
pf_printpdf(h, fullfile(settings.figurepath,'muscle_only'), 'eps')
close(h)
