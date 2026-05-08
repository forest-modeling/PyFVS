import os

from pyfvs import fvs

root = os.path.split(__file__)[0]
kwds = root + '/nc_carbon.key'

f = fvs.FVS('pn')
f.fvs_api.use_fvs_morts=True

f.execute_projection(kwds=kwds)
print(f.summary)