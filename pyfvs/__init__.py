"""
PyFVS

Modules and objects for executing and interacting with FVS variants.

@author: Tod Haren, tod.haren at gmail
"""

__author__ = 'Tod Haren, tod.haren at gmail'

import os
import sys
import logging
import logging.config
import importlib.machinery as imp

# # Bring standard modules into the package namespace
# from .keywords.keywords import *
# from .keywords.eventmonitor import *
# from .fvs import FVS, FVSTrees
# from . import fvs

# If the __version__ file is present, use it.
from ._version import __version__, __git_commit__, __git_describe__

# TODO: Look in local path as well as user home path
# TODO: Use YAML for the config file
# Use a config file written as a Python dictionary.
# The config file is used to initialize logging and FVS library paths.
config_path = os.path.join(os.path.split(__file__)[0], 'pyfvs.cfg')

def version():
    """Return the current PyFVS API version number."""
    return __version__

treelist_format = {
    'template':(
        '{plot_id:04d}{tree_id:04d}{prob:>7.1f}{tree_history:1d}{species:2s}'
        '{dbh:>5.1f}{dg_incr:>3.1f}{live_ht:>3.0f}{trunc_ht:>3.0f}{htg_incr:>2.1f}'
        '{crown_ratio:>2d}'
        '{damage1:>2d}{severity1:>2d}'
        '{damage2:>2d}{severity2:>2d}'
        '{damage3:>2d}{severity3:>2d}'
        '{age:>15d}')
    , 'fvs_format':(
        'I4,T1,I8,F7.1,I1,A2,F5.1,F3.1,F3.0,F3.0,F2.1'
        ',I2,6I2,2I1,I2,2I3,2I1,F3.0'
        )
    }

# Map treelist dataframe columns to a FVS formatted treelist file
treelist_fields = (
    #(column name, python format, fortran format, required)
    ('plot_id',':04d','I4',True),
    ('tree_id',':04d','T1,I8',True),
    ('prob',':>7.1f','F7.1',True),
    ('tree_history',':1d','I1',False),
    ('species',':>5s','A5',True),
    ('dbh',':>5.1f','F5.1',True),
    ('dg_incr',':>4.1f','F4.1',False),
    ('height',':>3.0f','F3.0',False),
    ('tk_height',':>3.0f','F3.0',False),
    ('htg_incr',':>4.1f','F4.1',False),
    ('crown_ratio',':>2.0f','I2',False),
    ('damage1',':>2d','I2',False),
    ('severity1',':>2d','I2',False),
    ('damage2',':>2d','I2',False),
    ('severity2',':>2d','I2',False),
    ('damage3',':>2d','I2',False),
    ('severity3',':>2d','I2',False),
    ('value_class',':1d','I1',False),
    ('rx_code',':1d','I1',False),
    ('plot_slope',':>2d','I2',False),
    ('plot_aspect',':>3d','I3',False),
    ('plot_hab',':>3d','I3',False),
    ('plot_topopos',':1d','I1',False),
    ('plot_siteprep',':1d','I1',False),
    ('tree_age',':>3d','F3.0',False),
    )
    
def get_config():
    """
    Return the configuration dict.
    """
    try:
        with open(config_path) as foo:
            cfg = eval(foo.read())

    except:
        cfg = {
            'logging':{
                'version':1
                , 'disable_existing_loggers':True
                , 'incremental':False
                }
            }

    return cfg

def init_logging():
    """
    Initialize package wide logging from the configuration file.
    """
    logging.config.dictConfig(get_config()['logging'])

def list_variants():
    """
    Return a list of compatible FVS variant modules.
    """
    import glob
    import importlib
    
    root = os.path.dirname(__file__)
    _vars = set()
    for sfx in imp.EXTENSION_SUFFIXES:
        _vars.update(glob.glob(os.path.join(root, f'*{sfx}')))

    vars = {}
    for var in _vars:
        libname = os.path.splitext(os.path.basename(var))[0]
        if not (libname.startswith('fvs') or libname.startswith('_fvs')):
            continue
        
        modname = libname.split('.')[0].lower()
        varname = modname[3:].upper()
        lib = 'pyfvs.{}'.format(modname)
        # print(f'Attempt to import: {lib}')
        try:
            mod = importlib.import_module(lib)
            status = 'OK'
        except:
            raise
            status = 'Failed'
            
        vars[varname] = {'lib':lib, 'status':status}

    return vars
