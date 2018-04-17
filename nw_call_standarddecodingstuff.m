function decode_results=nw_call_standarddecodingstuff(cfg, ft_preproc_struc)
%This is the first shot at implementing a collection of standard decoding
%pipelines.

%% Set Default
if ~isfield(cfg, 'method')
    method='logreg_timedecoding';
end

if ~isfield(cfg, 'numcv')
    numcv=4;
else 
    numcv=cfg.numcv;
end

if ~isfield(cfg, 'jobs')
    jobs=1;
else 
    jobs=cfg.jobs;
end

%% Convert fieldtrip structure into mne
mne_epochs=nw_ftpreproc2mne(ft_preproc_struc);

%% IMPLEMENT DEFAULT METHODS
switch method
    case 'logreg_timedecoding'
        mne_decode_results =py.nw_standarddecodingstuff.logreg_timedecoding(mne_epochs, pyargs('numcv',py.int(numcv),'jobs',py.int(jobs)));
end

%% WRAP UP RESULTS INTO FIELDTRIP STRUC
cfg=[];
decode_results=ft_timelockanalysis([],ft_preproc_struc);
decode_results=rmfield(decode_results, 'var');
decode_results.time=nparray2mat(mne_decode_results.times);
decode_results.avg=nparray2mat(mne_decode_results.data);
decode_results.roc=nparray2mat(mne_decode_results.roc_auc);

