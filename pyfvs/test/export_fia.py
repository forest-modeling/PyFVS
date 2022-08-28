"""
Export some FIA data for FVS testing
"""

import sqlite3
import pandas as pd

fiadb_path = 'c:/data/fia/FIADB_OR.db'
out_path = 'c:/workspace/forest-modeling/PyFVS/pyfvs/test/fia_test.db'
tables = ['plot','cond','tree','sitetree']
data = {}
plot_cns = ['23850662010900',]

# read the plot data
with sqlite3.connect(fiadb_path) as conn:
    sql = f'select * from plot where cn in ({",".join(plot_cns)})'
    df = pd.read_sql(sql, conn)
    df.columns = [c.lower() for c in df.columns]
    data['plot'] = df

    for tbl in tables[1:]:
        sql = f'select * from {tbl} where plt_cn in ({",".join(plot_cns)})'
        df = pd.read_sql(sql, conn)
        df.columns = [c.lower() for c in df.columns]
        data[tbl] = df
        
# Export the plot data
with sqlite3.connect(out_path) as conn:
    for tbl in tables:
        df = data[tbl]
        df.to_sql(tbl, conn, index=False, if_exists='replace')