pyversion('/Users/b1019548/anaconda3/envs/py27/bin/python')

%%
restoredefaultpath
clear all
addpath('~/Documents/MATLAB/fieldtrip/');
ft_defaults

addpath('~/Documents/MATLAB/nw_stream_ft2mne/');
nw_stream_ft2mne_init

%%
vpname='Tzvetan';
datapath='/Users/b1019548/ownCloud/Rubin_sampleDat';

%Data set containing face-vase data from Rubin experiment:
%Low pass filtered (30 Hz), resampled to 100 Hz and cut -100 tp 400 ms
load([datapath '/' vpname '/dataall_short.mat'])

%% CONVERT PREPROC STRUCTURE TO MNE
mne_epochs=nw_ftpreproc2mne(dataall);

%% apply some mne functions directly
timelock_mne=mne_epochs.average();
avgmat_mne=nparray2mat(timelock_mne.data);
time=nparray2mat(timelock_mne.times);

figure; plot(time, avgmat_mne); title('Average by mne')

ftavg=ft_timelockanalysis([], dataall);
tmp=ftavg.avg-avgmat_mne; 
figure; hist(tmp(:)); title('Difference to fieldtrip')
%If all zero then this means 2 packages produce same results

%%
DecRes=nw_call_standarddecodingstuff([],dataall);

%%

DecRes_cmb=ft_combineplanar([], DecRes); 

%%

cfg=[];
cfg.channel='MEGGRAD';
cfg.layout='neuromag306mag';
ft_singleplotER(cfg, DecRes_cmb);

%%

cfg=[];
cfg.zlim='maxabs';
cfg.layout='neuromag306mag';
cfg.colorbar='yes';

cfg.xlim=[.12 .12];
figure;ft_topoplotER(cfg, DecRes_cmb); title('120 ms')

cfg.xlim=[.15 .15];
figure;ft_topoplotER(cfg, DecRes_cmb); title('150 ms')

cfg.xlim=[.280 .280];
figure;ft_topoplotER(cfg, DecRes_cmb); title('280 ms')

cfg=[];
cfg.zlim='maxabs';
cfg.layout='neuromag306cmb';
cfg.colorbar='yes';

cfg.xlim=[.12 .12];
figure;ft_topoplotER(cfg, DecRes_cmb); title('120 ms')

cfg.xlim=[.15 .15];
figure;ft_topoplotER(cfg, DecRes_cmb); title('150 ms')

cfg.xlim=[.280 .280];
figure;ft_topoplotER(cfg, DecRes_cmb); title('280 ms')

%% EXPERIMENTAL STUFF
load(['/Users/b1019548/ownCloud/Rubin_sampleDat/' vpname '/headstuff_' vpname '_rvi.mat'], 'hdm')
load standard_mri.mat
load(['/Users/b1019548/ownCloud/Rubin_sampleDat/' vpname '/HM' vpname '_rvi_grid.mat'], 'mriF')
load('/Users/b1019548/Documents/MATLAB/fieldtrip/template/sourcemodel/standard_sourcemodel3d10mm.mat')


%%
hdm=ft_convert_units(hdm, 'm');
dataall.grad=ft_convert_units(dataall.grad, 'm');
mriF=ft_convert_units(mriF, 'm');
mri=ft_convert_units(mri, 'm');
template_grid=ft_convert_units(sourcemodel, 'm');

%%

cfg                = [];
% cfg.grid.warpmni   = 'yes';
% cfg.grid.template  = template_grid;
% cfg.grid.nonlinear = 'yes';
% cfg.mri=mriF;
cfg.grid.resolution = .007;
cfg.headmodel = hdm;
cfg.grid.unit      ='m';
grid               = ft_prepare_sourcemodel(cfg);

figure; hold on;
ft_plot_vol(hdm, 'edgecolor', 'none', 'facealpha', 0.4);
ft_plot_mesh(grid.pos(grid.inside,:));

%%

cfg=[];
cfg.grid=grid;
cfg.headmodel=hdm;
cfg.normalize ='yes';
lf=ft_prepare_leadfield(cfg, dataall);

%%

cfg=[];
cfg.preproc.lpfilter   = 'yes';
cfg.preproc.lpfreq     = 30;
cfg.preproc.lpfilttype = 'firws';
cfg.covariance         = 'yes';
cfg.covariancewindow   = [-.1 .5];

data_avg = ft_timelockanalysis(cfg, dataall);

%%

cfg=[];
cfg.method          = 'lcmv';
cfg.headmodel.unit        = 'm'; % th: dirty hack to make this work. as we always provide leadfields, we do not need a vol...
cfg.grid            = grid;
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.fixedori   = 'yes';
cfg.lcmv.lambda     = '10%';

lcmvall=ft_sourceanalysis(cfg, data_avg);

%%
beamfilts = cat(1,lcmvall.avg.filter{:});

data_source=[];
data_source.label=cellstr(num2str([1:size(beamfilts,1)]'));
data_source.avg = beamfilts*DecRes.avg;
data_source.time =DecRes.time;
data_source.dimord='chan_time';

%%
restoredefaultpath
addpath('~/Documents/MATLAB/obob_ownft/');
cfg=[];
cfg.package.svs=true;
obob_init_ft(cfg);

%%
% cfg=[];
% cfg.baseline=[-.2 -.05];
% cfg.baselinetype='relchange';
% data_source=obob_svs_timelockbaseline(cfg, data_source);

%%
cfg=[];
cfg.sourcegrid=grid;
cfg.parameter='avg';
cfg.latency=[.120 .160];
cfg.mri=mriF;
sourcecoeff=obob_svs_virtualsens2source(cfg, data_source);

%%
sourcecoeff.avg=abs(sourcecoeff.avg);

sourcecoeff.mask=(sourcecoeff.avg > max(sourcecoeff.avg(:))*.75);
cfg=[];
cfg.funparameter='avg';
cfg.maskparameter='mask';
ft_sourceplot(cfg,sourcecoeff);

