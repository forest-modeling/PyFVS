import unittest

from pyfvs import fvs
from pyfvs.keywords import keywords as kw

def bg_kwds():
    """
    A simple monoculture bare ground simulation
    """
    kwds = kw.KeywordSet(top_level=True)
    kwds += kw.STDIDENT('BARE', 'Bare ground, plant 350 DF')
    kwds += kw.STDINFO(712, 'CHS131', 0, 1000, 35, 6)
    kwds += kw.MANAGED(0, True)
    kwds += kw.DESIGN(0, 1, 999, 1, 0, 1, 1)
    kwds += kw.NUMCYCLE(10)
    kwds += kw.NOTREES()

    estab = kw.ESTAB(0)
    estab += kw.PLANT(1, 'DF', 350, 95, 2, 1, 0)
    kwds += estab

    kwds += kw.ECHOSUM()

    return kwds

fvs_variant = 'PN'
min_bdft = 15000
min_baa = 175
min_total_cuft = 3500
min_merch_cuft = 3000
# min_saw_cuft = 4500 # Sawtimber volume applies to easter variants, sawlog + pulp

class TreesTest(unittest.TestCase):

    def test_minharv(self):

        # First run should result in removed volume, e.g. all minimums are met
        f = fvs.FVS(fvs_variant)
        kwds = f.keywords
        kwds += bg_kwds()
        kwds += kw.THINBBA(5,80) # Thin to a residual BAA of 80 sqft at age 50
        kwds += kw.MINHARV(
            0,
            min_baa=min_baa,
            min_total_cuft=min_total_cuft,
            min_merch_cuft=min_merch_cuft,
            # min_saw_cuft=min_saw_cuft,
            min_bdft=min_bdft
            )
        r = f.execute_projection()
        
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        rem_mbdft = f.summary['rem_mbdft'].sum()
        self.assertTrue(rem_mbdft>0, f'Expected harvest did not occur')

        # Subsequent tests should not implement the harvest, e.g. no individual minimums are satisfied

        # BAA
        f = fvs.FVS(fvs_variant)
        kwds = f.keywords
        kwds += bg_kwds()
        kwds += kw.THINBBA(5,80)
        kwds += kw.MINHARV(0, min_baa=200) # BAA before thinning should be about 255 sqft
        r = f.execute_projection()
        
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        rem_mbdft = f.summary['rem_mbdft'].sum()
        self.assertTrue(rem_mbdft==0, f'Min BAA failed. Expected no harvest volume, but got mbdft={rem_mbdft}')

        # total cuft
        f = fvs.FVS(fvs_variant)
        kwds = f.keywords
        kwds += bg_kwds()
        kwds += kw.THINBBA(5,80)
        kwds += kw.MINHARV(0, min_total_cuft=5000) # Expected harvest would be ~4090
        r = f.execute_projection()
        
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        rem_mbdft = f.summary['rem_mbdft'].sum()
        self.assertTrue(rem_mbdft==0, f'Min total cuft failed. Expected no harvest volume, but got mbdft={rem_mbdft}')

        # merch cuft
        f = fvs.FVS(fvs_variant)
        kwds = f.keywords
        kwds += bg_kwds()
        kwds += kw.THINBBA(5,80)
        kwds += kw.MINHARV(0, min_merch_cuft=4000) # Expected harvest would be ~3750
        r = f.execute_projection()
        
        self.assertEqual(r, 0, 'FVS Return Code: %s' % r)

        rem_mbdft = f.summary['rem_mbdft'].sum()
        self.assertTrue(rem_mbdft==0, f'Min total cuft failed. Expected no harvest volume, but got mbdft={rem_mbdft}')

if __name__ == "__main__":
    unittest.main()
