import os
import unittest
import pytest
import pandas as pd
import numpy as np

import pyfvs
from pyfvs import fvs

root = os.path.split(__file__)[0]
variant = 'pn'
kwd_path = f'{root}/rmrs/{variant}_bareground.key'
sum_path = f'{root}/rmrs/{variant}_bareground.sum.save'

f = fvs.FVS(variant)

f.init_projection(os.path.join(root, kwd_path))
f.tree_data.live_tpa[:, :] = 0.0

for c in range(f.globals.ncyc):
    r = f.grow()

r = f.end_projection()
assert r == 0

widths = [4, 4, 6, 4, 5, 4, 4, 5, 6, 6, 6, 6, 6, 6, 6, 4, 5, 4, 4, 5, 8, 5, 6, 8, 4, 2, 1]
fldnames = (
        'year,age,tpa,baa,sdi,ccf,top_ht,qmd,total_cuft'
        ',merch_cuft,merch_bdft,rem_tpa,rem_total_cuft'
        ',rem_merch_cuft,rem_merch_bdft,res_baa,res_sdi'
        ',res_ccf,res_top_ht,resid_qmd,grow_years'
        ',annual_acc,annual_mort,mai_merch_cuft,for_type'
        ',size_class,stocking_class'
        ).split(',')

# Read the sum file generated by the "official" FVS executable
sum_check = pd.read_fwf(os.path.join(root, sum_path), skiprows=0, widths=widths)
sum_check.columns = fldnames

ncyc = f.globals.ncyc

# Cut BdFt +/- 1
cut_tpa = f.tree_data.cut_tpa[:, :ncyc + 1]
bdft = f.tree_data.bdft_net[:, :ncyc + 1]
cut_bdft = np.round(np.sum(cut_tpa * bdft, axis=0), 0).astype(int)
check_cut = sum_check.loc[:, 'rem_merch_bdft'].values
print(np.round(np.sum(cut_tpa, axis=0), 0).astype(int))
print(cut_bdft)
print(check_cut)
assert np.all(np.isclose(check_cut, cut_bdft, atol=1))