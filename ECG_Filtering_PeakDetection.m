clc; clear; close all;

%% Parameters (Configurable)
RECORD = '100';              % MIT-BIH record number
CHANNEL = 1;                 % ECG channel (MLII is usually channel 1)
FILTER_LOW = 0.5;           % Low cutoff frequency (Hz)
FILTER_HIGH = 40;           % High cutoff frequency (Hz)
DETECTION_WINDOW = 0.150;   % Moving average window (seconds)
MIN_RR_INTERVAL = 0.25;     % Minimum R-R interval (seconds) - prevents double detection
THRESHOLD_FACTOR = 0.5;     % Threshold = mean + THRESHOLD_FACTOR*std
REFINE_WINDOW = 0.050;      % Local search window for R-peak refinement (seconds)

%% Error Checking and Data Loading
fprintf('=== ECG Signal Processing Pipeline ===\n');
fprintf('Loading MIT-BIH record: %s\n', RECORD);

% Check if files exist
if ~exist([RECORD '.dat'], 'file') || ~exist([RECORD '.hea'], 'file')
    error('MIT-BIH files not found. Please check file path and record number.');
end

try
    [ecg_mV, Fs, t, leadNames] = load_mitdb_212(RECORD);
    fprintf('✓ Data loaded successfully\n');
    fprintf('  Sampling rate: %d Hz\n', Fs);
    fprintf('  Duration: %.1f seconds\n', t(end));
    fprintf('  Channels: %d\n', size(ecg_mV, 2));
catch ME
    error('Failed to load ECG data: %s', ME.message);
end

% Validate channel selection
if CHANNEL > size(ecg_mV, 2)
    error('Channel %d not available. Available channels: 1-%d', CHANNEL, size(ecg_mV, 2));
end

%% Signal Selection and Preprocessing
x = ecg_mV(:, CHANNEL);
fprintf('✓ Selected channel %d: %s\n', CHANNEL, leadNames{CHANNEL});

% Design bandpass filter
[b, a] = butter(4, [FILTER_LOW FILTER_HIGH] / (Fs/2), 'bandpass');
x_f = filtfilt(b, a, x);
fprintf('✓ Applied bandpass filter: %.1f-%.1f Hz\n', FILTER_LOW, FILTER_HIGH);

%% R-Peak Detection (Pan-Tompkins Algorithm)
fprintf('✓ Running R-peak detection...\n');

% Step 1: Differentiation
y = diff(x_f);

% Step 2: Squaring
y2 = y.^2;

% Step 3: Moving average (detection envelope)
win = round(DETECTION_WINDOW * Fs);
env = movmean([0; y2], win);  % pad to align lengths

% Step 4: Adaptive thresholding
thr = mean(env) + THRESHOLD_FACTOR * std(env);
minDist = round(MIN_RR_INTERVAL * Fs);

% Step 5: Peak detection in envelope
[~, loc_env] = findpeaks(env, 'MinPeakHeight', thr, 'MinPeakDistance', minDist);

% Step 6: Refine R-peak locations (search for local maxima in filtered ECG)
search = round(REFINE_WINDOW * Fs);
loc_R = zeros(size(loc_env));
for k = 1:numel(loc_env)
    i1 = max(1, loc_env(k) - search);
    i2 = min(length(x_f), loc_env(k) + search);
    [~, rel] = max(x_f(i1:i2));
    loc_R(k) = i1 + rel - 1;
end
loc_R = unique(loc_R);
