function norm_by_ms(data_freq,twnorm,savepath,savepath_n,f_title)
% compute z-score by normalizing to 300ms before sample onset for each
% trial
    
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
        for iChan = 1:nChan
            pow_sg = squeeze(pow(itrl,iChan,:,:));
            tstr = find(data_freq.time>=0,1);
            if tstr<=twnorm
                error(message('Not enough padding for normalization baseline'));
            end
            % calculate mean power for each frequency
            meanmat = repmat(nanmean(pow_sg(:,(tstr-500):tstr),2),1,size(pow_sg,2));
            stdmat = repmat(nanstd(pow_sg(:,(tstr-500):tstr),0,2),1,size(pow_sg,2));
            pow_n(itrl,iChan,:,:) = (pow_sg - meanmat)./stdmat;
        end
    end
    data_freq.powspctrm_norm = pow_n;
   
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