function data = parload(fname)
% this function is run by parallel processes on each worker
    load(fname,'data_prep');
    data = data_prep;
end