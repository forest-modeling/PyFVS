'''
Created on Feb 2, 2016

@author: THAREN
'''

import unittest
import pytest

import numpy as np
import pandas as pd

from pyfvs import fvs
from pyfvs.keywords import keywords as kw

fvs_variant = 'PN'

class TreesTest(unittest.TestCase):

    def test_fvs_trees(self):

        # wkspc = '/mnt/c/workspace/pyfvs/src/tests'
        wkspc = None

        # Start by populating inventory trees with the PyFVS interface
        f = fvs.FVS(fvs_variant, workspace=wkspc, cleanup=True)

        inv_trees = pd.DataFrame(dict(
            plot_id=[1,1,1],
            tree_id=[1,2,3],
            species=['DF','WH','RA'],
            prob=[175,125,50],
            diameter=[0.1,0.1,0.1]
            ))
        f.inventory_trees = inv_trees

        kwds = f.keywords
        kwds += kw.STDINFO(712, 'CHS131', 0, 200, 35, 6)
        kwds += kw.MANAGED(0, True)
        kwds += kw.INVYEAR(2010)
        kwds += kw.DESIGN(0, 1, 999, 1, 0, 1, 1)
        kwds += kw.NUMCYCLE(40)
        # kwds += kw.NOTREES()

        r = f.execute_projection()
        print('FVS Return Code: %s' % r)
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        # Compute stand summaries from tree level values for each cycle
        def sum(rows):
            r = dict(
                tpa=rows['live_tpa'].sum(),
                baa=(rows['live_tpa']*(rows['live_dbh']**2)*0.005454154).sum(),
                tcuft=(rows['live_tpa']*rows['cuft_total']).sum(),
                mcuft=(rows['live_tpa']*rows['cuft_net']).sum(),
                mbdft=(rows['live_tpa']*rows['bdft_net']).sum(),
                )
            return pd.Series(r)

        df = f.trees.groupby('cycle').apply(sum)

        assert df['tpa'][0]==350.0
        assert (df['tpa']>0).all()

        # Ensure the tree-level summaries match the FVS summary table within rounding error
        assert np.isclose(f.summary['tpa'], df['tpa'].to_numpy(), atol=1).all()
        assert np.isclose(f.summary['baa'], df['baa'].to_numpy(), atol=1).all()
        assert np.isclose(f.summary['tcuft'], df['tcuft'].to_numpy(), atol=1).all()
        assert np.isclose(f.summary['mcuft'], df['mcuft'].to_numpy(), atol=1).all()
        assert np.isclose(f.summary['mbdft'], df['mbdft'].to_numpy(), atol=1).all()

        inv_summary = df.copy()

        #####
        # Rerun the same tree list, but initialized from a "tre" file
        #####
        f = fvs.FVS(fvs_variant, workspace=wkspc, cleanup=False)
        
        kwds = f.keywords
        kwds += kw.STDINFO(712, 'CHS131', 0, 200, 35, 6)
        kwds += kw.MANAGED(0, True)
        kwds += kw.INVYEAR(2010)
        kwds += kw.DESIGN(0, 1, 999, 1, 0, 1, 1)
        kwds += kw.NUMCYCLE(40)
        kwds += kw.TREEFMT('T7,I4,T1,I4,T14,F3.0,I1,A3,F3.1,F2.1,T30,F3.0,T40,F3.0,T50,F3.1,T60,I1,T65,I2,T70,5I1,T75,7I1,T80,F3.0')
        kwds += kw.TREEDATA()

        trl = (
            '1     0101   1751DF 001\n'
            '2     0101   1251WH 001\n'
            '3     0101   0501RA 001\n'
            )
        with open(f.treelist_path, 'w') as fp:
            fp.write(trl)

        r = f.execute_projection()
        print('FVS Return Code: %s' % r)
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        # Compute stand summaries from tree level values for each cycle
        def sum(rows):
            r = dict(
                tpa=rows['live_tpa'].sum(),
                baa=(rows['live_tpa']*(rows['live_dbh']**2)*0.005454154).sum(),
                tcuft=(rows['live_tpa']*rows['cuft_total']).sum(),
                mcuft=(rows['live_tpa']*rows['cuft_net']).sum(),
                mbdft=(rows['live_tpa']*rows['bdft_net']).sum(),
                )
            return pd.Series(r)

        tre_summary = f.trees.groupby('cycle').apply(sum)

        assert (inv_summary.to_numpy()==tre_summary.to_numpy()).all()


if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
#     kwds = bg_kwds()
#     print(kwds)
