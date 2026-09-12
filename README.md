# Neurophysiology Signal Analysis Toolkit

MATLAB coursework repository containing seven experiment scripts and shared signal-processing functions for recorded neurophysiology data. The shared functions cover threshold-based spike detection, spike-waveform extraction, RMS/SNR calculation, event-file parsing, trial alignment, PSTH binning, raster plotting, and FFT-based periodograms.

## Analyses

- **Electrode configuration:** compares recordings indexed by electrode spacing and electrode size using spike rate, waveforms, peak-to-peak amplitude, and SNR.
- **Sensory-evoked response:** detects spikes, reads stimulus event logs, aligns spikes to stimulus onset/offset, and plots rasters, PSTHs, response measures, peak firing rate, and time to peak across stimulus positions.
- **Muscle stimulation and EMG:** aligns force recordings to stimulation events, measures twitch amplitude/timing metrics versus stimulation amplitude and frequency, and compares EMG features with grip-force levels.

## Repository layout

```text
src/core/                         shared MATLAB functions
src/01_electrode_configuration/  electrode spacing and size/SNR scripts
src/02_sensory_evoked_response/  tactile-response scripts
src/03_muscle_emg_analysis/      twitch and EMG/force scripts
data/                             WAV recordings and event logs
```

## Requirements and how to run

The scripts are written for MATLAB and call functions including `audioread`, `rms`, and `regress`. They expect `.wav` recordings and, for event-aligned analyses, matching `-events.txt` files.

1. Open the experiment script you want to run under `src/`.
2. Update its `dataDir` assignment to the matching `data/<experiment>/` directory. The checked-in scripts currently contain absolute Windows paths from the original analysis environment.
3. Add `src/core` to the MATLAB path, then run the script section by section or as a whole. The scripts generate figures in the MATLAB session; they do not write a results report.

## Limitations

This is coursework analysis code, not a packaged toolbox or automated test suite. Several files retain course-template comments and `FILLIN` markers. The repository contains recorded data, and the scripts are configured for the included file naming conventions. No experimental results are reported here.

## Credits

- Repository author and visible Git committer: Sparsh Dadhich (`sdadhich04`).
- The MATLAB file headers credit A. L. Orsborn for the lab templates and source functions.
- The initial repository commit describes the work as BIOEN/ECE 466 labs 1–3.
