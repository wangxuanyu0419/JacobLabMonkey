function f = PlotSingleTrials_201120(data_prep,ntrl,nsess,chanidx,eTime)
    close all
    clear f

    filetitle = data_prep.cfg.dataset((end-17):(end-11));
    trlcode = sprintf('%d.%d',nsess,ntrl);
    
    f = figure;
    hold

    if isempty(chanidx)
        error('no channel specified');
    else
        for nchan = chanidx
            plot(data_prep.time{ntrl}, data_prep.trial{ntrl}(nchan,:), 'DisplayName',data_prep.label{nchan});
        end
        yl = [-600 600];
        plot([0 0],yl,'--k','HandleVisibility','off');
        plot(data_prep.time{ntrl}(eTime), data_prep.trial{ntrl}(nchan,eTime),'.','MarkerFaceColor','red', 'HandleVisibility','off');
        xlabel('time to reward [s]');
        xlim([-1.5 4]);
        ylim(yl);
        ylabel('LFP [uV]')
        lgd = legend;
        lgd.NumColumns = 2;
        lgd.Location = 'southeast';
        title(sprintf('%s, trial %d',filetitle, ntrl));
    end
    
    saveas(f,['/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/TrialScreening_201118/badtrials/',trlcode,'.png'],'png');
end