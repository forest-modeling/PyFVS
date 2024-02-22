"""
PyFVS

Modules and objects for executing and interacting with FVS variants.

@author: Tod Haren, tod.haren at gmail
"""

## TODO: Implement lat-lon variant lookup, embed simplified variant polygons, implement point in polygon
##       https://stackoverflow.com/questions/36399381/whats-the-fastest-way-of-checking-if-a-point-is-inside-a-polygon-in-python

import os
import sys
import logging
import logging.config
import importlib.machinery as imp

import confuse

if sys.version_info[:2] >= (3, 8):
    # TODO: Import directly (no need for conditional) when `python_requires = >= 3.8`
    from importlib.metadata import PackageNotFoundError, version  # pragma: no cover
else:
    from importlib_metadata import PackageNotFoundError, version  # pragma: no cover

try:
    # Change here if project is renamed and does not equal the package name
    dist_name = "PyFVS"
    __version__ = version(dist_name)
except PackageNotFoundError:  # pragma: no cover
    __version__ = "unknown"
finally:
    del version, PackageNotFoundError

## TODO: Import package modules
# from pyfvs.fvs import *
# from pyfvs.keywords import *

# Configuration is stored in a YAML file
# Package defaults will be in ./config_default.yaml
# NOTE: Confuse uses the concept of "views" where the contents of the configuration
#     files are not resolved until the ".get()" method is called, e.g. config['logging'].get()
config = confuse.LazyConfig('PyFVS', __name__)

# print(config['workspace'].get())

# print(config['treelist_format'].get()['template'])

# Default FVS Treelist format
# template is the Python string format
# fvs_format is the FVS keyword fields to read the formatted string
tmplt = config['treelist_format']['template'].get(str)
tmplt = ''.join(x.strip() for x in tmplt.split())
fmt = config['treelist_format']['fvs_format'].get(str)
if tmplt and fmt:
    if len(fmt)>78:
        f = fmt.split(',')


    treelist_format = {'template':tmplt, 'fvs_format': fmt}

else:
    treelist_format = {
        'template':(
            '{plot_id:04d}{tree_id:04d}{prob:>9.3f}{tree_history:1d}{species:2s}'
            '{dbh:>5.1f}{dg_incr:>3.1f}{live_ht:>3.0f}{trunc_ht:>3.0f}{htg_incr:>2.1f}'
            '{crown_ratio:>2d}'
            '{damage1:>2d}{severity1:>2d}'
            '{damage2:>2d}{severity2:>2d}'
            '{damage3:>2d}{severity3:>2d}'
            '{age:>15d}')
        , 'fvs_format':(
            'I4,T1,I8,F9.3,I1,A2,F5.1,F3.1,F3.0,F3.0,F2.1'
            ',I2,6I2,2I1,I2,2I3,2I1,F3.0'
            )
        }

# Map treelist dataframe columns to a FVS formatted treelist file
treelist_fields = (
    #(column name, python format, fortran format, required)
    ('plot_id',':04d','I4',True),
    ('tree_id',':04d','T1,I8',True),
    ('prob',':>9.3f','F9.3',True),
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

# def get_config():
#     """
#     Return the configuration dict.
#     """
#     try:
#         with open(config_path) as foo:
#             cfg = eval(foo.read())

#     except:
#         cfg = {
#             'logging':{
#                 'version':1
#                 , 'disable_existing_loggers':True
#                 , 'incremental':False
#                 }
#             }

#     return cfg

def init_logging():
    """
    Initialize package wide logging from the configuration file.
    """
    logging.config.dictConfig(config['logging'].get())

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
            # raise
            status = 'Failed'

        vars[varname] = {'lib':lib, 'status':status}

    return vars
