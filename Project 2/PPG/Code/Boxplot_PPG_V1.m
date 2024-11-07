
data = load('all_HRV_metrics.mat');
metrics = data.all_HRV_metrics;

% Activities 
subject_ids = fieldnames(metrics);
activities_all = {'Sit', 'Stand', 'Cycle1', 'Cycle2', 'Run1', 'Run2'};
features = {'meanNN', 'SDNN', 'RMSSD', 'NN50count', 'pNN50'};

% Variables
numSubjects = length(subject_ids);
numActivities = length(activities_all);
numFeatures = length(features);
meanData = NaN(numSubjects, numActivities, numFeatures); % NaN

% Mean of the each subject
for subjIdx = 1:numSubjects
    subjectData = metrics.(subject_ids{subjIdx});
    available_activities = fieldnames(subjectData);
    
    for actIdx = 1:numActivities
        activity = activities_all{actIdx};
        
        
        if ismember(activity, available_activities)
            activityData = subjectData.(activity);
            
            
            for featIdx = 1:numFeatures
                featureData = activityData.(features{featIdx});
                meanData(subjIdx, actIdx, featIdx) = mean(featureData, 'all');
            end
        end
    end
end

% Plots
for featIdx = 1:numFeatures
    figure;
   
    plotData = squeeze(meanData(:, :, featIdx));
    
  
    h = boxplot(plotData, 'Labels', activities_all, 'Colors', [0.5, 0.7, 1], 'Symbol', '');
    set(h, 'LineWidth', 1.2); 
    
    
    title(['Box Plot for ', features{featIdx}, ' across Activities']);
    xlabel('Activity');
    ylabel(['Mean of ', features{featIdx}]);
    
   
    saveas(gcf, ['BoxPlot_' features{featIdx} '_across_Activities.png']);
end
