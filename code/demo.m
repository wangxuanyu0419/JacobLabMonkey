% Read neuro explorer file
filename = 'Z:\XUANYU\MONKEY\Non-iontophoresis\data\raw_nex\R120410-03_lfp.nex';
nexfile = readNexFile(filename)
% strobed codes (event markers)
ts = nexfile.markers{1}.timestamps;
ts(1:10)
codes = nexfile.markers{1}.values{1}.strings;
codes = cellfun(@str2double, codes);
codes(1:10)
% lfps
% first channel PFC: AD01
pfc01 = nexfile.contvars{1}
x = 0:1/1000:(length(pfc01.data)-1)/1000;
% first channel VIP: AD09
vip01 = nexfile.contvars{9}

%% example trial: first correct
code_corr = 200;
code_beg = 9;
code_end = 18;
trl_corr = codes == code_corr;
trl_beg = find(codes == code_beg);
trl_beg = trl_beg(1:3:end); % account for 3 redundant markers
trl_end = find(codes == code_end);
trl_end = trl_end(3:3:end); % account for 3 redundant markers
i_xmpl = find(trl_corr, 1);
% codes and times this trial
strobes_xmpl = (ts >= ts(trl_beg(i_xmpl))) & (ts <= ts(trl_end(i_xmpl)));
ts_xmpl = ts(strobes_xmpl);
codes_xmpl = codes(strobes_xmpl);
% plot
plot(x, pfc01.data)
plot(x, vip01.data)
xlim([ts_xmpl(1), ts_xmpl(end)])
y = ylim();
for s = 1:length(ts_xmpl)
    x_s = ts_xmpl(s);
    line(ones(2,1) * x_s, y, 'linestyle', '--', 'color', 'black');
    text(x_s, y(1), num2str(codes_xmpl(s)));
end

%% read nex using Fieldtrip
% very simple trialfun
cfg = [];
cfg.dataset = filename;
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'Strobed*';
cfg.trialdef.eventvalue = 3;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 2;
ppcfg = ft_definetrial(cfg);

%% inspect a preprocessed FT file
load('/mnt/share/DANIEL/MONKEY/MONKEYS_DISTRACTOR/data/20160202-ALL/TD/preprocessed/PFC/R120410-03.mat')
load('/mnt/share/DANIEL/MONKEY/MONKEYS_DISTRACTOR/data/20160202-ALL/TD/reref(cwa)/PFC/R120410-03.mat')