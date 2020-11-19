% this script is for plotting trial-LFPs session by session and screen out
% bad trials (e.g. see R120410, AD14, correct trial 49) and/or bad channels

close all
clear all

stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(stdir);

%% define general variables
nexdir = dir('./data/raw_nex/*.nex'); % dir to all nex files
try
    mkdir('./data/TrialScreening_201118');
catch
end
expath = './data/TrialScreening_201118';

%% trialfun: segment trials
cfg_deftrl = [];
cfg_deftrl.trialfun = 'trialfun_201118';
cfg_deftrl.trialdef.eventtype = 'Strobed*'; % first 7 characters are compared
cfg_deftrl.trialdef.eventvalue = 25; % analysis starting/aligned point; reward code, 3; sample onset, 25;
cfg_deftrl.trialdef.pretrl = 1.5; % 0.5 fixation + 1s padding
cfg_deftrl.trialdef.posttrl = 1;
cfg_deftrl.trialdef.triallen = 0;
cfg_deftrl.trialdef.errorcode = 0; % 0, correct; 1, missing; 6, mistake; nan: no-specification;
cfg_deftrl.trialdef.stimtype = nan; % nan: no-specification; 0, standard; 1, controlled;
cfg_deftrl.trialdef.sampnum = nan; % sample numerosity: 1-4; nan: no-specification;
cfg_deftrl.trialdef.distnum = nan; % distractor numerosity: 1-4; nan: no-specification;

for i = 1:numel(nexdir)
    cfg_deftrl.dataset = fullfile(nexdir(i).folder,nexdir(i).name);
    
    % define trial
    cfg_preproc = ft_definetrial(cfg_deftrl);
    % preprocess
    data_prep = ft_preprocessing(cfg_preproc);
    % Visualization of the raw data
    cfg_vis = [];
    cfg_vis.viewmode = 'vertical';
    cfg_vis.continuous = 'no';
    cfg_brows = ft_databrowser(cfg_vis,data_prep);
    
end

%% preprocessing: 
