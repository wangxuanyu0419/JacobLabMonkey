% this script is for plotting trial-LFPs session by session and screen out
% bad trials (e.g. see R120410, AD14, correct trial 49) and/or bad channels

close all
clear all

stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
% cd(stdir);

%% define general variables
nexdir = dir([stdir '/data/raw_nex/*.nex']); % dir to all nex files
try
    mkdir([stdir '/data/TrialScreening_201118']);
catch
end
expath = [stdir '/data/TrialScreening_201118'];

%% trialfun: segment trials
cfg_deftrl = [];
cfg_deftrl.trialfun = 'trialfun_201118';
cfg_deftrl.trialdef.eventtype = 'Strobed*'; % first 7 characters are compared
cfg_deftrl.trialdef.eventvalue = 25; % analysis starting/aligned point; reward code, 3; sample onset, 25;
cfg_deftrl.trialdef.pretrl = 1.5; % 0.5 fixation + 1s padding
cfg_deftrl.trialdef.posttrl = 1;
cfg_deftrl.trialdef.triallen = 3;
cfg_deftrl.trialdef.errorcode = 0; % 0, correct; 1, missing; 6, mistake; nan: no-specification;
cfg_deftrl.trialdef.stimtype = nan; % nan: no-specification; 0, standard; 1, controlled;
cfg_deftrl.trialdef.sampnum = nan; % sample numerosity: 1-4; nan: no-specification;
cfg_deftrl.trialdef.distnum = nan; % distractor numerosity: 1-4; nan: no-specification;
cfg_deftrl.channel = {'AD*'};

%% preprocessing & plot error trials with problematic channels
istr = 1; % adjust start session
for i = istr:numel(nexdir)
    cfg_deftrl.dataset = fullfile(nexdir(i).folder,nexdir(i).name);
    
    % define trial
    cfg_preproc = ft_definetrial(cfg_deftrl);
    % preprocess
    data_prep = ft_preprocessing(cfg_preproc);
    
    % store preprocessed data
    save(fullfile(expath,nexdir(i).name(1:7)),'data_prep');
    
%     % Visualization of the raw data: Manual
%     cfg_vis = [];
%     cfg_vis.viewmode = 'vertical';
%     cfg_vis.continuous = 'no';
%     cfg_brows = ft_databrowser(cfg_vis,data_prep);        
%     pause
%     close all
    
    % Trial screening: auto
    % data range [-499.7559 499.7559], screen out a trial if there's an 
    % overshoot within the time window of interest: (0, 3000)
    eTrl = [];
    trlnum = numel(data_prep.trial);
    for ntrl = 1:trlnum
        [eChan eTime] = find(data_prep.trial{ntrl}>499 |data_prep.trial{ntrl}<-499);
        if ~isempty(eChan)
            chanidx = unique(eChan);
            PlotSingleTrials_201120(data_prep,ntrl,i,chanidx,eTime);
            eTrl = [eTrl ntrl];
        end
    end
    badtrials{i} = eTrl;
end

save([expath '/badtrials/badtrials'], 'badtrials');
