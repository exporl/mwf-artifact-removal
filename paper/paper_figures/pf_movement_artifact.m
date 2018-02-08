% Create figure for movement artifact removal

settings = mwfgui_localsettings;

% Get data and mask selecting single movement artifact
[y, Fs, ~] = get_artifact_data(3,'movement');
L = load('movement_artifact_figure_mask.mat');
mov_mask = L.mask;
y = y(:,100*200:end);
mov_mask = mov_mask(100*200:end);

% Remove movement artifact
p = mwf_params('delay', 5, 'rank', 'poseig');
W = mwf_compute(y, mov_mask, p);
[n, ~] = mwf_apply(y, W);

% Generate figure
range = 40*200:50*200;
spacing = 150;
h = figure; hold on
t = linspace(0,numel(range)/Fs,numel(range));
plot(t,y(44,range)+2*spacing,'blue') %FC6
plot(t,n(44,range)+2*spacing,'green')
plot(t,y(51,range)+spacing,'blue') %T8
plot(t,n(51,range)+spacing,'green')
plot(t,y(50,range),'blue') %C6
plot(t,n(50,range),'green')
plot(t,y(49,range)-spacing,'blue') %C4
plot(t,n(49,range)-spacing,'green')
plot(t,y(53,range)-2*spacing,'blue') %CP6
plot(t,n(53,range)-2*spacing,'green')

% legend and axis labels
legend('Original','Filtered')
xlim([0 10])
box off
ax = gca;
ax.YTick = [-300, -150, 0, 150, 300];
ax.YTickLabel = {'CP6','C4','C6','T8','FC6'};
ylabel('Channel')
xlabel('Time [s]')

% voltage scale
plot([0.5 0.5],[-120 -20],'k-')
plot([0.45 0.55],[-20 -20],'k-')
plot([0.45 0.55],[-120 -120],'k-')
text(0.6,-70,'100 \muV')

% Save figure
pf_printpdf(h, fullfile(settings.figurepath,'movement'), 'eps')
close(h)
