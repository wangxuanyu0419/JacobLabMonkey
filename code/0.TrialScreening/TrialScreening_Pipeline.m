% Perform segmentation and trial screening. Bad trials stored to 'badtrial.m'
% Define badtrials as having data saturation between [-0.5 3]s to sample onset
% Segment data by each session and by each channel.
%
% Only correct trials are included

close all
clear all

%% cd to root path
stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(stdir);

%% define general variables
nexdir = dir([stdir '/data/raw_nex/*.nex']); % dir to all nex files
try
    mkdir([stdir '/data/0.TrialScreening']);
catch
end
expath = [stdir '/data/0.TrialScreening'];

%% trialfun: segment trials
cfg_deftrl = [];
cfg_deftrl.trialfun = 'trialfun_201127';
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
    
    % preprocess: segmentation
    data_prep = ft_preprocessing(cfg_preproc);
    
    % Trial screening: auto
    % data range [-499.7559 499.7559], screen out a trial if there's an 
    % overshoot within the time window of interest: (-500, 3000)
    trlnum = numel(data_prep.trial);
    badtrials = zeros(numel(data_prep.label),trlnum);
    for ntrl = 1:trlnum
        [eChan,~] = find(data_prep.trial{ntrl}(:,1000:4500)>499 |data_prep.trial{ntrl}(:,1000:4500)<-499);
        if ~isempty(eChan)
            chanidx = unique(eChan);
            badtrials(chanidx,ntrl) = 1;
        end
    end
    data_prep.badtrials = badtrials;
    
    % store preprocessed data
    save(fullfile(expath,nexdir(i).name(1:7)),'data_prep');
end
