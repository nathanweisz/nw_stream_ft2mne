pyversion('/Users/b1019548/anaconda3/bin/python')

%%
restoredefaultpath
clear all
addpath('~/Documents/MATLAB/obob_ownft/');
obob_init_ft

addpath('~/Documents/MATLAB/nw_stream_ft2mne/');
nw_stream_ft2mne_init
%%
fileinfo='/Users/b1019548/Desktop/Data_Sternberg/jens_L.fif';
%fileinfo='/Users/b1019548/mne_data/MNE-sample-data/MEG/sample/sample_audvis_filt-0-40_raw.fif';

cfg             = [];
cfg.channel = 'MEG';
cfg.dataset     = fileinfo;
cfg.continuous  = 'yes';
% cfg.hpfilter='yes';
% cfg.hpfreq=1;
data = ft_preprocessing(cfg);

cfg          = [];
cfg.length   = 1; % in seconds;
cfg.overlap  = 0;
data = ft_redefinetrial(cfg, data);

data.trialinfo=ones(length(data.trial),1);
origtrl=data.cfg.trl;

%%
% cfg=[];
% cfg.inputfile=fileinfo;
% data=obob_apply_ssp(cfg,data);

%%
for ii= 1:length(data.time)
    data.time{ii}=linspace(0,1,size(data.trial{1},2));
end

%% downsample to speed up --> implement in MNE
% 
% cfg=[];
% cfg.resamplefs=128;
% 
% data=ft_resampledata(cfg, data);

%%
cfg=[]; 
cfg.gradscale=.04;
cfg.preproc.hpfilter='yes';
cfg.preproc.hpfreq=1;
cfg.preproc.hpfilttype='firws';
data=ft_rejectvisual(cfg, data);

data.sampleinfo=[origtrl(:,1), origtrl(:,2)];

%badsens=py.list({py.str('MEG2443'),py.str('MEG1711')});
badsens=py.list({});

%%
cfg=[];
cfg.hpfilter='yes';
cfg.hpfreq=1;
cfg.hpfilttype='fir';
data4ica=ft_preprocessing(cfg, data);

data4ica=rmfield(data4ica,'elec');
data4ica.hdr=rmfield(data4ica.hdr,'elec');

cfg=[];
cfg.neigh_method='template';
cfg.load_default=1;
data4ica = obob_fixchannels(cfg, data4ica);

cfg=[];
cfg.runica.pca=50;
comp=ft_componentanalysis(cfg, data4ica);


%% CONVERT PREPROC STRUCTURE TO MNE
mne_epochs=nw_ftpreproc2mne(data);

%%
art_log =py.nw_standardautoreject.runautoreject(mne_epochs,py.str(fileinfo),py.str('grad'),badsens);

%%
bad_epoch_ind=nparray2mat(art_log.bad_epochs);

%% Make artefact definition

cfg             = [];
cfg.channel = 'MEG';
cfg.dataset     = fileinfo;
cfg.continuous  = 'yes';
cfg.hpfilter='yes';
cfg.hpfreq=1;
data = ft_preprocessing(cfg);

cfg=[];
cfg.inputfile=fileinfo;
data=obob_apply_ssp(cfg,data);

%%
cfg=[];
cfg.channel={'all','-megmag'};
cfg.viewmode='vertical';
cfg.artfctdef.autoreject.artifact=origtrl(find(bad_epoch_ind==1),1:2);
ft_databrowser(cfg, data);

%%


