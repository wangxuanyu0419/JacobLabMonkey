% this function performs superlet transformation for selected trial
% and compared between SUPERLET and TFR
% averaged across electrodes: /code/Training/ft_superlet/across_electrode
% later added: in single channel
% example trial: 1.115

%% load the data_prep
strdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(strdir)
sesssel = fullfile('data','TrialScreening_201118','R120530.mat');
load(sesssel);

filename = data_prep.cfg.dataset((end-17):(end-11));
% trialsel = randi(250);
chansel = randi(12);
chancode = data_prep.label{chansel};

%% ft_processing cfg definition:
close all
f = figure('Position',[1 1 2560 1440]);

%% mtmconv
cfg_mtmconv.output = 'pow';
cfg_mtmconv.method = 'mtmconvol';
cfg_mtmconv.taper = 'hanning';
cfg_mtmconv.foi = 2.^(1:1/4:7);
cfg_mtmconv.t_ftimwin = 3./cfg_mtmconv.foi;
cfg_mtmconv.toi = -0.5:0.01:3;
cfg_mtmconv.pad = 'nextpow2';
% cfg_mtmconv.trials = trialsel;
cfg_mtmconv.channel = chancode;

data_freq_mtmconv = ft_freqanalysis(cfg_mtmconv,data_prep);

% plot the result
subplot(2,2,1);
ft_mat = squeeze(mean(data_freq_mtmconv.powspctrm,1));
contourf(cfg_mtmconv.toi,cfg_mtmconv.foi,ft_mat,40,'linestyle','none');
set(gca,'yscale','log','ylim',[2 128],'ytick',[2 4 8 16 32 64 128]);
title('MTMCONVOL');
colorbar
hold on
plot([0 0],[2 128],'--k');
plot([0.5 0.5],[2 128],'--k');
plot([1.5 1.5],[2 128],'--k');
plot([2 2],[2 128],'--k');

%% wavelet
cfg_wavelet.output = 'pow';
cfg_wavelet.method = 'wavelet';
cfg_wavelet.foi = 2:128;
cfg_wavelet.toi = -0.5:0.001:3;
cfg_wavelet.width = 3;
cfg_wavelet.gwidth = 3;
cfg_wavelet.pad = 'nextpow2';
% cfg_wavelet.trials = trialsel;
cfg_wavelet.channel = chancode;

data_freq_wavelet = ft_freqanalysis(cfg_wavelet,data_prep);

% plot the result
subplot(2,2,2);
ft_mat = squeeze(mean(data_freq_wavelet.powspctrm,1));
contourf(cfg_wavelet.toi,cfg_wavelet.foi,ft_mat,40,'linestyle','none');
set(gca,'yscale','log','ylim',[2 128],'ytick',[2 4 8 16 32 64 128]);
title('WAVELET');
colorbar
hold on
plot([0 0],[2 128],'--k');
plot([0.5 0.5],[2 128],'--k');
plot([1.5 1.5],[2 128],'--k');
plot([2 2],[2 128],'--k');

%% superlet
cfg_superlet.output = 'pow';
cfg_superlet.method = 'superlet';
cfg_superlet.foi = 2:128;
cfg_superlet.toi = -0.5:0.001:3;
cfg_superlet.superlet.basewidth = 3;
cfg_superlet.superlet.combine = 'additive';
cfg_superlet.superlet.order = round(linspace(1,30,numel(cfg_superlet.foi)));
cfg_superlet.z_ref_trls = -9:0; % standardization?
% cfg_superlet.trials = trialsel;
cfg_superlet.pad = 'nextpow2';
cfg_superlet.channel = chancode;

data_freq_superlet = ft_freqanalysis(cfg_superlet,data_prep);

% plot the result
subplot(2,2,3);
ft_mat = squeeze(mean(data_freq_superlet.powspctrm,1));
contourf(cfg_superlet.toi,cfg_superlet.foi,ft_mat,40,'linestyle','none');
set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
title('SUPERLET');
colorbar
hold on
plot([0 0],[2 128],'--k');
plot([0.5 0.5],[2 128],'--k');
plot([1.5 1.5],[2 128],'--k');
plot([2 2],[2 128],'--k');

%% TFR
cfg_tfr.output = 'pow';
cfg_tfr.method = 'wavelet';
cfg_tfr.foi = 2:128;
cfg_tfr.toi = -0.5:0.001:3;
cfg_tfr.width = 3;
cfg_tfr.gwidth = 3;
cfg_tfr.pad = 'nextpow2';
% cfg_tfr.trials = trialsel;
cfg_tfr.channel = chancode;

data_freq_tfr = ft_freqanalysis(cfg_tfr,data_prep);

% plot the result
subplot(2,2,4);
ft_mat = squeeze(mean(data_freq_tfr.powspctrm,1));
contourf(cfg_tfr.toi,cfg_tfr.foi,ft_mat,40,'linestyle','none');
set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
title('TFR');
colorbar
hold on
plot([0 0],[2 128],'--k');
plot([0.5 0.5],[2 128],'--k');
plot([1.5 1.5],[2 128],'--k');
plot([2 2],[2 128],'--k');

%%
% saveas(f,fullfile('code','Training','ft_superlet','single_electrode',sprintf('%s_%d_%s',filename,trialsel,chancode)),'png');
saveas(f,fullfile('code','Training','ft_superlet','single_electrode',sprintf('%s_AllTrl_%s',filename,chancode)),'png');
close(f)