function plot_example(data,filename)

close all
strdir = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey';
cd(strdir)

% plot the result of trial average
f1 = figure('Position',[1 1 2560 1440]);
ft_mat = squeeze(mean(data.powspctrm_norm,1));
for ichan = 1:length(data.label)
    subplot(4,4,ichan);
    ft_mat_chan = squeeze(ft_mat(ichan,:,:));
    contourf(data.cfg.toi,data.cfg.foi,ft_mat_chan,40,'linestyle','none');
    zlims = caxis;
    caxis([0 zlims(2)]);
    title(data.label{ichan});
    colorbar
    hold on
    plot([0 0],[4 100],'--r','linewidth',2);
    plot([0.5 0.5],[4 100],'--r','linewidth',2);
    plot([1.5 1.5],[4 100],'--r','linewidth',2);
    plot([2 2],[4 100],'--r','linewidth',2);
    ylim([4 100]);
end
saveas(f1,fullfile('data','1.Preprocessing','plot_example',sprintf('%s_trlavg',filename)),'png');
close(f1)

% plot the result of example trials
for i = 1:3
    f2 = figure('Position',[1 1 2560 1440]);
    trialsel = randi(250);
    ft_mat = squeeze(data.powspctrm_norm(trialsel,:,:,:));
    for ichan = 1:length(data.label)
        subplot(4,4,ichan);
        ft_mat_chan = squeeze(ft_mat(ichan,:,:));
        contourf(data.cfg.toi,data.cfg.foi,ft_mat_chan,40,'linestyle','none');
        zlims = caxis;
        caxis([0 zlims(2)]);
        title(data.label{ichan});
        colorbar
        hold on
        plot([0 0],[4 100],'--r','linewidth',2);
        plot([0.5 0.5],[4 100],'--r','linewidth',2);
        plot([1.5 1.5],[4 100],'--r','linewidth',2);
        plot([2 2],[4 100],'--r','linewidth',2);
        ylim([4 100]);
    end
    saveas(f2,fullfile('data','1.Preprocessing','plot_example',sprintf('%s_%d',filename,trialsel)),'png');
    close(f2)
end

