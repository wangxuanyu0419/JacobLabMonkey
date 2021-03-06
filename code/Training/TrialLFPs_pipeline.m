% This script is for learning basic fieldtrip processings. The goal is to
% get power plots aligned to sample onset in correct trials (excluding free reward
% condition).

close all
clear all

% Example trial definition:
% filename = 'C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\raw_nex\R120410-03_lfp.nex';
filename = 'C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\raw_nex\R120508-02_lfp.nex'; % missing channel

%% trialfun: segment trials
cfg_deftrl = [];
cfg_deftrl.dataset = filename;
cfg_deftrl.trialfun = 'trialfun_training';
cfg_deftrl.trialdef.eventtype = 'Strobed*'; % first 7 characters are compared
cfg_deftrl.trialdef.eventvalue = 25; % analysis starting/aligned point; reward code, 3; sample onset, 25;
cfg_deftrl.trialdef.pretrl = 1.5; % unit: second
cfg_deftrl.trialdef.posttrl = 1;
cfg_deftrl.trialdef.triallen = 3;
cfg_deftrl.trialdef.errorcode = 0; % 0, correct; 1, missing; 6, mistake; nan: no-specification;
cfg_deftrl.trialdef.stimtype = nan; % nan: no-specification; 0, standard; 1, controlled;
cfg_deftrl.trialdef.sampnum = nan; % sample numerosity: 1-4; nan: no-specification;
cfg_deftrl.trialdef.distnum = nan; % distractor numerosity: 1-4; nan: no-specification;

%% preprocessing: 
cfg_preproc = ft_definetrial(cfg_deftrl);

data_prep = ft_preprocessing(cfg_preproc);

%% ERP by Channel:
close all
ERPs = zeros(size(data_prep.trial{1}));
chanlabel = data_prep.label;

for trl = 1:numel(data_prep.trial)
    ERPs = ERPs + data_prep.trial{trl};
end
ERPs = ERPs / numel(data_prep.trial);

f = figure('Position',[1 1 2560 1440],'Visible',true,'Tag','Main');
ftitle = filename((end-17):(end-11));

for i = 1:16
    % plot each subplot
    subplot(4,4,i)
    chantgt = sprintf('AD%02d',i);
    chanidx = find(strcmp(chanlabel,chantgt));
    if isempty(chanidx)
        continue
    else
        hold
        plot(data_prep.time{1}, ERPs(chanidx,:));
        yl = ylim;
        plot([0 0],yl,'--k');
        if i < 9
            title([chantgt ' PFC']);
        else
            title([chantgt ' VIP']);
        end
        xlabel('time to reward [s]');
        xlim([-0.5 3]);
        ylabel('Event-Related Potential [uV]')
        set(gca, 'YDir','reverse')
    end
end
saveas(f,fullfile('ERPs',[ftitle '_trial']),'png');
save(fullfile('ERPs',[ftitle 'ERPs_trial']),'ERPs');
close

%% Visualization of the raw data
% cfg_vis = [];
% cfg_vis.viewmode = 'vertical';
% cfg_vis.continuous = 'no';
% cfg_brows = ft_databrowser(cfg_vis,data_prep);

%% spectral analysis:
cfg_spect.output = 'pow';
cfg_spect.method = 'mtmconvol';
cfg_spect.taper = 'hanning';
cfg_spect.foi = 2.^(1:1/4:8);
cfg_spect.t_ftimwin = 3./cfg_spect.foi;
cfg_spect.toi = -0.5:0.01:3;
cfg_spect.pad = 'nextpow2';

data_freq = ft_freqanalysis(cfg_spect,data_prep);

save(['data_' ftitle '_trial'],'data_prep','data_freq')

%% inspect data
xx(:,:) = data_freq.powspctrm(27,:,:);


%% baseline correction:
cfg_baseline = [];
cfg_baseline.baseline = [-0.5 0];
cfg_baseline.baselinetype = 'db';

data_blcorr = ft_freqbaseline(cfg_baseline,data_freq);

%% plot the result
close all
PFC = {'AD01','AD02','AD03','AD04','AD05','AD06','AD07','AD08'};
VIP = {'AD09','AD10','AD11','AD12','AD13','AD14','AD15','AD16'};

% plot all channels
cfg_plot = [];
cfg_plot.channel = {'AD*'};
cfg_plot.xlim = [-0.5 3];
cfg_plot.ylim = [0 128];
cfg_plot.title = [ftitle ' All Channels'];
f = figure
ft_singleplotTFR(cfg_plot,data_freq);
saveas(f,fullfile('Powerplots',[ftitle '_trial']),'png');

% plot PFC channels
cfg_plot_PFC = [];
cfg_plot_PFC.channel = PFC;
cfg_plot_PFC.xlim = [-0.5 3];
cfg_plot_PFC.ylim = [0 128];
cfg_plot.title = [ftitle ' PFC'];
f_PFC = figure
ft_singleplotTFR(cfg_plot_PFC,data_freq);
saveas(f_PFC,fullfile('Powerplots',[ftitle '_trial_PFC']),'png');

% plot VIP channels
cfg_plot_VIP = [];
cfg_plot_VIP.channel = VIP;
cfg_plot_VIP.xlim = [-0.5 3];
cfg_plot_VIP.ylim = [0 128];
cfg_plot.title = [ftitle ' VIP'];
f_VIP = figure
ft_singleplotTFR(cfg_plot_VIP,data_freq);
saveas(f_VIP,fullfile('Powerplots',[ftitle '_trial_VIP']),'png');

close all
