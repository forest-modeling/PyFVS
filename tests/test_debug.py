import os

import pyfvs
from pyfvs import fvs

root = os.path.split(__file__)[0]

variant = 'PN'
kwds = 'rmrs/pn_bareground.key'
save = 'rmrs/pn_bareground.sum.save'

def py_callback(stage):
    """
    A function that is called by FVS from various locations during the simulation loop

    Args
    ----
    stage: Integer indicating the current growth cycle location
    """
    print(f'FVS stage: {stage}')
    rtn = 0
    return rtn

f = fvs.FVS(variant)
# f.fvs_step.init_params()

print('init - with callback')
f.init_projection(os.path.join(root, kwds))

for c in range(f.globals.ncyc):
  print(f'Cycle: {c}')
  r = f.fvs_step.fvs_grow(py_callback)
  if r!=0:
    print(f'FVS Grow Error Code: {r}')
    break

r = f.end_projection()


f = fvs.FVS(variant)
# f.fvs_step.init_params()

print('\n\ninit - no callback')
f.init_projection(os.path.join(root, kwds))

for c in range(f.globals.ncyc):
  print(f'Cycle: {c}')
  r = f.fvs_step.fvs_grow()
  if r!=0:
    print(f'FVS Grow Error Code: {r}')
    break

r = f.end_projection()

print('Done')