import pyfvs.fvs

variant = 'ec'
keywords = f'c:/workspace/forest-modeling/pyfvs/pyfvs/test/rmrs/{variant}_bareground.key'
f = pyfvs.fvs.FVS(variant)

f.execute_projection(keywords)

print(f.summary)