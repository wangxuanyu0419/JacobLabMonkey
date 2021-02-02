function burstprop_traces(session,cfg)
% Compute traces for each burst property of each condition of interest,
% stored by session at data/4.BurstStat.
%
% data structure:
% ---
% Contain fields:
%   - Rate: burst rate traces, contain n structs (n, number of channels),
%   each with x conidtions
%   - Amplitude: burst amplitude traces, n structs
%   - Width: burst width traces.
%
% cfg:
% ---
%   - min_cycle: double, scalar that sets the threshold for temporal burst width.
%   - fband: n*1 cell, each element is a 2*1 vector, specify a freq range
%   for analysis;
%
% Conditions (as table):
%   - S1-4: classtered by sample identity
%   - D0-4: classtered by distractor identity
%   - Effective / Non-effective: distractor effectiveness; distractor
%   different from the sample (effective) or same (Non-)
%
% Input:
% ---
% session: a string specify which session to read, e.g. "R120516"
%
%

fprintf('Now start: %s\n',session);

inputroot = '/mnt/storage2/xuanyu/MONKEY/Non-ion/3.Bursts/';
inputf = dir([inputroot,session,'*.mat']);
outputroot = '/mnt/storage2/xuanyu/MONKEY/Non-ion/4.BurstStat';
nChan = size(inputf,1);
nBand = size(cfg.fband,1);

% calculate for each channel and store in data_stat
for iChan = 1:nChan
    filename = inputf(iChan).name;
    ChanID = filename(9:12);
    
    load(fullfile(inputf(iChan).folder,filename));
    
    ntrl = size(data_burst.trialinfo,1);
    trialtime = data_burst.time;
    
    burst_trials = data_burst.trialinfo.bursts;
    
    % select trials for condition sorting, 12 conditions specified
    [condidx,condname] = sort_condition(data_burst.trialinfo);
    
    data_stat.label{iChan} = ChanID;
    if iChan == 1
        data_stat.fband = cfg.fband;
        data_stat.condname = condname;
        data_stat.time = data_burst.time;
        data_stat.cfg = cfg;
    end
    
    % extract bursts for different bands
    for iBand = 1:nBand
        frg = sort(cfg.fband{iBand});
        burst_sel = cellfun(@(x) ...
            x(...
            x.f>=frg(1) & x.f<=frg(2) & ...
            (gauss_fwfracm(x.t_sd,1/2).*x.f)>=cfg.min_cycle,:), ...
            burst_trials, 'uni',0); % trial wise selection
        
        % new method to accumulate burst rate and other properties, then
        % average across trials for each condition and for each channel,
        % each cell contain nChan of traces.
        data_stat.amp_bands{iChan,iBand} = cellfun(@(x) amp_trace(burst_sel(x),trialtime), condidx,'uni',0);
        data_stat.rate_bands{iChan,iBand} = cellfun(@(x) rate_trace(burst_sel(x),trialtime), condidx,'uni',0);
        data_stat.width_bands{iChan,iBand} = cellfun(@(x) width_trace(burst_sel(x),trialtime), condidx,'uni',0);
    end
end

fprintf('Burst statistics done: %s\n',session);
save(fullfile(outputroot,[session '.mat']),'data_stat','-mat');

end