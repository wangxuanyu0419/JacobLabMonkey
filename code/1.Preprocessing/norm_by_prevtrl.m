function norm_by_prevtrl(data_freq,n_prevtrl,savepath,savepath_n,f_title)
% compute z-score by normalizing to n previous trials
% for the first several trials, take all 10 leading trials
% normalization per frequency
    
    pow = data_freq.powspctrm;
    pow_n = nan(size(pow));
    ntrl = size(pow,1);
    nChan = size(pow,2);
    
    %% get trial infomation into the data struct
    stdir = '/mnt/storage2/xuanyu/MONKEY/Non-ion';
    cd(stdir);
    
    ctxpath = 'spike_nexctx';
    load(fullfile(ctxpath,[f_title '.mat']));
    respcode = nexctx.TrialResponseCodes(nexctx.TrialResponseErrors==0);
    sample = floor(respcode/1000);
    distractor = mod(floor(respcode/100),10);
    test = mod(floor(respcode/10),10);
    stimtype = mod(respcode,10); % standard or controlled
    data_freq.trialinfo = table(sample,distractor,test,stimtype);

    %% normalization
    fprintf('the input of %s is raw data with %d channels and %d trials\n',f_title,nChan,ntrl);
%     textprogressbar('Normalization progressing: '); % only work without parallel processing
    for itrl = 1:ntrl
%         textprogressbar(round(itrl/ntrl*100));
        if itrl <= n_prevtrl
            supermat = pow(1:(n_prevtrl+1),:,:,:);
        else
            supermat = pow((itrl-n_prevtrl):itrl,:,:,:);
        end
        meanmat = repmat(squeeze(nanmean(nanmean(supermat,4),1)),1,1,size(supermat,4));
        stdmat = repmat(squeeze(nanmean(nanstd(supermat,0,4),1)),1,1,size(supermat,4));
        pow_n(itrl,:,:,:) = (squeeze(pow(itrl,:,:,:))-meanmat)./stdmat;
        data_freq.powspctrm_norm = pow_n;
    end
    
    fprintf('\nNormalization done: %s\n',f_title);
    
    %% save normalized frequency data by channel
    ichan = length(data_freq.label);
    for i = 1:ichan
        data_norm.label = data_freq.label{i};
        data_norm.freq = data_freq.freq;
        data_norm.time = data_freq.time;
        data_norm.cfg = data_freq.cfg;
        data_norm.badtrials = data_freq.badtrials(i,:);
        data_norm.trialinfo = data_freq.trialinfo;
        data_norm.powspctrm_norm = squeeze(data_freq.powspctrm_norm(:,i,:,:));
        save(fullfile(savepath_n, [f_title '-' data_norm.label '.mat']),'data_norm','-mat');
    end
    
    %% save a mark for completion
    data_freq = rmfield(data_freq,{'powspctrm','powspctrm_norm'});
    save(fullfile(savepath,[f_title '.mat']),'data_freq','-mat');
    
    fprintf('\nSave normalized data done: %s\n',f_title);
end