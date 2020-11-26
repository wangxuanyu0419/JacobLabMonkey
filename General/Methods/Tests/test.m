%% generate surrogate data
signal                  = toydata();
N                       = numel(signal);
fs                      = 1024;
t                       = N / fs;

% pad one sec before and after to avoid truncating with FieldTrip
signal_pad              = [zeros(1, fs), signal, zeros(1, fs)];
N_pad                   = numel(signal_pad);
t_pad                   = N_pad / fs;


%% put test data into FT format
data                    = [];
data.trial{1}           = signal_pad;
data.fsample            = fs;
data.sampleinfo         = [0, N_pad - 1];
data.trialinfo          = 1;
data.time{1}            = linspace(0, t_pad, N_pad);
data.label              = { 'A1' };


%% execute analysis
cfg                     = [];
cfg.output              = 'pow';
cfg.channel             = 'eeg';
cfg.method              = 'superlet';
cfg.foi                 = 10:0.5:75;
cfg.toi                 = data.time{1};
cfg.pad                 = 'nextpow2';

cfg.superlet.combine    = 'multiplicative';
cfg.superlet.gwidth     = 2.5;
cfg.superlet.basewidth  = 3;
cfg.superlet.order      = round(linspace(1, 30, numel(cfg.foi)));


ft_ws = ft_freqanalysis(cfg, data);
my_ws = asrwt(signal_pad, fs, cfg.foi, cfg.superlet.basewidth, [1, 30], 1);


%% plot results
figure;
subplot(1, 2, 1);
imagesc(data.trial{1}, cfg.foi, my_ws);
set(gca, 'ydir', 'normal');
colormap jet;
colorbar;

subplot(1, 2, 2);
xx = squeeze(ft_ws.powspctrm);
imagesc(data.trial{1}, cfg.foi, squeeze(ft_ws.powspctrm));
set(gca, 'ydir', 'normal');
colormap jet;
colorbar;




