% this function performs superlet transformation for selected trial
% and compared between electrodes
% example trial randomly chosen

%% load the data_prep
strdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(strdir)
sesssel = fullfile('data','TrialScreening_201118','R120530.mat');
load(sesssel);

filename = data_prep.cfg.dataset((end-17):(end-11));
trialsel = randi(250);

%%
close all
f = figure('Position',[1 1 2560 1440]);

%% superlet
cfg_superlet.output = 'pow';
cfg_superlet.method = 'superlet';
cfg_superlet.foi = 20:120;
cfg_superlet.toi = -0.5:0.001:3;
cfg_superlet.superlet.basewidth = 3;
cfg_superlet.superlet.combine = 'additive';
cfg_superlet.superlet.order = round(linspace(1,30,numel(cfg_superlet.foi)));
% cfg_superlet.z_ref_trls = -9:0; % standardization?
cfg_superlet.trials = trialsel;
cfg_superlet.pad = 'nextpow2';

for ichan = 1:length(data_prep.label)
    chancode = data_prep.label{ichan};
    cfg_superlet.channel = chancode;
    data_freq = ft_freqanalysis(cfg_superlet,data_prep);
    
    % plot the result
    subplot(4,4,ichan);
    ft_mat = squeeze(mean(data_freq.powspctrm,1));
    ft_mat_norm{ichan} = ft_mat.*repmat(cfg_superlet.foi',1,length(cfg_superlet.toi));
    contourf(cfg_superlet.toi,cfg_superlet.foi,ft_mat_norm{ichan},40,'linestyle','none');
%     set(gca,'yscale','log','ytick',[2 4 8 16 32 64 128]);
    title(chancode);
%     colorbar
    hold on
    plot([0 0],[2 128],'--r','linewidth',2);
    plot([0.5 0.5],[2 128],'--r','linewidth',2);
    plot([1.5 1.5],[2 128],'--r','linewidth',2);
    plot([2 2],[2 128],'--r','linewidth',2);
    ylim([20 120]);
end
%%
saveas(f,fullfile('code','Training','ft_superlet','compare_electrode',sprintf('%s_%d_norm',filename,trialsel)),'png');
% saveas(f,fullfile('code','Training','ft_superlet','compare_electrode',sprintf('%s_AllTrl_norm',filename)),'png');
close(f)