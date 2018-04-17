"""
This module contains a collection of very standard decoding tools that are called from Matlab (XXX.m).
"""

import numpy as np
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

import mne
from mne.decoding import (SlidingEstimator, GeneralizingEstimator,
                        cross_val_multiscore, LinearModel, get_coef)

from sklearn.linear_model import LogisticRegression

##
def logreg_timedecoding(epochs, numcv=4, jobs=1):    
    """
    Logistic regression over sensors. Returns Evoked array containing coefficients and ROC.
    Code snippets stolen from:
    https://martinos.org/mne/stable/auto_tutorials/plot_sensors_decoding.html
    """
    
    X = epochs.get_data()  # MEG signals: n_epochs, n_channels, n_times
    X = X.astype(float)
    y = epochs.events[:, 2]  # targets
    
    # setup and run the decoder 
    
    clf = make_pipeline(StandardScaler(),  LinearModel(LogisticRegression()))
    
    time_decod = SlidingEstimator(clf,  scoring='roc_auc', n_jobs=jobs)#scoring='roc_auc',
    
    scores = cross_val_multiscore(time_decod, X, y, cv=numcv, n_jobs=jobs)
    
    # Mean scores across cross-validation splits
    scores = np.mean(scores, axis=0)
    
    #
    time_decod = SlidingEstimator(clf,scoring='roc_auc', n_jobs=jobs)
    time_decod.fit(X, y)
    
    coef = get_coef(time_decod,'patterns_',inverse_transform=True)
    
    evoked = mne.EvokedArray(coef, epochs.info, tmin=epochs.times[0])
    evoked.roc_auc=scores
    
    return evoked

##
