
data = load('EDA_all_metrics.mat');
metrics = data.EDA_metrics;

activities = fieldnames(metrics.P01);
features = {'SCL', 'NS_SCRs', 'Drivers'};

numSubjects = length(fieldnames(metrics));
numActivities = length(activities);
meanData = zeros(numSubjects, numActivities, length(features));
stdData = zeros(numSubjects, numActivities, length(features));

% Mean and STD
subjectFields = fieldnames(metrics);
for subjIdx = 1:numSubjects
    subjectData = metrics.(subjectFields{subjIdx});
    for actIdx = 1:numActivities
        for featIdx = 1:length(features)
            featureData = subjectData.(activities{actIdx}).(features{featIdx});
            meanData(subjIdx, actIdx, featIdx) = mean(featureData, 'all');
            stdData(subjIdx, actIdx, featIdx) = std(featureData, 0, 'all');
        end
    end
end

% Box Plot
for featIdx = 1:length(features)
    figure;
    
    plotData = squeeze(meanData(:, :, featIdx));
    
    
    boxplot(plotData, 'Labels', activities);
    title(['Box Plot for ', features{featIdx}, ' across Activities']);
    xlabel('Activity');
    ylabel(['Mean of ', features{featIdx}]);
end

