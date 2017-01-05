
clear

rank_options = {'full','poseig'};
delay_options = [0, 5];

for i = 1:numel(delay_options)
    for j = 1:numel(rank_options)
        
        params = filter_params('delay',delay_options(i),'rank',rank_options{j});
        [S, A] = remove_artifacts_allsubjects('eyeblink', params);
        
        SER(:,j+(i-1)*numel(rank_options)) = S;
        ARR(:,j+(i-1)*numel(rank_options)) = A;
        label{j+(i-1)*numel(rank_options)} = [rank_options{j} '_' num2str(delay_options(i))];
    end
    
end

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
