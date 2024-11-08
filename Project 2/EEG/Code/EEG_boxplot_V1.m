
data = load('EEG_all_metrics.mat');
metrics = data.EEG_metrics;


subject_ids = fieldnames(metrics);
activities_all = {'Sit', 'Stand', 'Cycle1', 'Cycle2', 'Run1', 'Run2'};
bands = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};
frequency_ranges = {'0.5-4 Hz', '4-8 Hz', '8-13 Hz', '13-30 Hz', '30-50 Hz'};

% Variables
numSubjects = length(subject_ids);
numActivities = length(activities_all);
numBands = length(bands);
meanData = NaN(numSubjects, numActivities, numBands); % NaN to miss data
stdData = NaN(numSubjects, numActivities, numBands);

% Mean and STD
for subjIdx = 1:numSubjects
    subjectData = metrics.(subject_ids{subjIdx});
    available_activities = fieldnames(subjectData);
    
    for actIdx = 1:numActivities
        activity = activities_all{actIdx};
        
        
        if ismember(activity, available_activities)
            bandPowers = subjectData.(activity).BandPowers;
            
           
            for bandIdx = 1:numBands
                meanData(subjIdx, actIdx, bandIdx) = mean(bandPowers(:, bandIdx), 'all');
                stdData(subjIdx, actIdx, bandIdx) = std(bandPowers(:, bandIdx), 0, 'all');
            end
        end
    end
end

% Box plot
for bandIdx = 1:numBands
    figure;
    
    plotData = squeeze(meanData(:, :, bandIdx));
    
   
    h = boxplot(plotData, 'Labels', activities_all, 'Colors', [0.5, 0.7, 1], 'Symbol', '');
    set(h, 'LineWidth', 1.2); 
    
    
    set(gca, 'YScale', 'log');
    
    
    title(['Box Plot for ', bands{bandIdx}, ' Band Power (', frequency_ranges{bandIdx}, ') across Activities']);
    xlabel('Activity');
    ylabel(['Mean Power of ', bands{bandIdx}, ' Band']);
    
    
    saveas(gcf, ['BoxPlot_' bands{bandIdx} '_Band_Power.png']);
end
