function [cfg] = plot_ft_heatmap(fh,cfg,data)
    %% Section 1: general cfg handling that is independent from the data

    % these are used by the ft_preamble/ft_postamble function and scripts
    ft_revision = '$Id$';
    ft_nargin   = nargin;
    ft_nargout  = nargout;

    % do the general setup of the function
    ft_defaults
    ft_preamble init
    ft_preamble debug
    ft_preamble loadvar data
    ft_preamble provenance data
    ft_preamble trackconfig

    % the ft_abort variable is set to true or false in ft_preamble_init
    if ft_abort
        return
    end

    % check if the input data is valid for this function
    data = ft_checkdata(data, 'datatype', 'freq');

    % check if the input cfg is valid for this function
    cfg = ft_checkconfig(cfg, 'unused',      {'cohtargetchannel'});
    cfg = ft_checkconfig(cfg, 'renamed',     {'matrixside',     'directionality'});
    cfg = ft_checkconfig(cfg, 'renamedval',  {'zlim', 'absmax', 'maxabs'});
    cfg = ft_checkconfig(cfg, 'renamedval',  {'directionality', 'feedforward', 'outflow'});
    cfg = ft_checkconfig(cfg, 'renamedval',  {'directionality', 'feedback',    'inflow'});
    cfg = ft_checkconfig(cfg, 'renamed',     {'channelindex',   'channel'});
    cfg = ft_checkconfig(cfg, 'renamed',     {'channelname',    'channel'});
    cfg = ft_checkconfig(cfg, 'renamed',     {'cohrefchannel',  'refchannel'});
    cfg = ft_checkconfig(cfg, 'renamed',	   {'zparam',         'parameter'});
    cfg = ft_checkconfig(cfg, 'renamed',     {'newfigure',      'figure'});

    % Set the defaults
    cfg.baseline       = ft_getopt(cfg, 'baseline',      'no');
    cfg.baselinetype   = ft_getopt(cfg, 'baselinetype',  'absolute');
    cfg.trials         = ft_getopt(cfg, 'trials',        'all', 1);
    cfg.xlim           = ft_getopt(cfg, 'xlim',          'maxmin');
    cfg.ylim           = ft_getopt(cfg, 'ylim',          'maxmin');
    cfg.zlim           = ft_getopt(cfg, 'zlim',          'maxmin');
    cfg.fontsize       = ft_getopt(cfg, 'fontsize',       8);
    cfg.colorbar       = ft_getopt(cfg, 'colorbar',      'yes');
    cfg.colorbartext   = ft_getopt(cfg, 'colorbartext',   '');
    cfg.interactive    = ft_getopt(cfg, 'interactive',   'yes');
    cfg.hotkeys        = ft_getopt(cfg, 'hotkeys',       'yes');
    cfg.maskalpha      = ft_getopt(cfg, 'maskalpha',      1);
    cfg.maskparameter  = ft_getopt(cfg, 'maskparameter',  []);
    cfg.maskstyle      = ft_getopt(cfg, 'maskstyle',     'opacity');
    cfg.channel        = ft_getopt(cfg, 'channel',       'all');
    cfg.title          = ft_getopt(cfg, 'title',          []);
    cfg.masknans       = ft_getopt(cfg, 'masknans',      'yes');
    cfg.directionality = ft_getopt(cfg, 'directionality', []);
    cfg.figurename     = ft_getopt(cfg, 'figurename',     []);
    cfg.parameter      = ft_getopt(cfg, 'parameter',     'powspctrm');
    cfg.renderer       = ft_getopt(cfg, 'renderer',       []); % let MATLAB decide on the default
    % add user parameter
    cfg.yscale         = ft_getopt(cfg, 'yscale',        'linear');
    %/add user parameter

    % this is needed for the figure title
    if isfield(cfg, 'dataname') && ~isempty(cfg.dataname)
        dataname = cfg.dataname;
    elseif isfield(cfg, 'inputfile') && ~isempty(cfg.inputfile)
        dataname = cfg.inputfile;
    elseif nargin>1
        dataname = arrayfun(@inputname, 2:nargin, 'UniformOutput', false);
    else
        dataname = {};
    end

    %% Section 2: data handling, this also includes converting bivariate (chan_chan and chancmb) into univariate data

    hastime = isfield(data, 'time');
    hasfreq = isfield(data, 'freq');

    assert((hastime && hasfreq), 'please use ft_singleplotER for time-only or frequency-only data');

    xparam = ft_getopt(cfg, 'xparam', 'time');
    yparam = ft_getopt(cfg, 'yparam', 'freq');

    % check whether rpt/subj is present and remove if necessary
    dimord = getdimord(data, cfg.parameter);
    dimtok = tokenize(dimord, '_');
    hasrpt = any(ismember(dimtok, {'rpt' 'subj'}));

    if ~hasrpt
        assert(isequal(cfg.trials, 'all') || isequal(cfg.trials, 1), 'incorrect specification of cfg.trials for data without repetitions');
    else
        assert(~isempty(cfg.trials), 'empty specification of cfg.trials for data with repetitions');
    end

    % parse cfg.channel
    if isfield(cfg, 'channel') && isfield(data, 'label')
        cfg.channel = ft_channelselection(cfg.channel, data.label);
    elseif isfield(cfg, 'channel') && isfield(data, 'labelcmb')
        cfg.channel = ft_channelselection(cfg.channel, unique(data.labelcmb(:)));
    end

    % Apply baseline correction:
    if ~strcmp(cfg.baseline, 'no')
        tmpcfg = keepfields(cfg, {'baseline', 'baselinetype', 'baselinewindow', 'demean', 'parameter', 'channel'});
        % keep mask-parameter if it is set
        if ~isempty(cfg.maskparameter)
            tempmask = data.(cfg.maskparameter);
        end
        data = ft_freqbaseline(tmpcfg, data);
        % put mask-parameter back if it is set
        if ~isempty(cfg.maskparameter)
            data.(cfg.maskparameter) = tempmask;
        end
    end

    % channels should NOT be selected and averaged here, since a topoplot might follow in interactive mode
    tmpcfg = keepfields(cfg, {'showcallinfo', 'trials'});
    if hasrpt
        tmpcfg.avgoverrpt = 'yes';
    else
        tmpcfg.avgoverrpt = 'no';
    end
    tmpvar = data;
    [data] = ft_selectdata(tmpcfg, data);
    % restore the provenance information and put back cfg.channel
    tmpchannel  = cfg.channel;
    [cfg, data] = rollback_provenance(cfg, data);
    cfg.channel = tmpchannel;

    if isfield(tmpvar, cfg.maskparameter) && ~isfield(data, cfg.maskparameter)
        % the mask parameter is not present after ft_selectdata, because it is
        % not included in all input arguments. Make the same selection and copy
        % it over
        tmpvar = ft_selectdata(tmpcfg, tmpvar);
        data.(cfg.maskparameter) = tmpvar.(cfg.maskparameter);
    end

    clear tmpvar tmpcfg dimord dimtok hastime hasfreq hasrpt

    % ensure that the preproc specific options are located in the cfg.preproc
    % substructure, but also ensure that the field 'refchannel' remains at the
    % highest level in the structure. This is a little hack by JM because the field
    % refchannel can relate to connectivity or to an EEg reference.

    if isfield(cfg, 'refchannel'), refchannelincfg = cfg.refchannel; cfg = rmfield(cfg, 'refchannel'); end
    cfg = ft_checkconfig(cfg, 'createsubcfg',  {'preproc'});
    if exist('refchannelincfg', 'var'), cfg.refchannel  = refchannelincfg; end

    if ~isempty(cfg.preproc)
        % preprocess the data, i.e. apply filtering, baselinecorrection, etc.
        fprintf('applying preprocessing options\n');
        if ~isfield(cfg.preproc, 'feedback')
            cfg.preproc.feedback = cfg.interactive;
        end
        data = ft_preprocessing(cfg.preproc, data);
    end

    % Handle the bivariate case
    dimord = getdimord(data, cfg.parameter);
    if startsWith(dimord, 'chan_chan_') || startsWith(dimord, 'chancmb_')
        % convert the bivariate data to univariate and call this plotting function again
        cfg.originalfunction = 'ft_singleplotTFR';
        cfg.trials = 'all'; % trial selection has been taken care off
        bivariate_common(cfg, data);
        return
    end


    % Apply channel-type specific scaling
    fn = fieldnames(cfg);
    fn = setdiff(fn, {'skipscale', 'showscale', 'gridscale'}); % these are for the layout and plotting, not for CHANSCALE_COMMON
    fn = fn(endsWith(fn, 'scale') | startsWith(fn, 'mychan') | strcmp(fn, 'channel') | strcmp(fn, 'parameter'));
    tmpcfg = keepfields(cfg, fn);
    if ~isempty(tmpcfg)
        data = chanscale_common(tmpcfg, data);
        % remove the scaling fields from the configuration, to prevent them from being called again in interactive mode
        % but keep the parameter and channel field
        cfg = removefields(cfg, setdiff(fn, {'parameter', 'channel'}));
    else
        % do nothing
    end

    %% Section 3: select the data to be plotted and determine min/max range

    % Take the subselection of channels that is contained in the layout, this is the same in all datasets
    [selchan] = match_str(data.label, cfg.channel);

    % Get physical min/max range of x, i.e. time
    if strcmp(cfg.xlim, 'maxmin')
        xmin = min(data.(xparam));
        xmax = max(data.(xparam));
    else
        xmin = cfg.xlim(1);
        xmax = cfg.xlim(2);
    end

    % Get the index of the nearest bin
    xminindx = nearest(data.(xparam), xmin);
    xmaxindx = nearest(data.(xparam), xmax);
    xmin = data.(xparam)(xminindx);
    xmax = data.(xparam)(xmaxindx);
    selx = xminindx:xmaxindx;
    xval = data.(xparam)(selx);

    % Get physical min/max range of y, i.e. frequency
    if strcmp(cfg.ylim, 'maxmin')
        ymin = min(data.(yparam));
        ymax = max(data.(yparam));
    else
        ymin = cfg.ylim(1);
        ymax = cfg.ylim(2);
    end

    % Get the index of the nearest bin
    yminindx = nearest(data.(yparam), ymin);
    ymaxindx = nearest(data.(yparam), ymax);
    ymin = data.(yparam)(yminindx);
    ymax = data.(yparam)(ymaxindx);
    sely = yminindx:ymaxindx;
    yval = data.(yparam)(sely);

    % test if X and Y are linearly spaced (to within 10^-12): % FROM UIMAGE
    dx = min(diff(xval));  % smallest interval for X
    dy = min(diff(yval));  % smallest interval for Y
    evenx = all(abs(diff(xval)/dx-1)<1e-12);     % true if X is linearly spaced
    eveny = all(abs(diff(yval)/dy-1)<1e-12);     % true if Y is linearly spaced

    if ~evenx || ~eveny
        ft_warning('(one of the) axis is/are not evenly spaced, but plots are made as if axis are linear')
    end

    % masking is only possible for evenly spaced axis
    if strcmp(cfg.masknans, 'yes') && (~evenx || ~eveny)
        ft_warning('(one of the) axis are not evenly spaced -> nans cannot be masked out -> cfg.masknans is set to ''no'';')
        cfg.masknans = 'no';
    end

    % the usual data is chan_freq_time, but other dimords should also work
    dimtok = tokenize(dimord, '_');
    datamatrix = data.(cfg.parameter);
    [c, ia, ib] = intersect({'chan', yparam, xparam}, dimtok, 'stable');
    datamatrix = permute(datamatrix, ib);
    datamatrix = datamatrix(selchan, sely, selx);

    if ~isempty(cfg.maskparameter)
        maskmatrix = data.(cfg.maskparameter)(selchan, sely, selx);
        if islogical(maskmatrix) && any(strcmp(cfg.maskstyle, {'saturation', 'opacity'}))
            maskmatrix = double(maskmatrix);
            maskmatrix(~maskmatrix) = cfg.maskalpha;
        elseif isnumeric(maskmatrix)
            if strcmp(cfg.maskstyle, 'outline')
                ft_error('Outline masking with a numeric cfg.maskparameter is not supported. Please use a logical mask instead.')
            end
            if cfg.maskalpha ~= 1
                ft_warning('Using field "%s" for masking, cfg.maskalpha is ignored.', cfg.maskparameter)
            end
            % scale mask between 0 and 1
            minval = min(maskmatrix(:));
            maxval = max(maskmatrix(:));
            maskmatrix = (maskmatrix - minval) / (maxval-minval);
        end
    else
        % create an Nx0x0 matrix
        maskmatrix = zeros(length(selchan), 0, 0);
    end

    %% Section 4: do the actual plotting
    % plot at the specified handle
    hold on
    
    zval = mean(datamatrix, 1); % over channels
    zval = reshape(zval, size(zval,2), size(zval,3));
    mask = squeeze(mean(maskmatrix, 1)); % over channels

    % Get physical z-axis range (color axis):
    if strcmp(cfg.zlim, 'maxmin')
      zmin = nanmin(zval(:));
      zmax = nanmax(zval(:));
    elseif strcmp(cfg.zlim, 'maxabs')
      zmin = -nanmax(abs(zval(:)));
      zmax =  nanmax(abs(zval(:)));
    elseif strcmp(cfg.zlim, 'zeromax')
      zmin = 0;
      zmax = nanmax(zval(:));
    elseif strcmp(cfg.zlim, 'minzero')
      zmin = nanmin(zval(:));
      zmax = 0;
    else
      zmin = cfg.zlim(1);
      zmax = cfg.zlim(2);
    end

    % Draw the data and mask NaN's if requested
    if isequal(cfg.masknans, 'yes') && isempty(cfg.maskparameter)
      nans_mask = ~isnan(zval);
      mask = double(nans_mask);
      ft_plot_matrix(xval, yval, zval, 'clim', [zmin zmax], 'tag', 'cip', 'highlightstyle', cfg.maskstyle, 'highlight', mask)
    elseif isequal(cfg.masknans, 'yes') && ~isempty(cfg.maskparameter)
      nans_mask = ~isnan(zval);
      mask = mask .* nans_mask;
      mask = double(mask);
      ft_plot_matrix(xval, yval, zval, 'clim', [zmin zmax], 'tag', 'cip', 'highlightstyle', cfg.maskstyle, 'highlight', mask)
    elseif isequal(cfg.masknans, 'no') && ~isempty(cfg.maskparameter)
      mask = double(mask);
      ft_plot_matrix(xval, yval, zval, 'clim', [zmin zmax], 'tag', 'cip', 'highlightstyle', cfg.maskstyle, 'highlight', mask)
    else
      ft_plot_matrix(xval, yval, zval, 'clim', [zmin zmax], 'tag', 'cip')
    end

    % set colormap
    if isfield(cfg, 'colormap')
      if ischar(cfg.colormap)
        cfg.colormap = ft_colormap(cfg.colormap);
      elseif iscell(cfg.colormap)
        cfg.colormap = ft_colormap(cfg.colormap{:});
      end
      if size(cfg.colormap,2)~=3
        ft_error('colormap must be a Nx3 matrix');
      else
        set(gcf, 'colormap', cfg.colormap);
      end
    end

    axis xy

    if isequal(cfg.colorbar, 'yes')
      c = colorbar;
      ylabel(c, cfg.colorbartext);
    end

    % Set callback to adjust color axis
    if strcmp('yes', cfg.hotkeys)
      %  Attach data and cfg to figure and attach a key listener to the figure
      set(gcf, 'KeyPressFcn', {@key_sub, xmin, xmax, ymin, ymax, zmin, zmax})
    end

    % Create axis title containing channel name(s) and channel number(s):
    if ~isempty(cfg.title)
      t = cfg.title;
    else
      if length(cfg.channel) == 1
        t = [char(cfg.channel) ' / ' num2str(selchan) ];
      else
        t = sprintf('mean(%0s)', join_str(', ', cfg.channel));
      end
    end
    title(t, 'fontsize', cfg.fontsize);

    % set the figure window title, add channel labels if number is small
    if isempty(get(gcf, 'Name'))
      if length(selchan) < 5
        chans = join_str(', ', cfg.channel);
      else
        chans = '<multiple channels>';
      end
      if ~isempty(cfg.figurename)
        set(gcf, 'name', cfg.figurename);
        set(gcf, 'NumberTitle', 'off');
      elseif ~isempty(dataname)
        set(gcf, 'Name', sprintf('%d: %s: %s (%s)', double(gcf), mfilename, join_str(', ', dataname), chans));
        set(gcf, 'NumberTitle', 'off');
      else
        set(gcf, 'Name', sprintf('%d: %s (%s)', double(gcf), mfilename, chans));
        set(gcf, 'NumberTitle', 'off');
      end
    end
    
    % set the yaxis scale as log if specified
    if strcmp(cfg.yscale,'log')
        set(gcf,'YScale','log');
    end
    %/set the yaxis scale as log if specified
    
    axis tight

    % do the general cleanup and bookkeeping at the end of the function
    ft_postamble debug
    ft_postamble trackconfig
    ft_postamble previous data
    ft_postamble provenance
    ft_postamble savefig

    if ~ft_nargout
      % don't return anything
      clear cfg
    end

end