% Demonstrate effect of artifact SNR in hybrid data on SER and ARR
%
% synthetic eye blink data for all subjects
% SNRs go from -24 to 12 (factor 1/16 to 4)

clear
settings = mwfgui_localsettings;

Nsubj = 10;
SNRs = -12:3:24;
Nsnrs = numel(SNRs);

SER = zeros(Nsubj, Nsnrs);
ARRhy = zeros(Nsubj, Nsnrs); % hybrid ARR (i.e. with real d)
ARRre = zeros(Nsubj, Nsnrs); % real ARR (i.e. with y as approximation)
realSNRs = zeros(Nsubj, 1);

params = mwf_params('delay', 5, 'rank', 'poseig');

for i = 1:Nsubj
    for j = 1:Nsnrs
    T   = EEG_data_synthetic(i, SNRs(j));
    [W]         = mwf_compute(T.eeg_data, T.mask, params);
    [~, d]      = mwf_apply(T.eeg_data, W);
    [SER(i,j), ARRhy(i,j)]  = mwf_performance(T.eeg_data, d, T.mask, T.artifact);
    [~, ARRre(i,j)]  = mwf_performance(T.eeg_data, d, T.mask);
    end
    realSNRs(i) = T.realisticSNR;
end
ARRdiff = ARRhy - ARRre;

fig = figure; hold on
harrdiff = contributions.shadedErrorbar(SNRs,ARRdiff(:,:),{@mean,@std},'-k*',1);
harrhy = contributions.shadedErrorbar(SNRs,ARRhy(:,:),{@mean,@std},':g',1);
harrre = contributions.shadedErrorbar(SNRs,ARRre(:,:),{@mean,@std},'--r',1);
hser = contributions.shadedErrorbar(SNRs,SER(:,:),{@mean,@std},'-b',1);

hser.mainLine.LineWidth = 1;
harrre.mainLine.LineWidth = 1.5;
harrhy.mainLine.LineWidth = 1.5;

mp = mean(realSNRs);
sp = std(realSNRs);
plot([mp,mp], [-50,50], 'k-', 'LineWidth', 1)
plot([mp-sp,mp-sp], [-50,50], 'k:', 'LineWidth', 1)
plot([mp+sp,mp+sp], [-50,50], 'k:', 'LineWidth', 1)

legend([hser.mainLine, harrre.mainLine, harrhy.mainLine, harrdiff.mainLine], ...
    {'SER','ARR_{real}', 'ARR_{hybrid}', 'ARR_{diff}'},'Location','northwest')    
xlabel('Artifact SNR [dB]')
ylabel('SER and ARR [dB]')
xlim([SNRs(1) SNRs(end)])
ylim([-10 30])
set(gca,'XTick',SNRs);
pf_printpdf(fig, fullfile(settings.figurepath,'hybrid_SER_ARR'), 'eps')
close(fig)

