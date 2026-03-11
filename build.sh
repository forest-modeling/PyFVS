export fvs_variants=pn,wc

python -m pip install --no-build-isolation -v -e . \
  --config-settings=editable-verbose=true \
  --config-settings=setup-args="-Dfvsvariants=$fvs_variants"
  --config-settings=build-dir="build-wsl" \
  