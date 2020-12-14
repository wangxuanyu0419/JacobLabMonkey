%% compute power via superlet method 
delete(gcp('nocreate'))
parpool(32)
f = dir('/mnt/storage3/daniel/monkey_bursts/nonDA/preproc/R120516*.mat');
save_folder = '/mnt/share/XUANYU/MONKEY/JacobLabMonkey/data/2.Normalized';
cfg = [];
cfg.saturation                  = 250;
cfg.specest.method              = 'superlet';
cfg.specest.output              = 'pow';
cfg.specest.channel             = {'AD01' 'AD09' 'AD11'};
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