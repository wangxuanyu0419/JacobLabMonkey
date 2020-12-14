f = dir('/mnt/storage3/daniel/monkey_bursts/nonDA/preproc/*.mat');
f = f(arrayfun(@(x) ismember(x.name(1:12),{'R120516_AD01' 'R120516_AD09' 'R120516_AD10' 'R120516_AD11'}),f));
fig = figure('Position',[900 -994 1280 723]);
for i = 1:numel(f)
    load(fullfile(f(i).folder,f(i).name));
    z = bsxfun(@rdivide,bsxfun(@minus,pow.powspctrm,mean(pow.powspctrm,4)),std(pow.powspctrm,[],4));
    for trl = [11 12 13]
        z = squeeze(z(trl,1,:,:));
        imagesc(pow.time, pow.freq, z.*(z>2));
        set(gca,'YDir','normal');
        xlabel('time from sample presentation [s]')
        ylabel('freq [Hz]')
        caxis([0 6]);
        colorbar
        arrayfun(@(x) line(ones(2,1)*x,ylim,'LineStyle','--'),[0 0.5 1.5 2 3])
        title(sprintf('Power z-scored across trial time, threshold z>=2, sess %s, trial %d',f(i).folder(end-6:end),i));
        print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/2.Normalized',sprintf('%s_%03d',f(i).name(1:12),trl)),'-depsc');
    end
end
