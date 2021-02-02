%% plot example AD01/09/10/11 channel average traces for example session R120516
% all conditions, cond-num = 12
% manual load of burst_stat

adlist = [1 8 9 10];

nfband = length(data_stat.fband);

for iad = adlist
    close all
    adlabel = data_stat.label{iad};
    
    fig = figure('Position',[50 50 1280 720], 'Visible', true);
    ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]); % figure window
    hold(ax,'on');
    
    % plot rate, all conditions
    arrayfun(@(x) plot(ax,data_stat.time,data_stat.rate_bands{iad,x}{12}), 1:nfband);
    % add legend
    fbandstr = cellfun(@(x) sprintf('%02d-%02dHz',min(x),max(x)), data_stat.fband, 'uni', 0);
    legend(ax,fbandstr);
    
    ylimdef = ylim(ax);
    
    % add trial epoch lines
    arrayfun(@(x) line(ax, ones(2,1)*x, [0,1],'LineStyle','--','Color','k','HandleVisibility','off'),[0 0.5 1.5 2 3]);
    set(ax,'ylim',ylimdef);
    
    % change appearance
    xlim([-0.5,3.2]);
    
    % add description
    title(ax,sprintf('R120516, Chan %s, all conditions',adlabel));
    xlabel(ax,'time from sample onset [s]');
    ylabel(ax,'burst rate');
    
    str1 = sprintf('trials:\n  correct\n  saturation in [-0.5 3]s excluded\n  all conditions\n');
    str2 = sprintf('spectral estimation: adaptive additive superlets\n  4-100Hz\n  min 3 cycles, order 30\n');
    str3 = sprintf('burst extraction:\n  fit rotated 2D Gaussians\n  only bursts with width >= 1 cycle accepted\n');
    strall = {str1,str2,str3};
    annotation(fig,'textbox',[0 0 1 1],'String',strall,'EdgeColor','none');
    
    % save figure
    print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/4.BurstStat/Rate',sprintf('R120516_%s_%s',adlabel,'All')),'-dpng');
end

%% plot example AD01/09/10/11 channel average traces for example session R120516
% other conditions, cond-num = 1-11
% manual load of burst_stat
for icond = 1:11
    condname = data_stat.condname{icond};
    for iad = adlist
        close all
        adlabel = data_stat.label{iad};
        
        fig = figure('Position',[50 50 1280 720], 'Visible', true);
        ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]); % figure window
        hold(ax,'on');
        
        % plot rate, all conditions
        arrayfun(@(x) plot(ax,data_stat.time,data_stat.rate_bands{iad,x}{icond}), 1:nfband);
        % add legend
        fbandstr = cellfun(@(x) sprintf('%02d-%02dHz',min(x),max(x)), data_stat.fband, 'uni', 0);
        legend(ax,fbandstr);
    
        % change appearance
        xlim([-0.5,3.2]);
        ylimdef = ylim(ax);
        
        % add trial epoch lines
        arrayfun(@(x) line(ax, ones(2,1)*x, [0,1],'LineStyle','--','Color','k','HandleVisibility','off'),[0 0.5 1.5 2 3]);
        set(ax,'ylim',ylimdef);
        
        % add description
        title(ax,sprintf('R120516, Chan %s, %s',adlabel, condname));
        xlabel(ax,'time from sample onset [s]');
        ylabel(ax,'burst rate');
        
        str1 = sprintf('trials:\n  correct\n  saturation in [-0.5 3]s excluded\n  condition %s\n', condname);
        str2 = sprintf('spectral estimation: adaptive additive superlets\n  4-100Hz\n  min 3 cycles, order 30\n');
        str3 = sprintf('burst extraction:\n  fit rotated 2D Gaussians\n  only bursts with width >= 1 cycle accepted\n');
        strall = {str1,str2,str3};
        annotation(fig,'textbox',[0 0 1 1],'String',strall,'EdgeColor','none');
        
        % save figure
        print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/4.BurstStat/Rate',sprintf('R120516_%s_%s',adlabel,condname)),'-dpng');
    end
end


%% plot average burst rate across region PFC and VIP for example session R120516
% manual load of burst_stat
adlistPFC = arrayfun(@(x) sprintf('AD%02d',x),1:8, 'uni',0);
adn = 1:16;
adPFClog = cellfun(@(x) ismember(x,adlistPFC), data_stat.label);
adPFC = adn(adPFClog);
adVIP = adn(~adPFClog);

c(1,:) = [0 0 0.8];
c(2,:) = [0.8 0 0];
c(3,:) = [0 0.6 0];


nfband = length(data_stat.fband);

%% plot PFC rate
close all
fig = figure('Position',[50 50 1280 720], 'Visible', true);
ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]); % figure window
hold(ax,'on');

% plot rate, all conditions
ratePFCChan = cellfun(@(x) x{12}, data_stat.rate_bands(adPFC,1:nfband), 'uni',0);
ratePFCmean = arrayfun(@(x) nanmean(cell2mat(ratePFCChan(:,x)'),2), 1:nfband, 'uni',0);
ratePFCSD = arrayfun(@(x) nanstd(cell2mat(ratePFCChan(:,x)'),0,2), 1:nfband, 'uni',0);
arrayfun(@(x) plot(ax,data_stat.time,ratePFCmean{1,x},'Color',c(x,:)), 1:nfband);
arrayfun(@(x) fill(ax,[data_stat.time,fliplr(data_stat.time)],[ratePFCmean{1,x}-ratePFCSD{1,x};fliplr(ratePFCmean{1,x}+ratePFCSD{1,x})]',c(x,:),'EdgeColor','none','FaceAlpha',0.2), 1:nfband);

% add legend
fbandstr = cellfun(@(x) sprintf('%02d-%02dHz',min(x),max(x)), data_stat.fband, 'uni', 0);
legend(ax,fbandstr);

    
% change appearance
xlim([-0.5,3.2]);
ylimdef = ylim(ax);

% add trial epoch lines
arrayfun(@(x) line(ax, ones(2,1)*x, [0,1],'LineStyle','--','Color','k','HandleVisibility','off'),[0 0.5 1.5 2 3]);
set(ax,'ylim',ylimdef);

% add description
title(ax,'R120516, PFC average, all conditions');
xlabel(ax,'time from sample onset [s]');
ylabel(ax,'average burst rate');

str1 = sprintf('trials:\n  correct\n  saturation in [-0.5 3]s excluded\n  all conditions\n');
str2 = sprintf('spectral estimation: adaptive additive superlets\n  4-100Hz\n  min 3 cycles, order 30\n');
str3 = sprintf('burst extraction:\n  fit rotated 2D Gaussians\n  only bursts with width >= 1 cycle accepted\n');
strall = {str1,str2,str3};
annotation(fig,'textbox',[0 0 1 1],'String',strall,'EdgeColor','none');

% save figure
print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/4.BurstStat/Rate',sprintf('R120516_%s_%s','PFC','All')),'-dpng');

%% plot PFC width
close all
fig = figure('Position',[50 50 1280 720], 'Visible', true);
ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]); % figure window
hold(ax,'on');

% plot rate, all conditions
widthPFCChan = cellfun(@(x) x{12}, data_stat.width_bands(adPFC,1:nfband), 'uni',0);
widthPFCmean = arrayfun(@(x) nanmean(cell2mat(widthPFCChan(:,x)'),2), 1:nfband, 'uni',0);
widthPFCSD = arrayfun(@(x) nanstd(cell2mat(widthPFCChan(:,x)'),0,2), 1:nfband, 'uni',0);
arrayfun(@(x) plot(ax,data_stat.time,widthPFCmean{1,x}','Color',c(x,:)), 1:nfband);
arrayfun(@(x) fill(ax,[data_stat.time,fliplr(data_stat.time)],[widthPFCmean{1,x}-widthPFCSD{1,x};fliplr(widthPFCmean{1,x}+widthPFCSD{1,x})]',c(x,:),'EdgeColor','none','FaceAlpha',0.2), 1:nfband);

% add legend
fbandstr = cellfun(@(x) sprintf('%02d-%02dHz',min(x),max(x)), data_stat.fband, 'uni', 0);
legend(ax,fbandstr);

% change appearance
xlim([-0.5,3.2]);
ylimdef = ylim(ax);

% add trial epoch lines
arrayfun(@(x) line(ax, ones(2,1)*x, [0,2*ylimdef(2)],'LineStyle','--','Color','k','HandleVisibility','off'),[0 0.5 1.5 2 3]);
set(ax,'ylim',ylimdef);

% add description
title(ax,'R120516, PFC average, all conditions');
xlabel(ax,'time from sample onset [s]');
ylabel(ax,'average burst width [n_{cycle}]');

str1 = sprintf('trials:\n  correct\n  saturation in [-0.5 3]s excluded\n  all conditions\n');
str2 = sprintf('spectral estimation: adaptive additive superlets\n  4-100Hz\n  min 3 cycles, order 30\n');
str3 = sprintf('burst extraction:\n  fit rotated 2D Gaussians\n  only bursts with width >= 1 cycle accepted\n');
strall = {str1,str2,str3};
annotation(fig,'textbox',[0 0 1 1],'String',strall,'EdgeColor','none');

% save figure
print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/4.BurstStat/Width',sprintf('R120516_%s_%s','PFC','All')),'-dpng');

%% plot PFC amplitude
close all
fig = figure('Position',[50 50 1280 720], 'Visible', true);
ax = axes(fig,'Position', [0.3 0.11 0.655 0.815]); % figure window
hold(ax,'on');

% plot rate, all conditions
ampPFCChan = cellfun(@(x) x{12}, data_stat.amp_bands(adPFC,1:nfband), 'uni',0);
ampPFCmean = arrayfun(@(x) nanmean(cell2mat(ampPFCChan(:,x)'),2), 1:nfband, 'uni',0);
ampPFCstd = arrayfun(@(x) nanstd(cell2mat(ampPFCChan(:,x)'),0,2), 1:nfband, 'uni',0);
arrayfun(@(x) plot(ax,data_stat.time,ampPFCmean{1,x},'Color',c(x,:)), 1:nfband);

% add legend
fbandstr = cellfun(@(x) sprintf('%02d-%02dHz',min(x),max(x)), data_stat.fband, 'uni', 0);
legend(ax,fbandstr);

% change appearance
xlim([-0.5,3.2]);
ylimdef = ylim(ax);

% add trial epoch lines
arrayfun(@(x) line(ax, ones(2,1)*x, [0,2*ylimdef(2)],'LineStyle','--','Color','k','HandleVisibility','off'),[0 0.5 1.5 2 3]);
set(ax,'ylim',ylimdef);

% add description
title(ax,'R120516, PFC average, all conditions');
xlabel(ax,'time from sample onset [s]');
ylabel(ax,'average burst amplitude [z]');

str1 = sprintf('trials:\n  correct\n  saturation in [-0.5 3]s excluded\n  all conditions\n');
str2 = sprintf('spectral estimation: adaptive additive superlets\n  4-100Hz\n  min 3 cycles, order 30\n');
str3 = sprintf('burst extraction:\n  fit rotated 2D Gaussians\n  only bursts with width >= 1 cycle accepted\n');
strall = {str1,str2,str3};
annotation(fig,'textbox',[0 0 1 1],'String',strall,'EdgeColor','none');

% save figure
print(gcf,fullfile('/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/4.BurstStat/Amplitude',sprintf('R120516_%s_%s','PFC','All')),'-dpng');

