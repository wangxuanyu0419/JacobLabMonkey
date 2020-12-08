close all
clear all

%% cd to root path
stdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(stdir);

%% read in data_prep, segmented LFP functions
prepdir = dir([stdir '/data/0.TrialScreening/*.mat']); % dir to all nex files

for i = 1:numel(prepdir)
    load(fullfile(prepdir(i).folder,prepdir(i).name));
    fprintf('Now at %s\n',prepdir(i).name(1:7));

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
    save(fullfile(prepdir(i).folder,prepdir(i).name),'data_prep');
end
