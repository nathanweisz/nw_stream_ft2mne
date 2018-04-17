
    
import numpy as np
import mne

def preproc2epoch(data3D, ch_names, ch_types, sfreq, events, tmin):
    """
    Takes relevant input from Matlab to create an mne epoch-array. This function is 
    called    from Matlab (nw_ftpreproc2mne.m).
    """
    
    info = mne.create_info(ch_names=ch_names, ch_types=ch_types, sfreq=sfreq)
    
    epochs = mne.EpochsArray(data3D, info=info, events=events, tmin=tmin, baseline=None)
    
    return epochs