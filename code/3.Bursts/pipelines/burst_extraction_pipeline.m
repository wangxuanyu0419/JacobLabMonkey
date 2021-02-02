% estimate bursts from normalized powerspectra data

close all
clear all

%% set root path
stdir = '/mnt/storage2/xuanyu/MONKEY/Non-ion'; % migrate data to the storage 2

%% compare input files and exist output files
inf = dir(fullfile(stdir,'2.Normalized','*.mat'));
outfolder = fullfile(stdir,'3.Bursts');
outf = dir(fullfile(outfolder,'*.mat'));
[f_name,f_list] = setdiff({inf.name},{outf.name});
f_path = inf(f_list).folder;

%% parallel processing for burst estimation
parfor i = 1:length(f_list)
    try
        burst_extraction(f_path,f_name{i},outfolder);
    catch e
        fprintf('\nWarning: Something wrong with Session %s: \n%s\n',f_title,e.message);
    end
end

