
clear

rank_options = {'pct'}; % 'full','poseig',
rank_pct = [1, 5:5:100];
delay_options = [0, 5];

for i = 1:numel(delay_options)
    for j = 1:numel(rank_pct)
        
        params = mwf_params('delay',delay_options(i),'rank',rank_options{1},'rankopt',rank_pct(j));
        [S, A] = remove_artifacts_allsubjects('muscle', params);
        
        SER(:,j,i) = S;
        ARR(:,j,i) = A;
        label{j} = [rank_options{1} num2str(rank_pct(j)) '_' num2str(delay_options(i))];
    end
    
end
SER(8,:,:) = [];
ARR(8,:,:) = [];

figure
contributions.shadedErrorbar(rank_pct,SER(:,:,1),{@mean,@std},'-b',1)
hold on
contributions.shadedErrorbar(rank_pct,SER(:,:,2),{@mean,@std},'-r',1)

figure
contributions.shadedErrorbar(rank_pct,ARR(:,:,1),{@mean,@std},'-b',1)
hold on
contributions.shadedErrorbar(rank_pct,ARR(:,:,2),{@mean,@std},'-r',1)

figure
boxplot(SER, 1:size(SER,2))
xlabel('Processing parameters')
ylabel('SER [dB]')
title('SER in function of parameters used')
hold on
plot(SER.','.--','MarkerSize',10)
set(gca,'XTick',1:size(SER,2))
set(gca,'XTickLabel',label)


figure
boxplot(ARR, 1:size(ARR,2))
xlabel('Processing parameters')
ylabel('ARR [dB]')
title('ARR in function of parameters used')
hold on
plot(ARR.','.--','MarkerSize',10)
set(gca,'XTick',1:size(ARR,2))
set(gca,'XTickLabel',label)
