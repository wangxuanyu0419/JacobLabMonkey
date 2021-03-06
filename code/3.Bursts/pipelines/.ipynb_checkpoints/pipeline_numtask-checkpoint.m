f = dir('/mnt/share/DANIEL/MONKEYS_DISTRACTOR/data/20160202-ALL/TD/preprocessed/**/*.mat');
f = f(arrayfun(@(x) ~contains(x.folder,'spike'),f));
for i_f = 1:numel(f)
    lfp = loadmat_singlevar(fullfile(f(i_f).folder, f(i_f).name));
    trialerror = numeric_to_categorical_trialerror(lfp.response_err);
    lfp.trialinfo = table(...
        trialerror,...
        lfp.cnds(:,1),...
        lfp.cnds(:,2),...
        lfp.cnds(:,3),...
        'VariableNames', {'trialerror', 'sample', 'distractor', 'test'},...
        'RowNames', arrayfun(@num2str, 1:numel(trialerror), 'uni', 0));
    lfp = remove_non_ft_fields(lfp);
    % split channels
    cfg = [];
    for i_ch = 1:numel(lfp.label)
        cfg.channel = lfp.label{i_ch};
        cfg.outputfile = sprintf('/mnt/storage3/daniel/nonDA/preproc/%s_%s.mat', f(i_f).name(1:7), lfp.label{i_ch});
        ft_selectdata(cfg, lfp);
    end
end

%% compute power via superlet method 
delete(gcp('nocreate'))
parpool(32)
f = dir('/mnt/storage3/daniel/nonDA/preproc/*.mat');
save_folder = '/mnt/storage3/daniel/nonDA/add_brst_ord3-30_4-100Hz';
cfg = [];
cfg.saturation                  = 250;
cfg.specest.method              = 'superlet';
cfg.specest.output              = 'pow';
cfg.specest.channel             = 'all';
cfg.specest.trials              = 'all';
cfg.specest.keeptrials          = 'yes';
cfg.specest.pad                 = 'nextpow2';
cfg.specest.padtype             = 'zero';
cfg.specest.polyremoval         = 0;
cfg.specest.foi                 = 4:100;
cfg.specest.toi                 = -1.0:0.001:3.6;
cfg.specest.superlet.basewidth  = 3;
cfg.specest.superlet.combine    = 'additive';
cfg.specest.superlet.order      = round(linspace(1,30,numel(cfg.specest.foi)));
cfg.z_ref_trls = -9:0;
cfg.savefolder = save_folder;

parfor isess = 1:numel(f)
    try
        burst_wrapper(fullfile(f(isess).folder, f(isess).name), cfg);
    catch
        fprintf(fullfile(f(isess).folder, f(isess).name))
    end
end

%% burst metrics
mat = dir('/mnt/storage3/daniel/nonDA/add_brst_ord3-30_4-100Hz/*.mat');
regions(1).name = 'PFC';
regions(1).mat = mat(arrayfun(@(x) ~isempty(regexp(x.name, '.*AD0[1-8].*')), mat));
regions(2).name = 'VIP';
regions(2).mat = mat(arrayfun(@(x) ~isempty(regexp(x.name,'.*AD(09|1[0-6]).*')),mat));
%% calculate and plot burst rates per electrode
figtext = [...
    newline, 'trials: ',...
    newline, '  correct',...
    newline, '  max 0.1% saturated voltage within [-0.5 3.1]',...
    newline, 'spectral estim.: adaptive additive superlets',...
    newline, '  4-100 Hz',...
    newline, '  min 3 cycles, order 30',...
    newline, 'burst extraction:',...
    newline, '  fit rotated 2D Gaussians',...
    newline, '  only bursts with width >= 1 cycle',...
    newline, ...
    newline, 'Lundqvist used',...
    newline, '  specest: multitaper',...
    newline, '  burstextr: fit non-rotated Gaussians'...
    ];
f_bands = ...
    [4 10;...
    20 35;...
    50 90];
br_text = {...
    'accumulated burst rate', ...
    'binary burst rate'};
br_subfold = {...
    'accum',...
    'binary'};
measures = struct('text',br_text,'subfold',br_subfold,'ylim',{[0 0.4],[0 0.4]});
stats = struct('append', {'', 'mean_elec'}, 'tag', {'burst rate individual electrodes','burst rate mean across electrodes +- sd'});
for i_region = 1:numel(regions)
    burstmetric_computation_plotting(...
        regions(i_region).mat,...
        @accum_burstrate,...
        @count_brst,...
        '/home/daniel/DBH/Git/LFP_DA/prototyping/numconditions',...
        strcat('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200109_burst_rate/', regions(i_region).name),...
        figtext,...
        f_bands,...
        measures,...
        stats);
end
% exclude electrodes with less than 50 trials from mean plots
min_trl = 50;
f = dir('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200109_burst_rate/**/*mean*.fig');
for i = 1:numel(f)
    fig = openfig(fullfile(f(i).folder,f(i).name));
    meanburstmetric_plot_mintrl(fig,min_trl);
    print(fig,fullfile(f(i).folder,strrep(f(i).name(2:end),'fig','eps')), '-depsc');
    close all
end
% overlap numerosities in plots
burstmetric_overlap(f, min_trl)

%% burst widths
%% calculate and plot burst widths per electrode
figtext = [...
    newline, 'trials: ',...
    newline, '  correct',...
    newline, '  max 0.1% saturated voltage within [-0.5 3.1]',...
    newline, 'spectral estim.: adaptive additive superlets',...
    newline, '  4-100 Hz',...
    newline, '  min 3 cycles, order 30',...
    newline, 'burst extraction:',...
    newline, '  fit rotated 2D Gaussians',...
    newline, '  only bursts with width >= 1 cycle',...
    newline, ...
    newline, 'Lundqvist used',...
    newline, '  specest: multitaper',...
    newline, '  burstextr: fit non-rotated Gaussians'...
    ];
f_bands = ...
    [4 10;...
    20 35;...
    50 90];
measures = struct('text',{'burst width [s]', 'burst width [n_{cycles}]'},'subfold',{'sec', 'cyc'},'ylim',{[0 0.3], [0 3.5]});
stats = struct('append', {'', 'mean_elec'}, 'tag', {'burst width individual electrodes','burst width mean across electrodes +- sd'});
for i_region = 1:numel(regions)
    burstmetric_computation_plotting(...
        regions(i_region).mat,...
        @accum_burstproperty,...
        @burst_width,...
        '/home/daniel/DBH/Git/LFP_DA/prototyping/numconditions',...
        strcat('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200110-burst_width/', regions(i_region).name),...
        figtext,...
        f_bands,...
        measures,...
        stats);
end
% exclude electrodes with less than 50 trials from mean plots
min_trl = 50;
f = dir('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200110-burst_width/**/*mean*.fig');
for i = 1:numel(f)
    fig = openfig(fullfile(f(i).folder,f(i).name));
    meanburstmetric_plot_mintrl(fig,min_trl);
    print(fig,fullfile(f(i).folder,strrep(f(i).name(2:end),'fig','eps')), '-depsc');
    close all
end
% overlap numerosities in plots
burstmetric_overlap(f, min_trl)

% split plots by frequency band
ylims = [...
    0.1 0.3; ...
    0.05 0.1; ...
    0.03 0.05];
frq = struct(...
    'band', mat2cell(f_bands,ones(size(f_bands,1),1),2), ...
    'ylim', mat2cell(ylims,ones(size(ylims,1),1),2));
f = dir('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200110-burst_width/*/sec/**/*mean*.fig');
for i_f = 1:numel(f)
    fig = openfig(fullfile(f(i_f).folder,f(i_f).name));
    if ~isempty(regexp(f(i_f).name,'(mean|overlap)'))
        % apply min trl criterion
        meanburstmetric_plot_mintrl(fig,min_trl);
    else
        % re-set the transparency of individual electrodes' traces
        ln = findobj(fig,'Type','Line','-regexp','DisplayName','.');
        arrayfun(@(x) set(x,'Color', [x.Color 0.05]),ln);
    end

    figs = fig_split_by_frequency(fig,frq);
    for i_frq = 1:numel(frq)
        print(figs(i_frq), ...
            fullfile(f(i_f).folder, sprintf('%s_%s', f(i_f).name(2:end-4), figs(i_frq).Tag)),...
            '-depsc');
    end
    close all
end

%% burst amplitudes
%% calculate and plot burst amplitudes per electrode
figtext = [...
    newline, 'trials: ',...
    newline, '  correct',...
    newline, '  max 0.1% saturated voltage within [-0.5 3.1]',...
    newline, 'spectral estim.: adaptive additive superlets',...
    newline, '  4-100 Hz',...
    newline, '  min 3 cycles, order 30',...
    newline, 'burst extraction:',...
    newline, '  fit rotated 2D Gaussians',...
    newline, '  only bursts with width >= 1 cycle',...
    newline, ...
    newline, 'Lundqvist used',...
    newline, '  specest: multitaper',...
    newline, '  burstextr: fit non-rotated Gaussians'...
    ];
f_bands = ...
    [4 10;...
    20 35;...
    50 90];
measures = struct('text',{'burst amplitude [z]'},'subfold',{''},'ylim',{[3 4.5]});
stats = struct('append', {'', 'mean_elec'}, 'tag', {'burst amplitude individual electrodes','burst amplitude mean across electrodes +- sd'});
for i_region = 1:numel(regions)
    burstmetric_computation_plotting(...
        regions(i_region).mat,...
        @accum_burstproperty,...
        @burst_amp,...
        '/home/daniel/DBH/Git/LFP_DA/prototyping/numconditions',...
        strcat('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200114-burst_amplitude/', regions(i_region).name),...
        figtext,...
        f_bands,...
        measures,...
        stats);
end
% exclude electrodes with less than 50 trials from mean plots
min_trl = 50;
f = dir('/mnt/share/DANIEL/nonDA/_plots/bursts/addASLT_3_30/1standardize_by_-9trials/200114-burst_amplitude/**/*mean*.fig');
for i = 1:numel(f)
    fig = openfig(fullfile(f(i).folder,f(i).name));
    meanburstmetric_plot_mintrl(fig,min_trl);
    print(fig,fullfile(f(i).folder,strrep(f(i).name(2:end),'fig','eps')), '-depsc');
    close all
end
% overlap numerosities in plots
burstmetric_overlap(f, min_trl)
