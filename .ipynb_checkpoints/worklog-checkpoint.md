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
* <s>***Question***</s>: 
    - A ceiling artifact in AD14, `R120410`, correct trial 49;
    - Channel AD14 not stable troughout the whole session
    - What to do?
    - Daniel haven't screen for these artifacts (saturation of data acquisition); may need eyeballing for excluding certain trials

![Ceiling?](./General/Figures/Questions/Ceiling.png)

* stepping into the [frequency analysis](https://www.fieldtriptoolbox.org/walkthrough/#frequency-analysis)


## 2020.11.10
* ***Question*** sampling rate: 40kHz for what and 1kHz for what?

## 2020.11.11
* <s>***Question***</s> Why there're NaNs in the spectral data? Solution: fieldname 'channel' not 'Channel'; a wrong fieldname will be ignored by FieldTrip without warning.
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
* ***Question*** bsfreq in ft_preprocessing? what is it?

## 2020.11.17
* Discussed a little about the training powerplots with Simon, acceptable and ready to enter the next stage
* working on getting guest accounts for the lab, not solved

## 2020.11.18
* Use Shirui's account on the Analysis PC, done.
* start to do preprocessing:
  - [preprocessing_201118](./code/1.Preprocessing/preprocessing_201118.m)
  - [trialfun_201118](./code/1.Preprocessing/trialfun_201118.m) copied from `./code/Training/trialfun_training.m`
* develop trial screening protocol:
  - [TrialEyeballing_201118](./code/0.TrialScreening/TrialEyeballing_201118.m)
* Alpha connection is bad: resetting already established connections from time to time
    - a hack: ssh through beta then through alpha
    
## 2020.11.19
* Start trial screening:
    - Protocol: run [TrialEyeballing_201118](./code/0.TrialScreening/TrialEyeballing_201118.m)
    - each session was break apart with a `pause`
    - wrong trials note down at [TrialScreening](./data/TrialScreening_201118/badtrials.md)
    
## 2020.11.20
* plot single trial for review:

![1.1](./data/TrialScreening_201118/badtrials/1.1.AD14.png)

    - range of data: [-499.7559 499.7559]; saturation if exceeding the range
    
* Auto detect saturations:
    - `data_prep` saved at `./data/TrialScreening_201118/*.mat`
    - badtrial figures at `./data/TrialScreening_201118/.png`; name formatting: session.trial.png
    
## 2020.11.21
* error trials got, only observed in 2 sessions (i=[1 4], name = ['R120410' 'R120413'])
* further eyeballing: kick out trials with saturation in time window [0 3000] after event *25* (sample onset)
    - 1.[1 16 21 22 36 40 54 58 89], 9 trials, all in channel `AD14`
    - 4.[5 7 10 15 16 23 26 27 32 33 39 45 47 48 49 50 52 54 56 57 59 60 64 65 66 67 76 78 80 82 83 95 97 99 104 105 106 118 128 142 145 146 148 151 153 155 157 160 162 165 174 175 176 177 180 182 183 185 187 188 190 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 223 226 227 228 229 234 235 237 238 242 243 244 247 248 249 250 251 254 257 258 259 261 263 265 266 269 271 272 274 275 276 277], 121 trials, all in channel `AD11`, consider exclude the whole channel

## 2020.11.23
* Check Superlet method. It's in Daniels' github

## 2020.11.24
* continue with the Superlet method.
* Issue: Daniel's development on Superlet for Fieldtrip has not been finished. There seems scaling issue (see email and `./General/Methods/`)
* plot with [contourf](https://mailman.science.ru.nl/pipermail/fieldtrip/2015-July/035240.html)
* Power plots with different methods in example trials, averaged across electrodes: `./code/Training/ft_superlet/Plots`
e.g.: ![1.182](./code/Training/ft_superlet/across_electrode/R120410_182.png)
* MTMCONVOL method result in 
smaller values in power, especially for lower frequencies. Might be normalized across frequency bands? (i.e. uV<sup>2</sup>/Hz, 1/f rule considered)
* ***Question*** what's the unit for the power values in each bin? e.g. in wavelet analysis? Also mine is different from Daniel's, also because of normalization?
![Daniel example](./General/Figures/Questions/Daniel_example_burst.png)
    - Look into the codes!

## 2020.11.26
* plot a lot of figures with example sessions / trial, at `./code/Training/ft_superlet`, aiming at visualize the result of different analysis methods.
* confirm superlet and wavelet methods are prone to 1/f law. Need normalization

## 2020.11.27
* give data club presentation, discuss a few things:
    - a fixed way for standardization is necessary, ionto data are more messy, better less strict way: **only exclude trials with saturation within [-0.5 3] range.** Save the electrodes
    - do not need to do 1/f normalization, when normalized by -9~0 trials, already across frequency bands
    - filter the 50/60Hz noises: like EEG, relate to e.g. light alternating f; So called **Power line component**
    - each channel separated by 1mm, enough to be considered as independent
    - maybe relate to spikes first before doing clustering etc.
    - should try to reproduce and catch up to Daniel's progress so
* migrate lfp_da repo to the `share/Xuanyu` folder

## 2020.12.01
* run freqanalysis and normalization in 1st session.
     - Takes very long, up to 3h for a single session.
     - Maybe exclude bad trials before doing so. **Nope**, keep it for later analysis.
* Test if the normalization is working:
    - Plot across electrodes for trial-average and example trial (`./code/1.Preprocessing/plot_example`)
* discover a bug in previous generation of badtrials: `TrialScreening_Pipeline`, line 53:
> ...find(data_prep.trial{ntrl}(**:,**1000:4500))...
    - It previously takes the 1000:4500 element instead of from the second dimension (time in trial)
* renew it via [add_badtrials]('./code/0.TrialScreening/add_badtrials.m')
* debug on freqanalysis and normalization, trigger a `parfor` parrallel processing of the dataset
    - normalized result at `data_freq.powspectra_norm`
     
## 2020.12.02
* progress last night failed, unknown reason: dot index not supported
    - Any way to make error line specific?
    - To make trial progress also explicit?
    - There are also out of memory errors
* run with fewer trials doesn't report errors, might be out of memory problem?
    - reduce number of workers down to 6
* succeed in some sessions, bad sessions here:
    - R120416: out of memory
    - ...
* decide to use only 3 workers

## 2020.12.03
* mostly done, bad sessions:
    - R120420 (text progress must be initialized with a string)
    - R120413 (text progress)
    - R120410 (text progress)
    - R120418 (text progress)
    - R120517 (text progress)
    - R120523
    - R120416
    - R120521
    - R120503
* failure rate about 50%
* problem with text progress bar, quoted out during pause, don't know if it works.
* add script that skip exist files
* restart processing.

## 2020.12.07
* debug on file saving, only saved a string called 'data_freq' previously...
* The size of data is extremely large with all channels and all correct trials, now separate preprocessed data (`1.Preprocessing`) and normalized data (`2.Normalized`)
* Migrade data from `/mnt/share/XUANYU/MONKEY/JacobLabMonkey` to `/mnt/storage2/XUANYU/MONKEY/Non-ion`
    - copy the following folders:
        - 0.TrialScreening
        - 1.Preprocessing
        - 2.Normalized
        - raw_nex
        - spike_nexctx
    - remove folder 0./1./2. from the share folder
* takes about 3 days to get all processing done;
* Now file-saving is moved into the `norm_by_prevtrl.m`, during normalization process, and trial info was also included.
* Better progress report in command window
* result padding change to [-0.5, 3.5]

## 2020.12.08
* file size too big, split by channel for storage, discard the plan to store pure frequency data

## 2020.12.12
* preprocessing and normalization done, successful in all sessions and all channels
* try to start burst extraction:
    - try thresholding with e.g. z.*(z>2)
    - reference to code `share/DANIEL/IONTOPHORESIS/_plots/bursts/addASLT_3_30/190813-pow_z_thr/code`

## 2020.12.14
* plot example trials, overlaid with Daniel's burst peaks:
![Example trial](./data/2.Normalized/R120516-AD01_008_D.jpg)
* There're differences, suspect reason: my normalization didn't include error and missing trials, but only with correct trials
    - pons: heterogeneous background? small z-score size?
* Next step: burst extraction

# To-do list:
* (x) define a trial structure for the data, arrage that for whole-dataset analysis (ft_redefinetrial)
* (x) artifact screening (for trials / electrodes)
* (x) familiarize with superlet method

# Ideas to go
* Item specific bursts / burst identities:
    - spatial outlay: weighted in different electrodes
    - sorted by spiking neurons
* Dopamine ionophoresis effect