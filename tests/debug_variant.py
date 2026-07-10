import pyfvs.fvs

variant = 'wc'
keywords = f'tests/rmrs/{variant}_bareground.key'
f = pyfvs.fvs.FVS(variant)

f.execute_projection(keywords)

print(f.summary)