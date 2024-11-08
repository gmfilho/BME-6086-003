% Load
data = load('accel_all_metrics.mat');
metrics = data.accel_metrics;

% Activities
subject_ids = fieldnames(metrics);
activities_all = {'Sit', 'Stand', 'Cycle1', 'Cycle2', 'Run1', 'Run2'};
feature = 'MeanMagnitude';

%Variables
numSubjects = length(subject_ids);
numActivities = length(activities_all);
meanData = NaN(numSubjects, numActivities); 

% Mean magnitude
for subjIdx = 1:numSubjects
    subjectData = metrics.(subject_ids{subjIdx});
    available_activities = fieldnames(subjectData);
    
    for actIdx = 1:numActivities
        activity = activities_all{actIdx};
        
        
        if ismember(activity, available_activities)
            activityData = subjectData.(activity);
            featureData = activityData.(feature);
            meanData(subjIdx, actIdx) = mean(featureData, 'all');
        end
    end
end


figure;

plotData = meanData;

% Box plot
h = boxplot(plotData, 'Labels', activities_all, 'Colors', [0.5, 0.7, 1], 'Symbol', '');
set(h, 'LineWidth', 1.2); 
set(gca, 'YScale', 'log'); 


title(['Box Plot for ', feature, ' across Activities']);
xlabel('Activity');
ylabel(['Mean of ', feature, ' (Log Scale)']);

% Save
saveas(gcf, ['BoxPlot_' feature '_across_Activities_log.png']);
