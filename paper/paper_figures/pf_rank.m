% Demonstrate effect of rank on SER and ARR
%
% muscle + eye blink artifact data for all subjects
% 5 time lags are included in the analysis

clear
settings = mwfgui_localsettings;

rank_options = {'pct'};
rank_pct = [1, 2:2:100];
delay_options = [5];
artifact = {'eyeblink','muscle'};

for a = 1:numel(artifact)
    SER = zeros(10,numel(rank_pct),numel(delay_options));
    ARR = zeros(10,numel(rank_pct),numel(delay_options));
    pct = zeros(10,numel(delay_options));
    for i = 1:numel(delay_options)
        for j = 1:numel(rank_pct)
            
            params = mwf_params('delay',delay_options(i),'rank',rank_options{1},'rankopt',rank_pct(j));
            [S, A] = remove_artifacts_allsubjects(artifact{a}, params);
            
            SER(:,j,i) = S;
            ARR(:,j,i) = A;
        end
        
        % what are normal keep percentages of positive eigenvalues?
        params = mwf_params('delay',delay_options(i),'rank','poseig');
        [~, ~, ~, pct(:,i)] = remove_artifacts_allsubjects(artifact{a}, params);
    end
    
    if strcmp(artifact{a},'eyeblink')
        SER(8,:,:) = []; ARR(8,:,:) = []; pct(8,:) = []; % remove continuous eyeblinking
    end
    
    fig = figure; hold on
    harr = contributions.shadedErrorbar(rank_pct,ARR(:,:,1),{@mean,@std},'--r',1);
    hser = contributions.shadedErrorbar(rank_pct,SER(:,:,1),{@mean,@std},'-b',1);
    
    hser.mainLine.LineWidth = 1;
    harr.mainLine.LineWidth = 1.5;
    
    mp = mean(pct)*100;
    sp = std(pct)*100;
    plot([mp,mp], [0,30], 'k-', 'LineWidth', 1)
    plot([mp-sp,mp-sp], [0,30], 'k:', 'LineWidth', 1)
    plot([mp+sp,mp+sp], [0,30], 'k:', 'LineWidth', 1)
    
    legend([hser.mainLine, harr.mainLine],{'SER','ARR'},'Location','northeast')
    
    xlabel('Percent of eigenvalues kept [%]')
    ylabel('SER and ARR [dB]')
    ylim([0 25])
    pf_printpdf(fig, fullfile(settings.figurepath,['rank_SER_ARR_' artifact{a}]), 'eps')
    close(fig)
    
end
