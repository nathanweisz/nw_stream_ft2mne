function [mne_epochs]=nw_ftpreproc2mne(preprocdata)
%Converts fieldtrip preprocessing structure into an MNE Epochs structure.

% for ii=1:length(preprocdata.label)
%     tmp=preprocdata.label{ii};
%     preprocdata.label{ii}=tmp(~isspace(tmp));
% end

ch_names = py.list(preprocdata.label');

chantype=ft_chantype(preprocdata.label);
tmp=cellfun(@(x) strrep(x(1:end), 'megplanar', 'grad'), chantype,'UniformOutput',false);
tmp=cellfun(@(x) strrep(x(1:end), 'megmag', 'mag'), tmp,'UniformOutput',false);

ch_types = py.list(tmp');

sfreq=mat2nparray(preprocdata.fsample);

ntrl=length(preprocdata.trial);
nchan=length(preprocdata.label);
nsamps=size(preprocdata.trial{1},2);

events=cat(2,preprocdata.sampleinfo(:,1), zeros(length(preprocdata.time),1), preprocdata.trialinfo);
%events=cat(2,preprocdata.trialinfo, ones(length(preprocdata.time),1)*preprocdata.time{1}(1),ones(length(preprocdata.time),1)*preprocdata.time{1}(end));
events=mat2nparray(events);
events=py.numpy.int64(events);

tmin=preprocdata.time{1}(1);
data3D=cat(3, preprocdata.trial{:});
data3D=permute(data3D,[3 1 2]);
data3D=mat2nparray(data3D);

mne_epochs =py.nw_convertdatastrucs.preproc2epoch(data3D, ch_names, ch_types, sfreq, events, tmin);
