
%Subjects - PPG Analysis
subject_ids = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'};

%Frequency and filter
fs = 64;
[b, a] = butter(4, ([0.4 4] / (fs / 2)));

% Storage the HRV data
all_HRV_metrics = struct();

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
    filename = [patient_id '-ppg-right.csv'];
    dados = readtable(filename);

    %PPG signal
    ppg_red = dados{:, 'ir'};  
    num_pontos = length(ppg_red);
    tempo = (0:num_pontos-1) / fs;
    % HRV metrics
    HRV_metrics = struct();

    % Plot with activities
    PPG_fil = filtfilt(b, a, ppg_red);
    figure;
    set(gcf, 'Position', [100, 100, 1200, 800]);
    plot(tempo, PPG_fil, 'r', 'DisplayName', 'Filtered PPG');  % Filtered ppg
    hold on;
    plot(tempo, ppg_red, 'b', 'DisplayName', 'Raw PPG');  % Raw
    xlabel('Time (s)');
    ylabel('PPG Amplitude');
    title(['PPG Filtered with Activities - ' patient_id]);
    legend('show');
    

    % Lines for each activity
    for i = 1:size(atividades, 1)
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        xline(inicio, '--k', atividade, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
    end
    
    % Save
    saveas(gcf, sprintf('PPG_Filtered_with_Activities_%s.jpg', patient_id));
    
    for i = 1:size(atividades, 1) - 1
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        fim = atividades{i+1, 2} - 1;

        % Segment
        idx_inicio = round(inicio * fs) + 1;
        idx_fim = round(fim * fs);

        % Extract and filter each
        segmento = ppg_red(idx_inicio:idx_fim);
        PPG_filtered = filtfilt(b, a, segmento);

        % Calculate the derivates
        PPG_fd = zeros(1, length(PPG_filtered));
        PPG_sd = zeros(1, length(PPG_filtered));
        for r = 3 : length(PPG_filtered)-2
            PPG_fd(r) = (-PPG_filtered(r + 2) + 8*PPG_filtered(r + 1) - 8*PPG_filtered(r - 1) + PPG_filtered(r - 2));	
            PPG_sd(r) = (-PPG_filtered(r + 2) + 16*PPG_filtered(r + 1) - 30*PPG_filtered(r) + 16*PPG_filtered(r - 1) - PPG_filtered(r - 2));
        end

        % Plot
        figure;
        set(gcf, 'Position', [100, 100, 1200, 800]);
        tempo_segmento = (0:length(PPG_filtered)-1) / fs;
        subplot(3,1,1);
        plot(tempo_segmento, PPG_filtered, 'b');
        title(['Filtered Segment: ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('PPG Amplitude');
        
        subplot(3,1,2);
        plot(tempo_segmento, PPG_fd, 'r');
        title('First-derivative of PPG');
        
        subplot(3,1,3);
        plot(tempo_segmento, PPG_sd, 'r');
        title('Second-derivative of PPG');
        
        linkaxes(findall(gcf,'Type','axes'),'x');

        % Save the plot of filtered segment and derivatives
        saveas(gcf, sprintf('Filtered_Segment_and_Derivatives_%s_%s.jpg', patient_id, atividade));

        % Análise de envelope de Hilbert
        analytic_signal = hilbert(PPG_filtered);
        upper_envelope = abs(analytic_signal);
        analytic_envelope = hilbert(upper_envelope);
        lower_envelope = abs(analytic_envelope);
        threshold_value = 0.5;
        filtered_signal = upper_envelope;
        filtered_signal(filtered_signal < threshold_value) = 0;

        % Detectar picos (batimentos)
        [~, locs] = findpeaks(filtered_signal, 'MinPeakDistance', fs * 0.6);

        % Calcular as métricas HRV
        Beat_times = locs(:) / fs;
        NN_intervals = diff(Beat_times);
        meanNN = mean(NN_intervals);
        SDNN = std(NN_intervals);
        RMSSD = rms(diff(NN_intervals));
        NN50count = sum(abs(diff(NN_intervals)) > 0.050);
        pNN50 = NN50count / length(NN_intervals);

        % Armazenar métricas HRV para o segmento atual
        HRV_metrics.(atividade).meanNN = meanNN;
        HRV_metrics.(atividade).SDNN = SDNN;
        HRV_metrics.(atividade).RMSSD = RMSSD;
        HRV_metrics.(atividade).NN50count = NN50count;
        HRV_metrics.(atividade).pNN50 = pNN50;

        % Plot do envelope e picos detectados
        figure;
        set(gcf, 'Position', [100, 100, 1200, 800]);
        subplot(3, 1, 1);
        plot(tempo_segmento, PPG_filtered, 'b');
        title(['Filtered PPG Signal - ' atividade ' - ' patient_id]);
        xlabel('Time (s)');
        ylabel('Amplitude');

        subplot(3, 1, 2);
        plot(tempo_segmento, PPG_filtered, 'b'); hold on;
        plot(tempo_segmento, upper_envelope, 'r', 'LineWidth', 1.5);
        title(['Filtered PPG with Upper Envelope - ' atividade ' - ' patient_id]);
        
        subplot(3, 1, 3);
        plot(tempo_segmento, PPG_filtered, 'b'); hold on;
        plot(tempo_segmento, lower_envelope, 'r--', 'LineWidth', 1.5);
        plot(tempo_segmento(locs), lower_envelope(locs), 'go', 'MarkerSize', 6);
        title(['Filtered PPG with Lower Envelope and Detected Peaks - ' atividade ' - ' patient_id]);

        % Save the plot of filtered PPG with envelopes and detected peaks
        saveas(gcf, sprintf('PPG_With_Envelope_and_Peaks_%s_%s.jpg', patient_id, atividade));
    end

    % Storage the data
    all_HRV_metrics.(patient_id) = HRV_metrics;
end

% Salvar todas as métricas HRV em um arquivo .mat
save('all_HRV_metrics.mat', 'all_HRV_metrics');