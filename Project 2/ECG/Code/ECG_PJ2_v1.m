%Subjects - ECG Analysis
subject_ids = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'};

%subject_ids = {'P01'}';

%Frequency and filter
fs = 250;
[b, a] = butter(2, ([0.5 100] / (fs / 2)));

% RR
[b_rr, a_rr] = butter(2, 0.3 / (fs / 2), 'low');  % LPF 0.3 Hz to RR

%For RR
max_segment_duration_minutes = 4;

% Storage the HRV data
ECG_all_HRV_metrics = struct();

for s = 1:length(subject_ids)
    %ID
    patient_id = subject_ids{s};

    % Activities times for each subject
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


    atividades = activity_times.(patient_id);

    % Load the file for each
    filename = [patient_id '_ECG.csv'];
    dados = readtable(filename);

    %ECG signal
    ecg = dados{:, 'EcgWaveform'};  
    num_pontos = length(ecg);
    tempo = (0:num_pontos-1) / fs;
    
    % HRV metrics
    ECG_HRV_metrics = struct();

    ECG_fil = filtfilt(b, a, ecg);
    figure;
    set(gcf, 'Position', [100, 100, 1200, 800]);
    plot(tempo, ECG_fil, 'r', 'DisplayName', 'Filtered ECG');  % Filtered ecg
    hold on;
    xlabel('Time (s)');
    ylabel('Amplitude (mV)');
    title(['ECG Filtered with Activities - ' patient_id]);
    legend('show');

   
    % Lines for each activity
    for i = 1:size(atividades, 1)
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        xline(inicio, '--k', atividade, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
    end
    % Save
    saveas(gcf, sprintf('ECG_Filtered_with_Activities_%s.jpg', patient_id));

    
        % Segments
    for i = 1:size(atividades, 1) - 1
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        fim = atividades{i+1, 2} - 1;

        
        idx_inicio = round(inicio * fs) + 1;
        idx_fim = round(fim * fs);

      
        segmento = ecg(idx_inicio:idx_fim);
        sample1_ECG_filtered = filtfilt(b, a, segmento);

        % Hilbert
        analytic_signal_ECG1 = hilbert(sample1_ECG_filtered);
        upper_envelope_ECG1 = abs(analytic_signal_ECG1);

        % Low and Upper Envelope
        analytic_envelope_ECG1 = hilbert(upper_envelope_ECG1);
        lower_envelope_ECG1 = abs(analytic_envelope_ECG1);

        max_amplitude = max(upper_envelope_ECG1);
        min_amplitude = min(upper_envelope_ECG1);


        % threshould
        threshold_value = 0.35 * max_amplitude;
        filtered_signal = upper_envelope_ECG1;
        filtered_signal(filtered_signal < threshold_value) = 0;

        % Peaks
        [~, locs_ECG1] = findpeaks(filtered_signal, 'MinPeakDistance', fs * 0.6);

        % HRV
        Beat_times = locs_ECG1(:) / fs;  
        NN_intervals = diff(Beat_times);  
        meanNN = mean(NN_intervals);
        SDNN = std(NN_intervals);
        RMSSD = rms(diff(NN_intervals));
        NN50count = sum(abs(diff(NN_intervals)) > 0.050);
        pNN50 = NN50count / length(NN_intervals);

        % BPM
        end_time_RR = min(inicio + max_segment_duration_minutes * 60, atividades{i+1, 2} - 1);
        segment_duration_minutes = min((end_time_RR - inicio) / 60, max_segment_duration_minutes);
        %segment_duration_minutes = (inicio - fim) / 60;  
        BPM = numel(locs_ECG1) / segment_duration_minutes;

        % RR
        baseline_resp = filtfilt(b_rr, a_rr, segmento);  
        [~, locs_resp] = findpeaks(baseline_resp, 'MinPeakDistance', fs * 2);  
        RR = numel(locs_resp) / segment_duration_minutes;  

        % HRV
        ECG_HRV_metrics.(atividade).meanNN = meanNN;
        ECG_HRV_metrics.(atividade).SDNN = SDNN;
        ECG_HRV_metrics.(atividade).RMSSD = RMSSD;
        ECG_HRV_metrics.(atividade).NN50count = NN50count;
        ECG_HRV_metrics.(atividade).pNN50 = pNN50;
        ECG_HRV_metrics.(atividade).BPM = BPM;
        ECG_HRV_metrics.(atividade).RR = RR;

        % Plot
        figure;
        set(gcf, 'Position', [100, 100, 1200, 800]);
        tempo_segmento = (0:length(sample1_ECG_filtered)-1) / fs;

        subplot(3, 1, 1);
        plot(tempo_segmento, sample1_ECG_filtered, 'b');
        title(['Filtered ECG Signal - ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Amplitude (mV)');

        subplot(3, 1, 2);
        plot(tempo_segmento, upper_envelope_ECG1, 'r', 'LineWidth', 1.5);
        title(['Upper Hilbert Envelope - ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Amplitude');

        subplot(3, 1, 3);
        plot(tempo_segmento, lower_envelope_ECG1, 'k--', 'LineWidth', 1.5);
        hold on;
        plot(tempo_segmento(locs_ECG1), lower_envelope_ECG1(locs_ECG1), 'go', 'MarkerSize', 6);  % Marcar picos detectados
        title(['Lower Envelope with Detected Peaks - ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Amplitude');
        hold off;
        
        %Save
        saveas(gcf, sprintf('Hilbert_Envelope_And_Peaks_%s_%s.jpg', patient_id, atividade));


        % Pan-Tompikins
        figure;
        set(gcf, 'Position', [100, 100, 1200, 800]);
        set(gcf, 'Position', [100, 100, 1200, 800]);
        [qrs_amp_raw, qrs_i_raw, delay] = pan_tompkin(sample1_ECG_filtered, fs, 1);
        %Save
        saveas(gcf, sprintf('Pan_Tompkins_%s_%s.jpg', patient_id, atividade));

        % Plot
        figure;
        set(gcf, 'Position', [100, 100, 1200, 800]);
        tempo_segmento = (0:length(sample1_ECG_filtered)-1) / fs;
        plot(tempo_segmento, sample1_ECG_filtered, 'b');
        hold on;
        plot(tempo_segmento(qrs_i_raw), sample1_ECG_filtered(qrs_i_raw), 'ro');
        title(['ECG with QRS Detection - ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Amplitude (mV)');
        legend('Filtered ECG', 'Detected QRS Complexes');
        hold off;
        %Save
        saveas(gcf, sprintf('QRS_Detection_%s_%s.jpg', patient_id, atividade));

    end

    % Metrics of HRV
    ECG_all_HRV_metrics.(patient_id) = ECG_HRV_metrics;

end

% Save
save('ECG_all_ECG_HRV_metrics.mat', 'all_HRV_metrics');