@REM pixi shell -e py312
@REM set fvs_variants=pn,wc,so,op,oc
@REM set fvs_variants=pn,wc,so,op,oc,ec,ca
set fvs_variants=pn,wc,ca,so
@REM set fvs_variants=so

@REM check for gfortran.exe

python -m pip install -v -e . --no-build-isolation ^
  --config-settings=editable-verbose=true ^
  --config-settings=setup-args="-Dfvsvariants=%fvs_variants%" ^
  --config-settings=build-dir="build-win-py312"
