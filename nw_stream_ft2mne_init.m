function nw_stream_ft2mne_init


[toolpath bb]=fileparts(which('nw_ftpreproc2mne'));

P = py.sys.path;
if count(P,toolpath) == 0
    insert(P,int32(0),toolpath);
end
