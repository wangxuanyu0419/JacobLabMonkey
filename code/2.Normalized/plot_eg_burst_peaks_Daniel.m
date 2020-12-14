close all
clear all

f = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/2.Normalized/*.mat');
f = f(arrayfun(@(x) ismember(x.name(1:12),{'R120516-AD01' 'R120516-AD09' 'R120516-AD10' 'R120516-AD11'}),f));
fx = dir('/mnt/storage3/daniel/monkey_bursts/nonDA/add_brst_ord3-30_4-100Hz/*.mat');
fx = fx(arrayfun(@(x) ismember(x.name(1:12),{'R120516_AD01' 'R120516_AD09' 'R120516_AD10' 'R120516_AD11'}),fx));


for i = 1:numel(f)
    load(fullfile(f(i).folder,f(i).name));
    load(fullfile(fx(i).folder,fx(i).name));
    for j = [19 20 21]
        fig = figure('Position',[900 -994 1280 723]);
        hold on
        trl = j-3;
        z = squeeze(data_norm.powspctrm_norm(trl,:,:));
        imagesc(data_norm.time,data_norm.freq,z.*(z>=1.5)); % threshold at 2 SD
        
        dm = pow.trialinfo.bursts{j,1};
        scatter(dm.t,dm.f,'MarkerFaceColor','r');
        
        set(gca,'YDir','normal');
        xlabel('time from sample presentation [s]')
        xlim([-0.5 3.5]);
        ylabel('freq [Hz]')
        ylim([4 100]);
        caxis([0 3.5]);
        colorbar
        arrayfun(@(x) line(ones(2,1)*x,ylim,'LineStyle','--'),[0 0.5 1.5 2 3]);
        title(sprintf('Trial %d, threshold 1.5, sess %s, Channel %s, plotted against Daniel bursts',trl,f(i).name(1:7),f(i).name(9:12)));

        print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/2.Normalized',sprintf('%s_%03d_D',f(i).name(1:12),trl)),'-depsc');
        close all
    end
end