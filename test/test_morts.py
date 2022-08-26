from pyfvs import fvs

kwds = 'test/nc_carbon.key'

f = fvs.FVS('wc')
f.globals.use_fvs_morts=True

f.execute_projection(kwds=kwds)
print(f.summary)