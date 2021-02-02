% calculate bursts statistics from extracted burst data

close all
clear all

%% set root path
stdir = '/mnt/storage2/xuanyu/MONKEY/Non-ion'; % migrate data to the storage 2

%% compare input files and exist output files
inf = dir(fullfile(stdir,'3.Bursts','*.mat'));
outf = dir(fullfile(stdir,'4.BurstStat','*.mat'));
sessdir = dir(fullfile(stdir,'0.TrialScreening','*.mat'));

[f_name,~] = setdiff({sessdir.name},{outf.name});

cfg.min_cycle = 1;
cfg.fband = {[4 10]; [20 35]; [50 90]};

%% parallel processing for burst estimation
parfor i = 1:numel(f_name)
    try
        burstprop_traces(f_name{i}(1:7),cfg);
    catch e
        fprintf('\nWarning: Something wrong with Session %s: \n%s\n',f_name{i}(1:7),e.message);
    end
end

