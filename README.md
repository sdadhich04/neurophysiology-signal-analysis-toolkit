# Neurophysiology Signal Analysis Toolkit

A MATLAB pipeline for detecting, trial-aligning, and characterizing bioelectric
signals across three linked electrophysiology experiments: how measurement
setup shapes recorded neural signals, how a sensory nerve encodes touch, and
how peripheral nerve stimulation and voluntary effort relate to muscle force
output. The three experiments share one underlying signal-processing core
(threshold-based event detection, trial alignment, PSTH construction, and
spectral analysis), applied first to extracellular nerve recordings and then
to continuous force/EMG signals.

Built from coursework for **BIOEN/ECE 466/564/566 (Neural Computation and
Engineering Laboratory)**, University of Washington, Winter 2026 (Prof. Amy
Orsborn). See [Provenance](#provenance--attribution) below for exactly what
was course-provided vs. completed here.

## Why these three experiments belong together

Each experiment answers a different question about how to get a clean,
interpretable signal out of a nervous system and turn it into a measurement:

1. **Does *how* you measure change *what* you measure?** (electrode
   referencing and electrode size)
2. **Given a clean measurement, what does the signal actually encode?**
   (a sensory nerve's response to touch)
3. **Can you close the loop — drive the periphery and read it back?**
   (evoking a muscle contraction with nerve stimulation, and relating
   voluntary EMG to force output)

The same core functions (spike/event detection → trial alignment → binning /
spectral analysis) get reused across all three, just applied to different
signal types (discrete spike times, continuous force, continuous EMG).

## Repository structure

```
src/
  core/                          shared signal-processing primitives
  01_electrode_configuration/    Experiment 1: referencing & electrode size
  02_sensory_evoked_response/    Experiment 2: tactile stimulus encoding
  03_muscle_emg_analysis/        Experiment 3: nerve-evoked twitch + EMG-force
data/
  01_electrode_configuration/    raw recordings for experiment 1
  02_sensory_evoked_response/    raw recordings + event logs for experiment 2
  03_muscle_emg_analysis/        raw recordings + event logs for experiment 3
```

## Experiment 1 — Electrode configuration (`src/01_electrode_configuration`)

**Prep:** extracellular recording from a cockroach leg nerve (Backyard Brains
SpikeRecorder / Spikerbox Pro), electrodes placed in the femur and tibia.

- `analysis_electrode_spacing.m` — varies the distance between the recording
  and reference electrode (0, 3, 6, 9 mm) and quantifies how spike rate,
  waveform shape, and peak-to-peak amplitude change as the reference moves
  away from the recording site (referencing theory: a reference placed too
  close to the recording electrode cancels the signal it's meant to measure;
  too far and it picks up unrelated noise).
- `analysis_electrode_size_and_snr.m` — repeats the analysis for three
  electrode sizes (pin gauges 000/00/0) and additionally computes
  signal-to-noise ratio (`computeSNR.m`) for each, since electrode size
  changes both the amplitude of what's picked up and the noise floor.

## Experiment 2 — Sensory-evoked response (`src/02_sensory_evoked_response`)

**Prep:** same cockroach leg nerve preparation, now with a tactile probe
(e.g. a toothpick on a manipulator) delivering a controlled touch stimulus,
and a Backyard Brains event marker logging stimulus on/off times.

- `analysis_tactile_stimulus_response.m` — trial-aligns spikes to stimulus
  onset, builds a raster plot and PSTH (peristimulus time histogram), and
  quantifies the evoked response magnitude (post-stimulus firing rate minus
  baseline) across 5 stimulus positions along the leg.
- `analysis_response_dynamics_and_latency.m` — trial-aligns to both
  stimulus onset and offset, and quantifies response *dynamics*: peak firing
  rate and time-to-peak (latency) as a function of stimulus position.

## Experiment 3 — Muscle stimulation & EMG (`src/03_muscle_emg_analysis`)

**Prep:** human forearm. A TENS unit delivers peripheral nerve stimulation
through self-adhesive electrodes to evoke an involuntary muscle twitch,
recorded via a force-sensitive-resistor circuit; separately, surface EMG
electrodes record muscle activity during voluntary grip contractions at a
measured grip force.

- `analysis_twitch_force_vs_stim_amplitude.m` — sweeps TENS stimulation
  amplitude (3.25–7 a.u.) and quantifies four twitch metrics per trial:
  latent period, contraction time, relaxation time, and contraction
  amplitude, trial-averaged with standard error.
- `analysis_twitch_force_vs_stim_frequency.m` — sweeps stimulation
  frequency (2–20 Hz) and quantifies twitch amplitude and absolute force
  amplitude as a function of frequency.
- `analysis_emg_vs_grip_force.m` — for three voluntary grip-force levels
  (5, 30, 60 N), computes mean rectified EMG amplitude, EMG RMS, and
  spectral power in three frequency bands (100–200, 200–300, 300–400 Hz),
  then fits a linear regression (R²) between each EMG metric and grip force
  to identify which feature best tracks force output.

  > **Note on file naming vs. in-script docstrings:** two of the original
  > Lab 3 scripts have a copy-paste labeling error in their header comment
  > (one says "Experiment 3" when its filename and content are Experiment 2;
  > another says "Experiment 1" when it's Experiment 3). The files here are
  > named for what the code actually computes, not the stale docstring text.

## Core toolkit (`src/core`)

| File | Purpose |
|---|---|
| `detectSpikes.m` | Threshold-crossing event detector; returns event times and fixed-window waveforms. Used for both spike detection and stimulation-pulse detection (by choice of threshold). |
| `computeSNR.m` | Splits a recording into spike/noise samples via threshold and returns RMS of each, for SNR. |
| `calcSpikePeak2Peak.m` | Peak-to-peak amplitude of each detected waveform. |
| `readEventsFile.m` | Parses Backyard Brains `-events.txt` marker logs into event codes + timestamps. |
| `trialAlignSpikes.m` | Aligns discrete spike times to a set of trial event times, with per-spike trial labels. |
| `trialAlignData.m` | Same alignment, for continuous signals (force, EMG) instead of discrete spike times. |
| `binTrialAlignedSpikes.m` | Bins trial-aligned spike times into a `[trials x time x channels]` firing-rate tensor for PSTH construction. |
| `plotRaster.m` | Raster plot of trial-aligned spike times. |
| `compute_periodogram_fft.m` | FFT-based periodogram (power spectral estimate) over a specified frequency band. |

These same nine files were duplicated identically across the original Lab
1/2/3 folders (course template); this repo keeps one copy of each in
`src/core` and has every analysis script reference it, rather than shipping
three redundant copies.

## Provenance & attribution

This started as BIOEN/ECE 466 coursework. The course provided:

- **Skeleton functions** with docstrings, structure, and specific
  implementation lines flagged `FILLIN` — `detectSpikes.m`, `computeSNR.m`,
  `readEventsFile.m`, `trialAlignSpikes.m`, `trialAlignData.m`,
  `binTrialAlignedSpikes.m`, and `plotRaster.m`. The `FILLIN` logic in these
  files, and all of the experiment-driver scripts (data loading loops,
  metric calculations, multi-file trend analysis, and figure generation),
  were completed for this project.
- **Fully-complete utility functions**, included here unmodified because the
  pipeline depends on them — `calcSpikePeak2Peak.m` and
  `compute_periodogram_fft.m`.

BIOEN 466 labs are structured as team assignments (2–3 students); the
original files don't carry per-student authorship headers the way some other
projects in this portfolio do, so if a lab partner contributed to this
submission and isn't credited here, let me know and I'll update the license.

## Known limitations

- **No results write-up survives.** Unlike other repos in this portfolio,
  the comprehension-question/report templates for these labs were never
  filled in (only the blank course templates exist on disk) — so this repo
  documents the code and methodology, not final numeric results. No
  figures/numbers are claimed here that weren't actually generated.
- **Hardcoded paths.** Every script has a `dataDir = 'C:\Users\...'` line
  (and builds filenames with literal `'\'` separators) pointing at the
  original data-collection machine. Update `dataDir` to point at this repo's
  `data/<experiment>/` folder before running; on macOS/Linux (e.g. in
  Octave) you'll also need to swap the `'\'` separators for `filesep`/`'/'`.
- **Lab 0 intentionally excluded.** The on-disk copy of the intro
  spike-detection/raster tutorial still has unresolved template blanks (e.g.
  `threshold = ;` — a syntax error as written) and was never finished, so
  it isn't part of this repository.
- **`plotRaster.m`'s no-figure fallback branch is broken** (`ax_handle =
  ax;` calls an undefined function). None of the included analysis scripts
  hit this path — they always pass an explicit figure/axis handle — so it
  doesn't affect anything here, but calling `plotRaster` with no arguments
  would fail until that line is changed to e.g. `ax_handle = gca;`.

## Running this code

Requires MATLAB (or Octave with the signal/statistics packages) —
`audioread`, `rms`, and `regress` are used throughout.

1. Update the `dataDir` assignment(s) near the top of the script you want to
   run to point at the matching `data/<experiment>/` folder.
2. Each script has two `%%` sections: a single-file "test" pass (loads one
   recording, plots intermediate steps) followed by a "now we can proceed
   to look at trends" loop that runs the full analysis across all files
   listed for that experiment. Run cell-by-cell to inspect intermediate
   plots, or run the whole script for the final trend figures.

## Data

Raw recordings from Backyard Brains SpikeRecorder / Musclebox hardware:
one `.wav` file per trial/recording, with accompanying `<name>-events.txt`
event-marker logs for the stimulus-aligned experiments (2 and 3).
