% this file is for getting single-trial LFP data and stored in fieldtrip format
% segmentation: 1s before fixation onset, 1s after delay2 offset
% trial error: only correct trials (code 0)

close all
clear all

stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(stdir);

%% define general variables
nexdir = dir('./data/raw_nex/*.nex'); % dir to all nex files (with LFP & spike)
nexdir_R = dir('./data/raw_nex/R*.nex'); % dir to all nex files of monkey R (with LFP & spike)
nexdir_W = dir('./data/raw_nex/W*.nex'); % dir to all nex files of monkey W (with LFP & spike)
try
    mkdir('/data/201118_preprocessing');
catch
end
expath = '/data/201118_preprocessing';
chanPFC = {'AD01', 'AD02', 'AD03', 'AD04', 'AD05', 'AD06', 'AD07', 'AD08'};
chanVIP = {'AD09', 'AD10', 'AD11', 'AD12', 'AD13', 'AD14', 'AD15', 'AD16'};

%% trialfun: segment trials
    cfg_deftrl = [];
    cfg_deftrl.trialfun = '201118_trialfun';
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
    
end
