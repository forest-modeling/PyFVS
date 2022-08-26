"""
Test PyFVS IO using FIA data
"""

import os
import unittest
import pytest
import sqlite3

import pandas as pd

from pyfvs import fvs
from pyfvs.keywords import keywords as kwds

root = os.path.split(os.path.abspath(__file__))[0]

workspace = f'{root}/fia_test'
fia_db = f'{root}/fia_test.db'
fvs_variant = 'PN'
forest_code = 612

class TreesTest(unittest.TestCase):

    def test_fsv_trees(self):

        try:
            os.makedirs(workspace)
        except:
            pass

        with sqlite3.connect(fia_db) as conn:
            plot = pd.read_sql('select * from plot', conn).iloc[0]
            plot_cn = plot['cn']

            ## FIXME: Aggregate condition or constrain trees to condition
            cond = pd.read_sql(f"select * from cond where plt_cn='{plot_cn}'", conn).iloc[0]
            
            trees = pd.read_sql(f"select * from tree where plt_cn='{plot_cn}'", conn)
            # site_tree = pd.read_sql(f"select * from sitetree where plt_cn='{plot_cn}'", conn)

        sim = fvs.FVS(fvs_variant, workspace=workspace, cleanup=False)

        # Translate species codes from FIA numeric to FVS alpha
        fia_spp_map = dict(zip(
            sim.spp_fia_codes.values(),sim.spp_fia_codes.keys()
        ))

        # Populate the keywords
        kw = sim.init_keywords(title=plot_cn)
        kw += kwds.STANDCN(plot_cn)
        kw += kwds.STDINFO(
            location=forest_code
            , slope=cond['slope']
            , aspect=cond['aspect']
            , elevation=plot['elev']
        )
        kw += kwds.DESIGN()
        kw += kwds.TIMEINT(0,10)
        kw += kwds.NUMCYCLE(1)

        kw += kwds.SITECODE(fia_spp_map[cond['sisp']], cond['sicond'])

        trees['plot_id'] = 1
        trees['diameter_growth'] = 0.0
        trees['height_growth'] = 0.0
        trees['total_height'] = 0.0

        # Map the FIA column names to inventory_trees array names
        field_map = dict(
          plot_id='plot_id'
          , tree_id = 'tree'
          , history = 'statuscd'
          , species='spcd'
          , prob='tpa_unadj'
          , diameter = 'dia'
          , diameter_growth = 'diameter_growth'
          , height = 'ht'
          , total_height = 'total_height'
          , height_growth = 'height_growth'
          , crown = 'cr'
          , age = 'totage'
        )

        fm = {v:k for k,v in field_map.items()}
        trees.rename(columns=fm, inplace=True)

        # Pass the trees dataframe to the FVS instance
        sim.inventory_trees = trees

        r = sim.execute_projection(kw)

        print('FVS Return Code: %s' % r)
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
#     kwds = bg_kwds()
#     print(kwds)
