function br = compute_burstrate(brsts,time,fun_burstprop)
% Computes non-binary (accumulated) and binary burst rate from burst parameters.
% Accumulated burst rate for a point in time is defined as the mean number of burst events across trials.
% Binary burst rate for a point in time is defined as the mean number of trials with any burst events.
%
% Input
% -----
% brsts: cell array
%   Every cell (representing a trial) should contain a table of burst parameters.
% time: double
%   Vector of trial times in which burst rate is evaluated.
%
% Output
% ------
% br: double
%   2-by-numel(time) matrix of burst rates corresponding to trial times. 
%   br(1,:) is the non-binary/accumulated burst rate. 
%   br(2,:) is the binary burst rate.

brst_cnt = cell2mat(cellfun(@(x) fun_burstprop(x,time), brsts, 'uni', 0));

acc_mean = @(n_time,n_trial,n_brst) accumarray(repmat((1:n_time)',[n_trial 1]), n_brst)/n_trial;
br = vertcat(...
    acc_mean(numel(time),numel(brsts),brst_cnt)',... % non-binary/accumulated
    acc_mean(numel(time),numel(brsts),brst_cnt>0)'); % binary
