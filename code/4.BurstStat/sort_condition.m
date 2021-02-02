function [condidx condname] = sort_condition(trialinfo)
% Sort trials in a session by its sample and distractor identity, output
% trial index for each condition.
%
% Input:
% ---
% trialinfo:
%   - table with 5 columns, sample and distractor are used for sorting
%   conditions
%
% Output:
% ---
% condidx:
%   - 1*12 cell, each with index for trials of one single condition
%
% condname:
%   - 1*12 cell, name of the conditions (S1-4, D0-5, Effective, Non-effective)

condname = {'S1','S2','S3','S4','D0','D1','D2','D3','D4','Effective','Non-effective','All'};
% sample conditions
for i = 1:4
    condidx{i} = find(trialinfo.sample==i);
end
% distractor conditions
for i = 0:4
    condidx{i+5} = find(trialinfo.distractor==i);
end
% effective distractor conditions
condidx{10} = find(trialinfo.sample~=trialinfo.distractor);
% non-effective distractor conditions
condidx{11} = find(trialinfo.sample==trialinfo.distractor);
% all conditions included
condidx{12} = 1:length(trialinfo.sample);
end