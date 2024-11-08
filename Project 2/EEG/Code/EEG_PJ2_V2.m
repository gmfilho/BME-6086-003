% Subject IDs 
subject_ids = {'P01', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'};
%subject_ids = {'P01', 'P03'};  
fs = 256;  % Sampling frequency 

% Define activity times 
activity_times.P01 = {'Sit', 300; 'Stand', 610; 'Cycle1', 910; 'Cycle2', 1210; 'Run1', 1510; 'Run2', 1810; 'End', 2110};
%activity_times.P02 = {'Sit', 5; 'Stand', 360; 'Cycle1', 1150; 'Cycle2', 1490; 'Run1', 1790; 'Run2', 2040; 'End', 2340};
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


% Frequency bands
delta_band = [0.5 4];
theta_band = [4 8];
alpha_band = [8 13];
beta_band = [13 30];
gamma_band = [30 50];

for s = 1:length(subject_ids)
    % Subject ID 
    patient_id = subject_ids{s};
    activities = activity_times.(patient_id);
    
    % Load EEG file
    filename = [patient_id '_eeg.csv'];
    data = readmatrix(filename);
    

    TP9 = data(:, 2); 
    AF7 = data(:, 3); 
    AF8 = data(:, 4); 
    TP10 = data(:, 6); 

    % Interpolation of NaNs
    time_indices = (1:length(TP9))';  
    
    TP9 = interp1(time_indices(~isnan(TP9)), TP9(~isnan(TP9)), time_indices, 'spline');
    AF7 = interp1(time_indices(~isnan(AF7)), AF7(~isnan(AF7)), time_indices, 'spline');
    AF8 = interp1(time_indices(~isnan(AF8)), AF8(~isnan(AF8)), time_indices, 'spline');
    TP10 = interp1(time_indices(~isnan(TP10)), TP10(~isnan(TP10)), time_indices, 'spline');

   
    [b_high, a_high] = butter(2, 1 / (fs / 2), 'high'); % High-pass filter
    [b_low, a_low] = butter(2, 50 / (fs / 2), 'low');   % Low-pass filter

    % Filters
    eeg_data = [filtfilt(b_low, a_low, filtfilt(b_high, a_high, TP9)), ...
                filtfilt(b_low, a_low, filtfilt(b_high, a_high, AF7)), ...
                filtfilt(b_low, a_low, filtfilt(b_high, a_high, AF8)), ...
                filtfilt(b_low, a_low, filtfilt(b_high, a_high, TP10))]';

    % Apply ICA
    [ica_weights, ica_sphere] = runica(eeg_data);
    ica_signals = ica_weights * ica_sphere * eeg_data;

    % Time vector 
    num_points = size(ica_signals, 2);
    time = (0:num_points-1) / fs;

    % Plot each ICA component
    fig = figure('Visible', 'off');
    set(fig, 'Position', [100, 100, 1200, 800]);
    for j = 1:size(ica_signals, 1)
        subplot(size(ica_signals, 1), 1, j);
        plot(time, ica_signals(j, :), 'b');
        hold on;

        % Adding vertical lines
        for i = 1:size(activities, 1)
            activity = activities{i, 1};
            start_time = activities{i, 2};
            xline(start_time, '--k', activity, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
        end
        
        xlabel('Time (s)');
        ylabel('Amplitude');
        title(['ICA Component ' num2str(j) ' - ' patient_id]);
        

    end
    %save
    saveas(fig, sprintf('EEG_ICA_With_Activities_%s.jpg', patient_id));
    close(fig);

    % Analysis by activity
    for i = 1:size(activities, 1) - 1
        activity = activities{i, 1};
        start_time = activities{i, 2};
        end_time = activities{i + 1, 2} - 1;

        % Segment
        idx_start = round(start_time * fs) + 1;
        idx_end = round(end_time * fs);

        % Ensure idx_end does not exceed the available data length 
        idx_end = min(idx_end, size(ica_signals, 2));

        ica_segment = ica_signals(:, idx_start:idx_end);
        n = size(ica_segment, 2);
        f = (0:n-1) * (fs/n);

        % Initialize variables
        band_powers = zeros(size(ica_signals, 1), 5);

        % Calculate mean power in each frequency band
        for j = 1:size(ica_signals, 1)
            fft_data = fft(ica_segment(j, :));
            band_powers(j, 1) = band_power(fft_data, f, delta_band);
            band_powers(j, 2) = band_power(fft_data, f, theta_band);
            band_powers(j, 3) = band_power(fft_data, f, alpha_band);
            band_powers(j, 4) = band_power(fft_data, f, beta_band);
            band_powers(j, 5) = band_power(fft_data, f, gamma_band);

            % spectrogram 
            fig = figure('Visible', 'off');
            set(fig, 'Position', [100, 100, 1200, 800]);
            subplot(2, 1, 1);
            spectrogram(ica_segment(j, :), hamming(128), 120, 128, fs, 'yaxis');
            title(['Spectrogram - ICA Component ' num2str(j) ' - ' activity ' - ' patient_id]);
            colorbar;
            %Save
            
            
            % Plot bar 
            subplot(2, 1, 2);
            bar(band_powers(j, :));
            title(['Mean Power in Frequency Bands - ' activity ' - ICA Component ' num2str(j) ' - ' patient_id]);
            xticks(1:5);
            xticklabels({'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'});
            ylabel('Power');
            grid on;
            %Save
            saveas(fig, sprintf('EEG_FFT_ICA_%s_%s_Component%d.jpg', patient_id, activity, j));
            close(fig);  
        end
        
        
        % Store power
        EEG_metrics.(patient_id).(activity).BandPowers = band_powers;
    end
end

% Save metrics 
save('EEG_all_metrics.mat', 'EEG_metrics');

% Function to calculate mean power in a frequency band
function power_avg = band_power(fft_data, f, band)
    band_indices = (f >= band(1)) & (f <= band(2));
    power_avg = mean(abs(fft_data(band_indices)).^2);
end
