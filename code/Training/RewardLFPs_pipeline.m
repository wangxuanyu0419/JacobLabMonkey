% This script is for learning basic fieldtrip processings. The goal is to
% get power plots aligned to reward in test trials (excluding free reward
% condition).

close all
clear all

% Example trial definition:
filename = 'C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\raw_nex\R120410-03_lfp.nex';

%% trialfun: segment trials
cfg_deftrl = [];
cfg_deftrl.dataset = filename;
cfg_deftrl.trialfun = 'trialfun_training';
cfg_deftrl.trialdef.eventtype = 'Strobed*'; % first 7 characters are compared
cfg_deftrl.trialdef.eventvalue = 3; % analysis starting/aligned point; reward code, 3; sample onset, 25;
cfg_deftrl.trialdef.pretrl = 1; % unit: second
cfg_deftrl.trialdef.posttrl = 2;
cfg_deftrl.trialdef.triallen = 0;
cfg_deftrl.trialdef.errorcode = 0; % 0, correct; 1, missing; 6, mistake; nan: no-specification;
cfg_deftrl.trialdef.stimtype = nan; % nan: no-specification; 0, standard; 1, controlled;
cfg_deftrl.trialdef.sampnum = nan; % sample numerosity: 1-4; nan: no-specification;
cfg_deftrl.trialdef.distnum = nan; % distractor numerosity: 1-4; nan: no-specification;

%% preprocessing: 
cfg_preproc = ft_definetrial(cfg_deftrl);

data_prep = ft_preprocessing(cfg_preproc);

%% ERP by Channel:
% close all
% ERPs = zeros(size(data_prep.trial{1}));
% chanlabel = data_prep.label;
% 
% for trl = 1:numel(data_prep.trial)
%     ERPs = ERPs + data_prep.trial{trl};
% end
% ERPs = ERPs / numel(data_prep.trial);
% 
% f = figure('Position',[1 1 2560 1440],'Visible',true,'Tag','Main');
ftitle = filename((end-17):(end-11));
% 
% for i = 1:16
%     % plot each subplot
%     subplot(4,4,i)
%     chantgt = sprintf('AD%02d',i);
%     chanidx = find(strcmp(chanlabel,chantgt));
%     if isempty(chanidx)
%         continue
%     else
%         hold
%         plot(data_prep.time{1}, ERPs(chanidx,:));
%         yl = ylim;
%         plot([0 0],yl,'--k');
%         if i < 9
%             title([chantgt ' PFC']);
%         else
%             title([chantgt ' VIP']);
%         end
%         xlabel('time to reward [s]');
%         ylabel('Event-Related Potential [uV]')
%     end
% end
% saveas(f,fullfile('ERPs',[ftitle '_reward']),'png');
% save(fullfile('ERPs','ERPs'),'ERPs');
% close

%% Visualization of the raw data
% cfg_vis = [];
% cfg_vis.viewmode = 'vertical';
% cfg_vis.continuous = 'no';
% cfg_brows = ft_databrowser(cfg_vis,data_prep);

%% spectral analysis:
clear cfg_spect

cfg_spect.output = 'pow';
cfg_spect.method = 'mtmconvol';
cfg_spect.taper = 'hanning';
cfg_spect.foi = 2.^(1:1/4:8);
cfg_spect.t_ftimwin = 3./cfg_spect.foi;
cfg_spect.toi = -0.5:0.01:1.5;
cfg_spect.pad = 'nextpow2';

% cfg_spect.output = 'pow';
% cfg_spect.method = 'mtmfft';
% cfg_spect.pad = 'nextpow2';
% cfg_spect.taper = 'dpss';
% cfg_spect.foi = [1:128];
% cfg_spect.tapsmofrq = [2]; % for fft;
% cfg_spect.t_ftimwin = 0.5 ./ cfg_spect.foi; % for convol
% cfg_spect.toi = -0.5:0.001:1.5;

data_freq = ft_freqanalysis(cfg_spect,data_prep);

% save('data_training_reward','data_prep','data_freq')
% f = figure('Position',[1 1 2560 1440],'Visible',true,'Tag','Main');
% for i = 27:42
%     subplot(4,4,(i-26));
%     loglog(data_freq.powspctrm(i,:))
%     title(sprintf('Channel %d %s',i,data_prep.label{i}));
%     xlabel('frequency [Hz]')
%     ylabel('power')
% end
% saveas(f,'Power Spectra example','png')

%% inspect data
% xx(:,:) = data_freq.powspctrm(27,:,:);


%% baseline correction:
cfg_baseline = [];
cfg_baseline.baseline = [-0.5 0];
cfg_baseline.baselinetype = 'db';

data_blcorr = ft_freqbaseline(cfg_baseline,data_freq);

%% plot the result
% close all
% 
% cfg_plot = [];
% cfg_plot.channel = {'AD*'};
% cfg_plot.xlim = [-1 2];
% 
% figure
% ft_singleplotTFR(cfg_plot,data_freq);

%% plot time frequency spectra
close all
clear cfg_plot
PFC = {'AD01','AD02','AD03','AD04','AD05','AD06','AD07','AD08'};
VIP = {'AD09','AD10','AD11','AD12','AD13','AD14','AD15','AD16'};

% plot all channels
cfg_plot = [];
cfg_plot.channel = {'AD*'};
cfg_plot.xlim = [-1 2];
cfg_plot.ylim = [2 128];
f = figure
ft_singleplotTFR(cfg_plot,data_freq);
saveas(f,fullfile('Powerplots',[ftitle '_reward']),'png');

% plot PFC channels
cfg_plot_PFC = [];
cfg_plot_PFC.channel = PFC;
cfg_plot_PFC.xlim = [-1 2];
cfg_plot_PFC.ylim = [2 128];
f_PFC = figure
ft_singleplotTFR(cfg_plot_PFC,data_freq);
saveas(f_PFC,fullfile('Powerplots',[ftitle '_reward_PFC']),'png');

% plot VIP channels
cfg_plot_VIP = [];
cfg_plot_VIP.channel = VIP;
cfg_plot_VIP.xlim = [-1 2];
cfg_plot_VIP.ylim = [2 128];
f_VIP = figure
ft_singleplotTFR(cfg_plot_VIP,data_freq);
saveas(f_VIP,fullfile('Powerplots',[ftitle '_reward_VIP']),'png');

close all
