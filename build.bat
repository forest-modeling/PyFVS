@REM conda activate pyfvs310
@REM set fvs_variants=pn,wc,so,op,oc
@REM set fvs_variants=pn,wc,so,op,oc,ec,ca
set fvs_variants=pn,wc,ca,so
@REM set fvs_variants=so

@REM check for gfortran.exe

python -m pip install -v -e . --no-build-isolation ^
  --config-settings=editable-verbose=true ^
  --config-settings=setup-args="-Dfvsvariants=%fvs_variants%"
