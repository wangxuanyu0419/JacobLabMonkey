function data = parload(fname,varname)
% this function is run by parallel processes on each worker
    load(fname,varname);
    eval(sprintf('data=%s;',varname));
end