function pf_methodcomparison(artifact, methods, SER, ARR, procTime)

switch artifact
    case 'eyeblink'
        selectsubject = [1:7,9:10];
        offset = [-5, 0, 0];
    case 'muscle'
        selectsubject = 1:10;
        offset = [-12, -0.5, 0];
    otherwise
        error('Error: invalid artifact specifier');
end

N = numel(methods);

SER = SER(selectsubject,:);
ARR = ARR(selectsubject,:);
procTime = procTime(selectsubject,:);

meandata = [mean(SER); mean(ARR); mean(procTime)];
stddata = [std(SER); std(ARR); std(procTime)];

% draw bars
hBar = bar(meandata);
labels = {'SER','ARR','Time'};
set(gca, 'XTick', 1:numel(meandata), 'XTickLabel', labels);

% viridis colormap (grayscale print friendly)
cmap = [    0.2670    0.0049    0.3294
    0.2302    0.3213    0.5455
    0.1282    0.5651    0.5509
    0.3629    0.7867    0.3866
    0.9932    0.9062    0.1439];
colormap(cmap)
legend(methods, 'Location','northwest')

% draw errorbars
hold on
for mIdx = 1:N 
    errorbar(hBar(mIdx).XData + hBar(mIdx).XOffset, meandata(:,mIdx), ...
        zeros(1,numel(labels)), stddata(:,mIdx)/2,'k.')
end

% perform statistics and draw significance markers
for measure = 1:2; % for SER and ARR
    switch measure
        case 1
            data = SER;
        case 2
            data = ARR;
        case 3
            data = procTime;
    end
    
    % calculate p-values
    pval = zeros(N);
    for mIdx1 = 1:N
        for mIdx2 = mIdx1:N
            pval(mIdx1,mIdx2) = signrank(data(:,mIdx1), data(:,mIdx2));
            pval(mIdx2,mIdx1) = pval(mIdx1,mIdx2);
        end
    end
    
    p = [pval(1,2:5) pval(2,3:5)];
    p = contributions.bonf_holm(p,0.05);
    pval(1,2:5) = p(1:4);
    pval(2,3:5) = p(5:7);
    
    % significance bars
    alpha = 0.05;
    adjust = zeros(2,N);
    for mIdx = 1:2
        pvals = pval(mIdx, mIdx:end);
        adjust(mIdx, find(pvals < alpha) + mIdx - 1) = 1;
        nsig = sum(pvals < alpha);
        if nsig > 0
            groups = repmat({[1,2]}, 1, nsig);
            pvals(pvals > alpha) = [];
            hSig{mIdx} = contributions.sigstar(groups, pvals);
        end
    end
    
    % adjust significance bars
    for mIdx = 1:numel(hSig)
        select = find(adjust(mIdx,:));
        for lIdx = 1:size(hSig{mIdx}, 1)
            hLine = findobj(hSig{mIdx}(lIdx,1));
            hLine.XData(1:2) = hBar(mIdx).XData(measure) + hBar(mIdx).XOffset;
            hLine.XData(3:4) = hBar(select(lIdx)).XData(measure) + ...
                hBar(select(lIdx)).XOffset;
            hStar = findobj(hSig{mIdx}(lIdx,2));
            hStar.Position(1) = mean(hLine.XData(2:3));
            
            % correct y-values
            hLine.YData = hLine.YData + offset(measure);
            hStar.Position(2) = hStar.Position(2) + offset(measure);
        end
    end
    
end

% make axis
axL = gca;
ylabel('SER and ARR [dB]')
set(axL, 'YLim', [0 25]);
box off

axR = axes('XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','k','YColor','k');
set(axR, 'XTick', [], 'YTick', axL.YTick,...
    'YLim', axL.YLim, 'YTickLabel', axL.YTickLabel)
ylabel('Processing Time [s]')
box off

% save figure
settings = mwfgui_localsettings;
pf_printpdf(gcf, fullfile(settings.figurepath, ['methodcomparison' '_' artifact]), 'eps')
close(gcf)

end
