% Subjects
subject_ids = {'P01', 'P02','P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'};

% Sample frequency
fs = 4;

for s = 1:length(subject_ids)
    % ID
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

    % EDA File
    filename = [patient_id '_EDA.csv'];
    opts = detectImportOptions(filename);
    opts.DataLines = [3 Inf];  
    opts.SelectedVariableNames = opts.VariableNames(1); 
    dados = readtable(filename, opts);

    % Numeric vector
    EDA = table2array(dados);
    num_pontos = length(EDA);
    time = (0:num_pontos-1) / fs;

    % Mean Filter
    EDAmf = medfilt1(EDA, fs);

    % Low-Pass Filter
    bhi = fir1(34, 1/(fs/2));
    EDAfir = filtfilt(bhi, 1, EDAmf);
    fig = figure('Visible', 'off');
    set(fig, 'Position', [100, 100, 1200, 800]); 
    plot(time, EDAmf, 'b'); hold on; 
    plot(time, EDAfir, 'k');
    xlabel('Time (s)');
    ylabel('Conductance (\muS)');
    title(['Median Filtered and Low-Pass Filtered EDA - ' patient_id]);
    legend('Median Filtered EDA', 'Low-Pass Filtered EDA');
    
    % Vertical lines
    for i = 1:size(atividades, 1)
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        xline(inicio, '--k', atividade, 'LabelVerticalAlignment', 'middle', 'HandleVisibility', 'off');
    end

    saveas(fig, sprintf('EDA_Activities_%s.jpg', patient_id));
    close(fig);

    % Each activity 
    for i = 1:size(atividades, 1) - 1
        atividade = atividades{i, 1};
        inicio = atividades{i, 2};
        fim = atividades{i + 1, 2} - 1; 

        % Segment
        idx_inicio = round(inicio * fs) + 1;
        idx_fim = round(fim * fs);

        % Extract segment
        EDA_segment = EDAfir(idx_inicio:idx_fim);
        Raw_EDA_segment = EDA(idx_inicio:idx_fim);
        time_segment = (0:length(EDA_segment) - 1) / fs;
        
        num_pontos_1 = length(EDA_segment);

        % Tonic (SCL) and Phasic (NS.SCRs) components 
        B_tonpha = fir1(60, 0.0004/(fs/2));
        EDAton = filtfilt(B_tonpha, 1, EDA_segment);  % SCL
        EDApha = EDA_segment - EDAton;                % NS.SCRs
    
        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]); 
        plot(time_segment, EDA_segment, 'k'); hold on;
        plot(time_segment, EDAton, 'b', 'LineWidth', 1.5); % SCL 
        plot(time_segment, EDApha, 'r', 'LineWidth', 1.5); % NS.SCRs 
        xlabel('Time (s)');
        ylabel('Conductance (\muS)');
        title(['SCL and NS.SCRs - ' atividade ' - ' patient_id]);
        legend('Filtered EDA', 'SCL (Tonic)', 'NS.SCRs (Phasic)');
        hold off;
        saveas(fig, sprintf('EDA_SLCandNS_%s_%s.jpg', patient_id, atividade));
        close(fig);

        % Mean SCL
        SCL = mean(EDAton);

        % Limits and NS.SCRs
        threshold = 0.05;  % µS
        ns_scrs_count = sum(EDApha > threshold);
        ns_scrs_per_min = ns_scrs_count / (num_pontos_1 / fs / 60); %Response for minutes

        % Plots SCL and NS.SCRs
        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]); 

        % Raw EDA and SCL
        subplot(2, 1, 1);
        plot(time_segment, EDA_segment, 'r'); hold on;
        plot(time_segment, EDAton, 'b', 'LineWidth', 1.5);
        xlabel('Time (s)');
        ylabel('Conductance (\muS)');
        title(['EDA - '  atividade ' - ' patient_id]);
        legend('Raw EDA', 'Tonic EDA');
        text(0.05 * max(time_segment), 0.95 * max(EDAton), ['SCL = ' num2str(SCL, '%.4f') ' \muS'], 'FontSize', 10, 'Color', 'blue', 'FontWeight', 'bold');
        hold off;

        % NS.SCRs 
        subplot(2, 1, 2);
        plot(time_segment, EDApha, 'k'); hold on;
        yline(threshold, 'm--', 'Threshold (0.05 \muS)', 'LineWidth', 1);
        xlabel('Time (s)');
        ylabel('Conductance (\muS)');
        legend('NS.SCRs', 'Threshold');
        text(0.05 * max(time_segment), 0.8 * max(EDApha), ['NS.SCRs = ' num2str(ns_scrs_per_min, '%.2f') ' resp./min'], 'FontSize', 10, 'Color', 'black', 'FontWeight', 'bold');
        hold off;
        saveas(fig, sprintf('EDA_NSandSCL_%s_%s.jpg', patient_id, atividade));
        close(fig);

        % sparsEDA
        epsilon = 1e-4;
        Kmax = 40;
        dmin = 1.25*fs;
        rho = 0.025;
        graphics = 0; % Valores do artigo
        [driver, tonicSparse, MSE] = sparsEDA(zscore(EDA_segment), fs, graphics, epsilon, Kmax, dmin, rho);
        tonicSparse = tonicSparse(2:end)*std(Raw_EDA_segment) + mean(EDA_segment);
        phasicSparse = (EDA_segment' - tonicSparse) * std(Raw_EDA_segment);
        driver = driver(2:end);

        % Tonic and Phasic sparsEDA
        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]); 
        plot(time_segment, EDA_segment, 'k'); hold on;
        plot(time_segment, tonicSparse, 'b', 'LineWidth', 1.5);
        plot(time_segment, phasicSparse, 'r', 'LineWidth', 1.5);
        xlabel('Time (s)');
        ylabel('Conductance (\muS)');
        title(['Tonic and Phasic Components from sparsEDA - '   atividade ' - ' patient_id]);
        legend('Filtered EDA', 'Tonic Component', 'Phasic Component');
        hold off;
        saveas(fig, sprintf('EDA_TonicandFasic_%s_%s.jpg', patient_id, atividade));
        close(fig);


        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]); 
        plot(time_segment, driver, 'm');
        xlabel('Time (s)');
        ylabel('Driver Signal');
        title(['Driver Signal from sparsEDA - '  atividade ' - ' patient_id]);
        legend('Driver Signal');
        hold off;
        saveas(fig, sprintf('EDA_SparsEDA_%s_%s.jpg', patient_id, atividade));
        close(fig);


        fig = figure('Visible', 'off');
        set(fig, 'Position', [100, 100, 1200, 800]); 
        yyaxis left
        plot(time_segment, phasicSparse, 'k');
        ylabel('Phasic Component (\muS)');
        yyaxis right
        stem(time_segment, driver, 'm');
        xlabel('Time (s)');
        ylabel('Driver Signal');
        title(['Phasic Component and Driver Signal - '  atividade ' - ' patient_id]);
        legend('Phasic Component', 'Driver Signal');
        hold off;
        saveas(fig, sprintf('EDA_phasicSparse_%s_%s.jpg', patient_id, atividade));
        close(fig);

        % Storage SCL, NS.SCRs and drivers 
        EDA_metrics.(patient_id).(atividade).SCL = SCL;
        EDA_metrics.(patient_id).(atividade).NS_SCRs = ns_scrs_per_min;
        EDA_metrics.(patient_id).(atividade).Drivers = driver;

    end
end

save('EDA_all_metrics.mat', 'EDA_metrics');