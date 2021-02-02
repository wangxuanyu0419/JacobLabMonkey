% This script is for learning basic fieldtrip processings. The goal is to
% get power plots aligned to reward in test trials (excluding free reward
% condition).

% Example trial definition:
filename = 'C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\raw_nex\R120410-03_lfp.nex';

%% trialfun: segment trials
cfg = [];
cfg.dataset = filename;
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'Strobed*';
cfg.trialdef.eventvalue = 25;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 2;
ppcfg = ft_definetrial(cfg);
