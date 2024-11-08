% IDs
subject_ids = {'P01','P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'};

fs = 100;  % Sample Frequency

% Subject
activity_times.P01 = {'Sit', 300; 'Stand', 610; 'Cycle1', 910; 'Cycle2', 1210; 'Run1', 1510; 'Run2', 1810; 'End', 2110};
activity_times.P02 = {'Sit', 5; 'Stand', 360; 'Cycle1', 1150; 'Cycle2', 1490; 'Run1', 1790; 'Run2', 2040; 'End', 2340};
activity_times.P03 = {'Sit', 20; 'Stand', 380; 'Cycle1', 1986; 'Cycle2', 2178; 'Run1', 2413; 'Run2', 2645; 'End', 2945};
activity_times.P04 = {'Sit', 1; 'Stand', 369; 'Cycle1', 693; 'Cycle2', 1013; 'Run1', 1301; 'Run2', 1631; 'End', 1931};
activity_times.P05 = {'Sit', 1; 'Stand', 294; 'Cycle1', 602; 'Cycle2', 902; 'Run1', 1281; 'Run2', 1551; 'End', 1851};
activity_times.P06 = {'Sit', 180; 'Stand', 486; 'Cycle1', 866; 'Cycle2', 1151; 'Run1', 1396; 'Run2', 1666; 'End', 1966};
activity_times.P07 = {'Sit', 1; 'Stand', 314; 'Cycle1', 744; 'Cycle2', 919; 'Run1', 1339; 'Run2', 1639; 'End', 1939};
activity_times.P08 = {'Sit', 1; 'Stand', 300; 'Cycle1', 629; 'Cycle2', 929; 'Run1', 1229; 'Run2', 1529; 'End', 1829};
activity_times.P09 = {'Sit', 1; 'Stand', 309; 'Cycle1', 678; 'Cycle2', 1080; 'Run1', 1380; 'Run2', 1680; 'End', 1980};
%activity_times.P010 = {'Sit', 1; 'Stand', 295; 'Cycle1', 4335; 'Cycle2', 4635; 'Run1', 4935; 'Run2', 5235; 'End', 5535};
activity_times.P11 = {'Sit', 1; 'Stand', 248; 'Cycle1', 673; 'Cycle2', 1018; 'Run1', 1308; 'Run2', 1668; 'End', 1968};
activity_times.P12 = {'Sit', 1; 'Stand', 305; 'Cycle1', 670; 'Cycle2', 1670; 'Run1', 2030; 'Run2', 2330; 'End', 2630};
activity_times.P13 = {'Sit', 1; 'Stand', 309; 'Cycle1', 669; 'Cycle2', 1019; 'Run1', 1319; 'Run2', 1609; 'End', 1909};
activity_times.P14 = {'Sit', 1; 'Stand', 320; 'Cycle1', 630; 'Cycle2', 1000; 'Run1', 1300; 'Run2', 1609; 'End', 1909};
activity_times.P15 = {'Sit', 1; 'Stand', 338; 'Cycle1', 758; 'Cycle2', 1058; 'Run1', 1498; 'Run2', 1938; 'End', 2238};
activity_times.P16 = {'Sit', 1; 'Stand', 345; 'Cycle1', 705; 'Cycle2', 1015; 'Run1', 1310; 'Run2', 2195; 'End', 2495};
activity_times.P17 = {'Sit', 1; 'Stand', 309; 'Cycle1', 664; 'Cycle2', 999; 'Run1', 1344; 'Run2', 1784; 'End', 2084};


% Band Pass Filter
low_cutoff = 0.5;    
high_cutoff = 20;    
[b, a] = butter(2, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');

% Metrics
accel_metrics = struct();

for s = 1:length(subject_ids)
    % ID 
    patient_id = subject_ids{s};
    activities = activity_times.(patient_id);

    %Load the ACC data
    filename = [patient_id '-imu-right.csv'];
    data = readmatrix(filename);
    
    % Time of X, Y and Z axis
    accel_x = data(:, 2);     
    accel_y = data(:, 3);     
    accel_z = data(:, 4);     

    % Time vector for plotting
    num_points = length(accel_x);
    time = (0:num_points-1) / fs;

    % Apply filter
    accel_x_filtered = filtfilt(b, a, accel_x);
    accel_y_filtered = filtfilt(b, a, accel_y);
    accel_z_filtered = filtfilt(b, a, accel_z);

    % Magnitude
    magnitude = sqrt(accel_x_filtered.^2 + accel_y_filtered.^2 + accel_z_filtered.^2);

    % Plot magnitude
    fig = figure('Visible', 'off');
    set(fig, 'Position', [100, 100, 1200, 800]);
    subplot(4, 1, 1);
    plot(time, accel_x_filtered);
    title(['Filtered Acceleration - X Axis - ' patient_id]);
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    subplot(4, 1, 2);
    plot(time, accel_y_filtered);
    title(['Filtered Acceleration - Y Axis - ' patient_id]);
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    subplot(4, 1, 3);
    plot(time, accel_z_filtered);
    title(['Filtered Acceleration - Z Axis - ' patient_id]);
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2))');

    subplot(4, 1, 4);
    plot(time, magnitude, 'k');
    title(['Magnitude of Acceleration - ' patient_id]);
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    % Vertical lines
    for a = 1:size(activities, 1)
        activity_name = activities{a, 1};
        start_time = activities{a, 2};
        xline(start_time, '--k', activity_name, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
    end
    
    % Save
    saveas(fig, sprintf('ACC_Activities_%s.jpg', patient_id));
    close(fig);

    % Activity
    for i = 1:size(activities, 1) - 1
        activity = activities{i, 1};
        start_time = activities{i, 2};
        end_time = activities{i + 1, 2} - 1;

        
        idx_start = round(start_time * fs) + 1;
        idx_end = round(end_time * fs);

        
        idx_end = min(idx_end, num_points);

        % Extract segments
        accel_x_segment = accel_x_filtered(idx_start:idx_end);
        accel_y_segment = accel_y_filtered(idx_start:idx_end);
        accel_z_segment = accel_z_filtered(idx_start:idx_end);
        
        % Calculate for each segment
        magnitude_segment = sqrt(accel_x_segment.^2 + accel_y_segment.^2 + accel_z_segment.^2);

        % Calculate for each activity 
        mean_magnitude = mean(magnitude_segment);

        % Storage the data
        accel_metrics.(patient_id).(activity).MeanMagnitude = mean_magnitude;

        
        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]);
        
        subplot(4, 1, 1);
        plot(time(idx_start:idx_end), accel_x_segment);
        title(['Filtered Acceleration - X Axis - ' activity ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Acceleration (m/s^2)');

        subplot(4, 1, 2);
        plot(time(idx_start:idx_end), accel_y_segment);
        title(['Filtered Acceleration - Y Axis - ' activity ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Acceleration (m/s^2)');

        subplot(4, 1, 3);
        plot(time(idx_start:idx_end), accel_z_segment);
        title(['Filtered Acceleration - Z Axis - ' activity ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Acceleration (m/s^2)');

        subplot(4, 1, 4);
        plot(time(idx_start:idx_end), magnitude_segment, 'k');
        xlabel('Time (s)');
        ylabel('Magnitude (m/s^2)');
        title(['Magnitude of Acceleration - ' activity ' - ' patient_id]);
        
        % Salvar
        saveas(fig, sprintf('ACC_Filtered_Mag_%s_%s.jpg', patient_id, activity));
        close(fig);
    
        % % FFT Test
        % n = length(accel_x_segment);
        % f = (0:n-1) * (fs/n);  
        % 
        % accel_x_fft = abs(fft(accel_x_segment)).^2 / n;
        % accel_y_fft = abs(fft(accel_y_segment)).^2 / n;
        % accel_z_fft = abs(fft(accel_z_segment)).^2 / n;
        % 
        % 
        % fig = figure('Visible', 'off');
        % set(fig, 'Position', [100, 100, 1200, 800]);
        % subplot(3, 1, 1);
        % plot(f(1:floor(n/2)), accel_x_fft(1:floor(n/2)));
        % title(['Frequency Spectrum - X Axis - ' activity ' - ' patient_id]);
        % xlabel('Frequency (Hz)');
        % ylabel('Power');
        % 
        % subplot(3, 1, 2);
        % plot(f(1:floor(n/2)), accel_y_fft(1:floor(n/2)));
        % title(['Frequency Spectrum - Y Axis - ' activity ' - ' patient_id]);
        % xlabel('Frequency (Hz)');
        % ylabel('Power');
        % 
        % subplot(3, 1, 3);
        % plot(f(1:floor(n/2)), accel_z_fft(1:floor(n/2)));
        % title(['Frequency Spectrum - Z Axis - ' activity ' - ' patient_id]);
        % xlabel('Frequency (Hz)');
        % ylabel('Power');
        % saveas(fig, sprintf('ACC_Spectrum_Mag_%s_%s.jpg', patient_id, activity));
        % close(fig);
        % 
        % 
        % fig = figure('Visible', 'off');
        % set(fig, 'Position', [100, 100, 1200, 800]);
        % spectrogram(magnitude_segment, hamming(128), 120, 128, fs, 'yaxis');
        % title(['Spectrogram of Acceleration Magnitude - ' activity ' - ' patient_id]);
        % colorbar;
        % saveas(fig, sprintf('ACC_Spectrogram_Mag_%s_%s.jpg', patient_id, activity));
        % close(fig);

    end
end

% Save the metrics
save('accel_all_metrics.mat', 'accel_metrics');
