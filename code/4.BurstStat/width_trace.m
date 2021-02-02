function widthavg = width_trace(brst,time)
% Average across expanded burst time with width for all specified
% bursts across all specified trials.
%
% Input
% -----
% brsts: table (n_trials-by-n_bursts-by-n_var)
%   Gaussian fits to bursts, i.e. this should contain the mean and SD of
%   fit in the temporal dimension. alreadly selected by conditions and
%   band-filtered
% trialtime: double
%   Trial time points of interest. Must be consistent with the times
%   specified in brsts. 
%
% Output
% ------
% widthavg: vector of length t (samples of a whole trial)
%   trial-average amplitude function of a given condition and a given
%   channel. missing points are filled by NaN.

ntrl = numel(brst);
fs = 1000;

for itrl = 1:ntrl
    % trick around trials with no burst
    if isempty(brst{itrl})
        trl_brst{itrl} = [];
        continue
    end
    
    clear brst_*
    b = brst{itrl}{:,{'t','t_sd','f'}};
    % burst times
    [brst_time,~,brst_width] = arrayfun(@(x) expand_burst(b(x,1),b(x,2),fs,b(x,3)), 1:size(b,1),'uni',0);
    % width vector
    brst_sum = cell2mat([brst_time;brst_width]');
    % convert to integral
    brst_sum(:,1) = round(brst_sum(:,1)*fs);
    
    % accumulate for each trial
    [brst_acm(:,1),~,brst_sum(:,1)] = unique(brst_sum(:,1));
    brst_acm(:,2) = accumarray(brst_sum(:,1),brst_sum(:,2),[],@mean); % mean width across time points
    
    % trail average stored
    trl_brst{itrl} = brst_acm;
end

brst_trl = cell2mat(trl_brst');
[brst_cond(:,1),~,brst_trl(:,1)] = unique(brst_trl(:,1));
brst_cond(:,2) = accumarray(brst_trl(:,1),brst_trl(:,2),[],@mean);

% delete timepoints out of observation range
tx = 1-round(1000*time(1));
idx = brst_cond(:,1)+tx;
kstr = find(idx>0,1);
kend = find(idx<=length(time),1,'last');
widthavg = NaN(length(time),1);
for ts = kstr:kend
    widthavg(idx(ts)) = brst_cond(ts,2);
end