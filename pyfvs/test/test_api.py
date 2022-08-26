"""
Test PyFVS API
"""

import os
import unittest
import pytest
import sqlite3

import pandas as pd

from pyfvs import fvs
from pyfvs.keywords import keywords as kwds

root = os.path.split(os.path.abspath(__file__))[0]

workspace = f'{root}/api_test'
fvs_variant = 'PN'
forest_code = 612

class TreesTest(unittest.TestCase):

    def test_mrule(self):

        try:
            os.makedirs(workspace)
        except:
            pass

        sim = fvs.FVS(fvs_variant, workspace=workspace, cleanup=False)

        kw = sim.keywords
        kw += kwds.STDINFO(location=forest_code)
        kw += kwds.DESIGN()
        kw += kwds.NUMCYCLE(10)
        kw += kwds.NOTREES()

        estab = kwds.ESTAB()
        estab += kwds.PLANT(1,'DF',350)

        kw += estab

        sim.run()

        default_summary = sim.summary.copy()

        sim = fvs.FVS(fvs_variant, workspace=workspace, cleanup=False)
        sim.fvslib.globals.use_api_mrules = True
        sim.fvslib.globals.mrule_maxlen = [40,32]

        kw = sim.keywords
        kw += kwds.STDINFO(location=forest_code)
        kw += kwds.DESIGN()
        kw += kwds.NUMCYCLE(10)
        kw += kwds.NOTREES()

        estab = kwds.ESTAB()
        estab += kwds.PLANT(1,'DF',350)

        kw += estab

        sim.run()

        test_summary = sim.summary.copy()

        print(default_summary)
        print(test_summary)

if __name__ == "__main__":
    unittest.main()
