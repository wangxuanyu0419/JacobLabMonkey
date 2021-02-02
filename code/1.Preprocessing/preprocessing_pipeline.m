% Perform spectral analysis and normalized by the previous 9 trials +
% current trial. 


close all
clear all

%% cd to root path
% stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
stdir = '/mnt/storage2/xuanyu/MONKEY/Non-ion'; % migrate data to the storage 2
cd(stdir);

%% read in data_prep, segmented LFP functions
inpath = [stdir '/0.TrialScreening'];
prepdir = dir([inpath '/*.mat']); % dir to all nex files
expath = [stdir '/1.Preprocessing'];
exdir = dir([expath '/*.mat']);
expath_n = [stdir '/2.Normalized'];

%% compare the input data and already exist outputs
[f_name,f_list] = setdiff({prepdir.name},{exdir.name});
f_path = prepdir(f_list).folder;

cfg_prep = [];
cfg_prep.method              = 'superlet';
cfg_prep.output              = 'pow';
cfg_prep.channel             = 'all';
cfg_prep.trials              = 'all';
cfg_prep.keeptrials          = 'yes';
cfg_prep.pad                 = 'nextpow2';
cfg_prep.padtype             = 'zero';
cfg_prep.polyremoval         = 0;
cfg_prep.foi                 = 4:100;
cfg_prep.toi                 = -1:0.001:4; % result padded with 1s
cfg_prep.superlet.basewidth  = 3;
cfg_prep.superlet.combine    = 'additive';
cfg_prep.superlet.order      = round(linspace(1,30,numel(cfg_prep.foi)));

delete(gcp('nocreate'))
pools = parpool(4);

parfor i = 1:length(f_list) % do parallel processing across sessions, skip processed files
    f_title = f_name{i}(1:7);
    try
        data_prep = parload(fullfile(f_path,f_name{i}),'data_prep');
        fprintf('Now start %s\n',f_title);
        
        data_freq = ft_freqanalysis(cfg_prep,data_prep);
        
        % pass badtrial to data_freq
        data_freq.badtrials = data_prep.badtrials;

        % normalization with -9~0 prev trl, save file both before and after normalization
        fprintf('Normalizing %s\n',f_title);
        norm_by_prevtrl(data_freq,9,expath,expath_n,f_title);   
    catch e
        fprintf(2,'\nWarning\nSomething wrong with Session %s: \n%s\n',f_title,e.message);
    end
end
