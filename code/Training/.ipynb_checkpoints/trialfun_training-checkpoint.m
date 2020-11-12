function trl = trialfun_training(cfg)

% This function requires the following fields to be specified:
% 
% 
% 
% 
    %% read in header and events
    hdr     = ft_read_header(cfg.dataset); % mainly for sampling frequency
    event   = ft_read_event(cfg.dataset);
    
    %% event marker codes
    beginTrial          = 9;
    endTrial            = 18;
    startPreTrial       = 15;  % start pre trial period (after fixation onset)
    sampon              = 25;
    sampoff             = 26;
    delay1on            = 33;
    delay1off           = 34;
    diston              = 27;
    distoff             = 28;
    delay2on            = 48;
    delay2off           = 49;
    nonmatchon          = 29;
    nonmatchoff         = 30;
    matchon             = 31;
    matchoff            = 23;
    correct             = 200; % correct trial 
    mistake             = 201; % error trial
    
    %% analysis variables:
    fixedTrialLen   = true;
    preanapad      = round(hdr.Fs * cfg.trialdef.pretrl);
    postanapad     = round(hdr.Fs * cfg.trialdef.posttrl);
    anatriallen        = round(hdr.Fs * cfg.trialdef.triallen) + preanapad + postanapad; % unit from s to num of samples
    eventmark       = cfg.trialdef.eventvalue;
    
    %% convert struct to vector
    TimeStamps = [event.sample]';
    TimeStamps = TimeStamps(3:(end-1));
    Marks = [event.value]';
    
    %% select trials:
    % find certain markers within a trial in reference to the beginning
    begidxs = find(Marks == beginTrial);
    begidxs = begidxs(1:3:end); % take the first of 3 repeats
    enddixs = find(Marks == endTrial);
    enddixs = enddixs(3:3:end); % take the last of 3 repeats
    if size(begidxs, 1) > size(enddixs, 1)
        % if PLEXON terminated before CORTEX, remove last incomplete trial
        begidxs = begidxs(1:end-1);
    end
    
    % get trial info
    ctxfilename = [cfg.dataset((end-17):(end-11)),'.mat'];
    load(fullfile('C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\spike_nexctx',ctxfilename));
    trlnum = length(nexctx.TrialResponseErrors);
    
    % select trials
    if isfield(cfg.trialdef,'errorcode')
        if isnan(cfg.trialdef.errorcode)
            errorsel = ones(trlnum,1);
        else
            errorsel = nexctx.TrialResponseErrors == cfg.trialdef.errorcode;
        end
    else
        error('Field cfg.errorcode not defined');
    end
    
    if isfield(cfg.trialdef,'stimtype') % standard or control trial
        if isnan(cfg.trialdef.stimtype)
            stimsel = ones(trlnum,1);
        else
            stimsel = mod(nexctx.TrialResponseCodes,10) == cfg.trialdef.stimtype;
        end
    end
    
    if isfield(cfg.trialdef,'sampnum') % sample numerosity
        if isnan(cfg.trialdef.sampnum)
            sampsel = ones(trlnum,1);
        else
            sampsel = floor(nexctx.TrialResponseCodes/1000) == cfg.trialdef.sampnum;
        end
    end
    
    if isfield(cfg.trialdef,'distnum') % sample numerosity
        if isnan(cfg.trialdef.distnum)
            distsel = ones(trlnum,1);
        else
            distsel = mod(floor(nexctx.TrialResponseCodes/100),10) == cfg.trialdef.distnum; % the hundreds digits are for distractor, e.g. x2xx
        end
    end
   
    sellog = errorsel & stimsel & sampsel & distsel;
    idxmat = [1:1:trlnum]';
    selidx = idxmat(sellog);
    
    %% initialise and allocate memory for trl-matrix
    trl = zeros(sum(sellog),3);
    for i = 1:sum(sellog)
        trlidx = selidx(i);
        trialmarks = Marks(begidxs(trlidx):enddixs(trlidx));
        trialstamps = TimeStamps(begidxs(trlidx):enddixs(trlidx));
        anabegstamp = trialstamps(find(trialmarks == eventmark)) - preanapad;
        anaendstamp = anabegstamp + anatriallen;
        trl(i,:) = [anabegstamp anaendstamp -preanapad];
    end
end


    