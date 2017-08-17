% Demonstrate effect of artifact SNR in hybrid data on SER and ARR
%
% synthetic eye blink data for all subjects
% SNRs go from -24 to 12 (factor 1/16 to 4)

clear
settings = mwfgui_localsettings;

Nsubj = 10;
SNRs = -24:3:12;
Nsnrs = numel(SNRs);

SER = zeros(Nsubj, Nsnrs);
ARRhy = zeros(Nsubj, Nsnrs); % synthetic ARR (i.e. with real d)
ARRre = zeros(Nsubj, Nsnrs); % real ARR (i.e. with y as approximation)

params = filter_params('delay', 10, 'rank', 'poseig');

for i = 1:Nsubj
    for j = 1:Nsnrs
    T   = EEG_data_synthetic(i, SNRs(j));
    [w]         = filter_compute(T.eeg_data, T.mask, params);
    [v, d]      = filter_apply(T.eeg_data, w);
    [SER(i,j), ARRhy(i,j)]  = filter_performance(T.eeg_data, d, T.mask, T.artifact);
    [~, ARRre(i,j)]  = filter_performance(T.eeg_data, d, T.mask);
    end
end
ARRdiff = ARRhy - ARRre;

fig = figure; hold on
hser = shadedErrorbar(SNRs,SER(:,:),{@mean,@std},'-b',1);
harrhy = shadedErrorbar(SNRs,ARRhy(:,:),{@mean,@std},'-r',1);
harrre = shadedErrorbar(SNRs,ARRre(:,:),{@mean,@std},'-g',1);
harrdiff = shadedErrorbar(SNRs,ARRdiff(:,:),{@mean,@std},'-k',1);

legend([hser.mainLine, harrhy.mainLine, harrre.mainLine, harrdiff.mainLine], ...
    {'SER','ARR_{hybrid}', 'ARR_{real}', 'ARR_{diff}'},'Location','northwest')    
xlabel('Artifact SNR [dB]')
ylabel('SER and ARR [dB]')
xlim([SNRs(1) SNRs(end)])
pf_printpdf(fig, fullfile(settings.figurepath,'hybrid_SER_ARR'))
close(fig)

