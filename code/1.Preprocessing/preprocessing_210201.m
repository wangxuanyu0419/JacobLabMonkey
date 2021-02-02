%% spectral analysis and normalization for example session R120516
load(fullfile(prepdir(1).folder,'R120516.mat'));

data_freq = ft_freqanalysis(cfg_prep,data_prep);

% pass badtrial to data_freq
data_freq.badtrials = data_prep.badtrials;

% normalization with -9~0 prev trl, save file both before and after normalization
norm_by_prevtrl(data_freq,9,expath,expath_n,'R120516');

%% extract burst

inf = dir(fullfile(stdir,'2.Normalized','*.mat'));
f_path = inf(1).folder;
outfolder = fullfile(stdir,'3.Bursts');

delete(gcp('nocreate'))
pools = parpool(20);
parfor i = 1:length(inf)
    try
        burst_extraction(f_path,inf(i).name,outfolder);
    catch e
        fprintf('\nWarning: Something wrong with Session %s: \n%s\n',f_title,e.message);
    end
end

%% burst stats

cfg.min_cycle = 1;
cfg.fband = {[4 10]; [20 35]; [50 90]};

burstprop_traces('R120516',cfg);

%% plot examples
load('R120516.mat')
plot_examples_burststat

