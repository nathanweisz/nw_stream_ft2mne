
import numpy as np
import mne  # noqa
from mne.utils import check_random_state  # noqa

from autoreject import (AutoReject, set_matplotlib_defaults)  # noqa


def runautoreject(epochs, fiffile, senstype, bads=[], n_interpolates = np.array([1, 4, 32]), consensus_percs = np.linspace(0, 1, 11)):

    check_random_state(42)  
    
    raw = mne.io.read_raw_fif(fiffile, preload=True)
    raw.info['bads'] = list()
    raw.pick_types(meg=True)
    raw.info['projs'] = list()
    epochs.info=raw.info #required since no channel infos
    
    del raw
      
    
    picks = mne.pick_types(epochs.info, meg=senstype, eeg=False, stim=False, eog=False, include=[], exclude=bads)
    
    epochs.verbose=False
    epochs.baseline=(None, 0)
    epochs.preload=True
    epochs.detrend=0
    
    
    ar = AutoReject(n_interpolates, consensus_percs, picks=picks, thresh_method='bayesian_optimization', random_state=42, verbose=False)
  
    epochs, reject_log = ar.fit_transform(epochs, return_log=True)
    return reject_log


#test=runautoreject(epochs, fiffile, 'grad')


