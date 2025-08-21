%% Heart Rate Analysis
RR = diff(loc_R) / Fs;  % R-R intervals in seconds
HR = 60 ./ RR;          % Instantaneous heart rate in BPM

% Remove invalid heart rates
HR_valid = HR(~isnan(HR) & isfinite(HR) & HR > 30 & HR < 200);

% Calculate statistics
avgBPM = mean(HR_valid);
minBPM = min(HR_valid);
maxBPM = max(HR_valid);
stdBPM = std(HR_valid);

%% Results Display
fprintf('\n=== ECG Analysis Results ===\n');
fprintf('Record: %s, Lead: %s\n', RECORD, leadNames{CHANNEL});
fprintf('Signal duration: %.1f seconds\n', t(end));
fprintf('Detected R-peaks: %d\n', numel(loc_R));
fprintf('Average heart rate: %.1f ± %.1f BPM\n', avgBPM, stdBPM);
fprintf('Heart rate range: %.1f - %.1f BPM\n', minBPM, maxBPM);
fprintf('Detection rate: %.1f beats/minute\n', numel(loc_R) / (t(end)/60));
