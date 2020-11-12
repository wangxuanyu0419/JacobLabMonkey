# Working log

## 2020.11.03
* Discussion with Danial and Simon on project overview and schedule
* Download `Neuroexplorer demo` for a trial on viewing the raw data 
* Meeting with Simon and Daniel, went through the `.nex` & `.ctx` & `.TM1`(Timing script) files

## 2020.11.04
* Uninstall `Neuroexplorer demo`, get its MATLAB toolbox `C:\Program Files\MATLAB\R2020a\toolbox\nexreader` (*Free*)
* Summarize the discussion (11.03) in `/Git/JacobLabMonkey/README.m`
* backup raw data (`.nex` and `.ctx`) at `share/XUANYU/MONKEY/Non-iontophoresis/data/raw_nex` and github

## 2020.11.05
* md file on behavior markers lost, unknown reason; but got paper record backup
* make sure commit everyday for the changes
* keep on with the condition codes, response codes, error codes
* now clear with the task structure: [document scan](./General/TrialMarkerDescription.pdf)
* start learning fieldtrip data structure
* try to do trial segmentation on rewards, only for test trials, excluding the free-rewards. See [pipeline script](./code/Training/RewardLFPs-pipeline.m)

## 2020.11.06
* [trial function](./code/Training/trialfun_training.m) (for segmentation) done, include variables:
    - eventvalue: event E to align, e.g. 3 for reward, 25 for sample stim onset
    - pretrl: time (sec) before E included in analysis
    - posttrl: time (sec) after E for analysis
    - triallen: triallength start from E (kind of unnecessary considering pre- and posttrl should have already define the length)
    - errorcode: use for select trials based on the response correction
    - stimtype: select trial based on standard/controlled stimulus
    - sampnum: select trial based on sample numerosity
    - distnum: select based on distractor numerosity
* include the notes in `README.md`
* *Are there artifacts that should be removed?* No physiological-event relevant noise, e.g. EOG
* Preprocessing with what parameter? bandpass? 
> mean-centered, filtered for line noise removal... and re-referenced to the average of all prefrontal and parietal electrodes within a session, unless stated otherwise... ERP subtraction was performed separately for all analyzed trial subsets
* ERP calculation done, see [figure](./code/Training/ERPs/R120410_reward.png)

## 2020.11.09
* try visualization of the raw data for inspection purpose `ft_databrowser`
    - no remarkable trends or artifacts in LFP
    - may try ICA later;
* ***Question***: 
    - A ceiling artifact in AD14, `R120410`, correct trial 49;
    - Channel AD14 not stable troughout the whole session
    - What to do?

![Ceiling?](./General/Figures/Questions/Ceiling.png)

* stepping into the [frequency analysis](https://www.fieldtriptoolbox.org/walkthrough/#frequency-analysis)


## 2020.11.10
* ***Question*** sampling rate: 40kHz for what and 1kHz for what?

## 2020.11.11
* ***Question*** Why there're NaNs in the spectral data? Solution: fieldname 'channel' not 'Channel'; a wrong fieldname will be ignored by FieldTrip without warning.
* ***Question*** try `mtmfft`, foilim [2 128] return 517 values, why? Suppose to be averaging across the range
* mtmfft with the following setup result in spectra:
```
cfg_spect.output = 'pow';
cfg_spect.method = 'mtmfft';
cfg_spect.pad = 'nextpow2';
cfg_spect.taper = 'dpss';
cfg_spect.foi = [1:128];
cfg_spect.tapsmofrq = [2]; % for fft;
```
![spectra](./code/Training/Power_Spectra_example.png)
* get gollum for editing the lab wiki. [Installation guide](https://github.com/gollum/gollum/wiki/Installation) not necessary, permission problem, now have access to edit

## 2020.11.12
* Plot powerplots: 
1. ***all*** channels aligned to sample onset (25)
![SampAlignAllChannels](./code/Training/Powerplots/R120410_trial.png)
2. ***PFC*** channels aligned to sample onset (25)
![SampAlignPFC](./code/Training/Powerplots/R120410_trial_PFC.png)
3. ***VIP*** channels aligned to sample onset (25)
![SampAlignVIP](./code/Training/Powerplots/R120410_trial_VIP.png)
* try a data session with missing channel *AD02*: (*R120508*)
![SampAlignMissingChan](./code/Training/Powerplots/R120508_trial.png)
* try to add titles, labels to the singleplotTFR
* ***Question***: VIP pre-sample ramp? small peaks following delay period?

# To-do list:
* define a trial structure for the data, arrage that for whole-dataset analysis (ft_reefinetrial)
* 