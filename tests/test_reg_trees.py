
import os
import unittest
import pytest
import sqlite3
import ctypes

import numpy as np
import pandas as pd

from pyfvs import fvs
from pyfvs.keywords import keywords as kwds

# root = os.getcwd()
root = os.path.split(os.path.abspath(__file__))[0]
print(__file__)

workspace = f'{root}/reg_test'
reg_wkbk = f'{workspace}/regen_rx.xlsx'

fvs_variant = 'PN'
forest_code = 612

try:
    os.makedirs(workspace)
except:
    pass

df = pd.read_excel(reg_wkbk, sheet_name='stands')
plot = df.iloc[0]
veg_lbl = plot['veg_lbl']

df = pd.read_excel(reg_wkbk, sheet_name='trees')
rx_trees = df.loc[df['veg_lbl']==veg_lbl].copy()

sim = fvs.FVS(fvs_variant, workspace=workspace, cleanup=False)

kw = sim.init_keywords()
kw += kwds.STDINFO(
    location=forest_code
    , slope=plot['slope']
    , aspect=plot['aspect']
    , elevation=plot['elev_code']
)
kw += kwds.DESIGN()
kw += kwds.TIMEINT(0,10)
kw += kwds.NUMCYCLE(1)
kw += kwds.TREELIST(0)
kw += kwds.ECHOSUM()

kw += kwds.SITECODE(plot['site_spp'], plot['site_phy'])
# kw += kwds.NOTREES()

# print(list(trees.columns))

rx_trees['diameter_growth'] = 0.0
rx_trees['height_growth'] = 0.0
rx_trees['total_height'] = 0.0

# Map the trees data column names to FVS tree array names
field_map = dict(
  plot_id='plot'
  , tree_id = 'tree'
  , history = 'status'
  , species='spcd'
  , prob='tpa'
  , diameter = 'diam'
  , diameter_growth = 'diameter_growth'
  , height = 'ht'
  , total_height = 'total_height'
  , height_growth = 'height_growth'
  , crown = 'cr_code'
  , age = 'age'
)

fm = {v:k for k,v in field_map.items()}
rx_trees.rename(columns=fm, inplace=True)

# print(rx_trees.columns)

# Pass the trees dataframe to the FVS instance
sim.inventory_trees = rx_trees

# inv.print_trees()

# sim.init_projection(kw)
# r = sim.run()
# r = sim.execute_projection(kw)
sim.keywords = kw
r = sim.run()
print(sim.summary)

print('FVS Return Code: %s' % r)
# self.assertEqual(r, 0, 'FVS Return Code: %s' % r)
