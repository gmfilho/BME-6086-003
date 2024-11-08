filename = '2021_12_03-16_44_37_Breathing.csv';
data = readtable(filename);

subject_ids = {'P01'};
activity_times.P01 = {'Sit', 300; 'Stand', 610; 'Cycle1', 910; 'Cycle2', 1210; 'Run1', 1510; 'Run2', 1810; 'End', 2110};
%patient_id = subject_ids{s};
activities = activity_times.(patient_id);

fs = 25;  % Frequency
breathing_waveform = data.BreathingWaveform;
n_points = length(breathing_waveform);  
time = (0:n_points-1) / fs;  

cutoff_freq = 0.5;  
[b, a] = butter(2, cutoff_freq / (fs / 2), 'low');
breathing_filtered = filtfilt(b, a, breathing_waveform);

fig = figure('Visible', 'off');
set(fig, 'Position', [100, 100, 1200, 800]);
plot(time, breathing_filtered);
xlabel('Time (seconds)');
ylabel('Breathing Waveform');
title('Respiration Waveform - P01');

% Line for each activity 
 for a = 1:size(activities, 1)
        activity_name = activities{a, 1};
        start_time = activities{a, 2};
        xline(start_time, '--k', activity_name, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
 end

 saveas(fig, sprintf('Respiration_Activities_P01s.jpg'));
 close(fig);




%% Teste 2

start_sample = 300 * fs;
end_sample = 600 * fs;
breathing_segment = breathing_waveform(start_sample:end_sample);
time_segment = time(start_sample:end_sample);

% LPF
cutoff_freq = 0.5;  % Frequência de corte em Hz, ajustável
[b, a] = butter(2, cutoff_freq / (fs / 2), 'low');
breathing_filtered = filtfilt(b, a, breathing_segment);

% Normalization
breathing_normalized = breathing_filtered - mean(breathing_filtered);
breathing_normalized = breathing_normalized / max(abs(breathing_normalized));

% Movmean filter
window_size = round(fs * 0.5);  
breathing_smoothed = movmean(breathing_normalized, window_size);

% Peaks
[pks, locs] = findpeaks(breathing_smoothed, 'MinPeakDistance', fs);  % A distância mínima é de 1 segundo

% RR
respiration_rate = numel(pks) / 5;  %5 minutes

disp(['Respiration Rate: ', num2str(respiration_rate), ' breaths per minute']);

% Plot
figure;
plot(time_segment, breathing_smoothed);
hold on;
plot(time_segment(locs), pks, 'ro');  %Mark the peaks
xlabel('Time (seconds)');
ylabel('Normalized Breathing Waveform');
xlim([299, 601]);
title('Processed Respiration Signal with Detected Peaks (300s to 600s) - P01');
legend('Processed Signal', 'Detected Peaks');

% RR in the graph
x_position = time_segment(1) + 0.3 * (time_segment(end) - time_segment(1));
y_position = min(breathing_smoothed) + 0.1 * (max(breathing_smoothed) - min(breathing_smoothed));
text(x_position, y_position, ...
    ['Respiration Rate: ', num2str(respiration_rate), ' breaths per minute'], ...
    'FontSize', 12, 'Color', 'black', 'FontWeight', 'bold');

hold off;
