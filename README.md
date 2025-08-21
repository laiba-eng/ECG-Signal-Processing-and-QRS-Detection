  # ECG-Signal-Processing-and-QRS-Detection
This project focuses on ECG (Electrocardiogram) signal processing using the MIT-BIH Arrhythmia Database. The main objective is to detect QRS complexes and R-peaks from ECG signals, which are critical for heart rate and arrhythmia analysis.

# Key Features
- Reads MIT-BIH Arrhythmia Database ECG records (.hea, .dat) without requiring external WFDB toolbox.
- Preprocessing pipeline: Bandpass filter (0.5–40 Hz) to remove baseline wander and high-frequency noise.
- R-Peak Detection: Implements a Pan–Tompkins–style algorithm with adaptive thresholding and local refinement.
- Heart Rate Analysis: Calculates R–R intervals, instantaneous heart rate (BPM), and statistical measures (mean, range, variability).

 ## Visualization Dashboard:
- Raw vs. filtered ECG comparison
- Detected R-peaks overlay
- Detection envelope with adaptive threshold
- Heart rate variability trend & histogram distribution

## Error handling for missing files, incorrect channel selection, and irregular data formats.

# Dataset

Source: MIT-BIH Arrhythmia Database

Files used: .hea (header) and .dat (ECG signal)

Example record: 100.hea, 100.dat

# Algorithm

ECG preprocessing (filtering & normalization)

Pan–Tompkins algorithm for QRS detection

Bandpass filtering

Derivative-based slope detection

Squaring & moving window integration

Thresholding for R-peak identification

# Results
<img width="600" height="400" alt="ECG SIGNAL COMPARISION" src="https://github.com/user-attachments/assets/32b0de2a-ffd9-4b41-bddc-8fc68d176fc2" />ECG SIGNAL COMPARISION
