close all
clear all

f = dir('/mnt/storage2/xuanyu/MONKEY/Non-ion/2.Normalized/*.mat');
f = f(arrayfun(@(x) ismember(x.name(1:12),{'R120516-AD01' 'R120516-AD09' 'R120516-AD10' 'R120516-AD11'}),f));


for i = 1:numel(f)
    fig = figure('Position',[900 -994 1280 723]);
    try
        load(fullfile(f(i).folder,f(i).name),'data_norm');
        for trl = [11 12 13]-3
            z = squeeze(data_norm.powspctrm_norm(trl,:,:));
            imagesc(data_norm.time,data_norm.freq,z.*(z>=2)); % threshold at 2 SD
            set(gca,'YDir','normal');
            xlabel('time from sample presentation [s]')
            xlim([-0.5 3.5]);
            ylabel('freq [Hz]')
            caxis([0 3.5]);
            colorbar
            arrayfun(@(x) line(ones(2,1)*x,ylim,'LineStyle','--'),[0 0.5 1.5 2 3]);
            title(sprintf('Power z-scored for trial %d, threshold 2, sess %s, Channel %s)',trl,f(i).name(1:7),f(i).name(9:12)));
            print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/2.Normalized',sprintf('%s_%03d',f(i).name(1:12),trl)),'-depsc');
        end
    end
    close all
end
