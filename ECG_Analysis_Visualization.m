%% Visualization
% Figure 1: Raw vs Filtered ECG
figure('Name', 'ECG Signal Comparison', 'Position', [100 100 1200 600]);
subplot(2,1,1);
plot(t, x, 'Color', [0.3 0.3 0.9]);
grid on;
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title(sprintf('Raw ECG (Record %s), Fs = %d Hz, Lead: %s', RECORD, Fs, leadNames{CHANNEL}));

subplot(2,1,2);
plot(t, x_f, 'Color', [0 0.6 0]);
grid on;
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title(sprintf('Filtered ECG (%.1f–%.1f Hz)', FILTER_LOW, FILTER_HIGH));

% Figure 2: R-Peak Detection
figure('Name', 'R-Peak Detection Results', 'Position', [200 200 1200 500]);
plot(t, x_f, 'Color', [0 0.4 0.8], 'LineWidth', 0.8);
hold on;
plot(t(loc_R), x_f(loc_R), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red', 'LineWidth', 1.5);
grid on;
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title(sprintf('Detected R-peaks | Average HR = %.1f BPM | %d beats detected', avgBPM, numel(loc_R)));
legend('Filtered ECG', 'R-peaks', 'Location', 'best');

% Figure 3: Detection Envelope and Threshold
figure('Name', 'Detection Algorithm Visualization', 'Position', [300 300 1200 500]);
plot(t, env, 'Color', [0 0.6 0.9], 'LineWidth', 1.2);
hold on;
yline(thr, '--', 'Color', [0.8 0 0], 'LineWidth', 2);
plot(t(loc_env), env(loc_env), 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'green');
grid on;
xlabel('Time (s)');
ylabel('Detection Energy');
title('Pan-Tompkins Detection Envelope with Adaptive Threshold');
legend('Detection Envelope', 'Threshold', 'Detected Peaks', 'Location', 'best');

% Figure 4: Heart Rate Variability
if numel(HR_valid) > 1
    figure('Name', 'Heart Rate Analysis', 'Position', [400 400 1200 400]);
    
    subplot(1,2,1);
    t_RR = t(loc_R(2:end));  % Time points for R-R intervals
    plot(t_RR, HR_valid, 'b-o', 'LineWidth', 1, 'MarkerSize', 4);
    grid on;
    xlabel('Time (s)');
    ylabel('Heart Rate (BPM)');
    title('Instantaneous Heart Rate');
    ylim([max(30, minBPM-10), min(200, maxBPM+10)]);
    
    subplot(1,2,2);
    histogram(HR_valid, 20, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'black');
    grid on;
    xlabel('Heart Rate (BPM)');
    ylabel('Frequency');
    title('Heart Rate Distribution');
    xline(avgBPM, '--r', 'LineWidth', 2, 'Label', sprintf('Mean: %.1f', avgBPM));
end

fprintf('\n✓ Processing complete! All figures generated.\n');
