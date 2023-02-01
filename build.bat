@REM conda activate pyfvs38
@REM set variants=pn,wc,so,op,oc
@REM set variants=pn,wc,so,op,oc,ec,ca
set variants=pn

python setup.py develop --no-deps -- -DFVS_VARIANTS=%variants%