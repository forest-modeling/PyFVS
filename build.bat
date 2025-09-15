@REM conda activate pyfvs310
@REM set variants=pn,wc,so,op,oc
@REM set variants=pn,wc,so,op,oc,ec,ca
set variants=pn,wc

@REM check for rtools40/ucrt64/bin/gfortran.exe

python -m pip install --no-build-isolation -v -e . ^
  --config-settings=editable-verbose=true ^
  --config-settings=setup-args="-Dfvsvariants=%variants%"
