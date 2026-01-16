<!-- These are examples of badges you might want to add to your README:
     please update the URLs accordingly

[![Built Status](https://api.cirrus-ci.com/github/forest-modeling/PyFVS.svg?branch=main)](https://cirrus-ci.com/github/forest-modeling/PyFVS)
[![ReadTheDocs](https://readthedocs.org/projects/PyFVS/badge/?version=latest)](https://PyFVS.readthedocs.io/en/stable/)
[![Coveralls](https://img.shields.io/coveralls/github/<USER>/PyFVS/main.svg)](https://coveralls.io/r/<USER>/PyFVS)
[![PyPI-Server](https://img.shields.io/pypi/v/PyFVS.svg)](https://pypi.org/project/PyFVS/)
[![Conda-Forge](https://img.shields.io/conda/vn/conda-forge/PyFVS.svg)](https://anaconda.org/conda-forge/PyFVS)
[![Monthly Downloads](https://pepy.tech/badge/PyFVS/month)](https://pepy.tech/project/PyFVS)
[![Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Twitter)](https://twitter.com/PyFVS)
-->

# PyFVS

Python wrappers and utilities for using the Forest Vegetation Simulator

The PyFVS [FVS source code](https://github.com/forest-modeling/ForestVegetationSimulator/tree/open-dev) is forked from the [USFS FVS GitHub](https://github.com/USDAForestService/ForestVegetationSimulator) repository, [open-dev](https://github.com/USDAForestService/ForestVegetationSimulator/tree/open-dev) branch

## Documentation

Check out the new AI generated documentation [wiki](https://deepwiki.com/forest-modeling/PyFVS).

## Features

 - FVS Class
   - FVS Step API - Iterate projection cycles
   - Initialize inventory trees from arrays
   - Access to all FVS internal arrays and variables

 - Keywords - Object based FVS keyword file generation

 - Command line interface

Documentation forthcoming

## Usage

**NOTE:** The PyFVS API is beta. Names and arguments may change as
features evolve. Deprecation warnings will be raise when possible.
However, there is guarantee of backward compatibility.

### Command Line

``` bash
>pyfvs --help
>pyfvs run PN -k path/to/keywords.key
```

### Run a simulation using an existing keyword file and treelist

``` Python
from pyfvs import fvs
f = fvs.FVS('PN')
kwds = 'path/to/keywords.key'
f.init_projection(kwds)

# Iterate through the simulation cycles
for cycle in f:
    print(f.year)
    # Do something interesting

# Closeout the simulation
f.end_projection()
```

### Genarate keywords for a bareground simulation

``` Python
from pyfvs import fvs,keywords
f = fvs.FVS('PN')
# Setup the KeywordSet for the simulation
kw = f.keywords
# Grow for 20 periods
kw += keywords.NUMCYCLE(20)
# Add default STDINFO keyword
kw += keywords.STDINFO()
# This is a bareground simulation, so no treelist
kw += keywords.NOTREES()
# Initialize the ESTAB keywordset
est = keywords.ESTAB()
# Add 350 planted DF seedlings to the ESTAB
est += keywords.PLANT(1,'DF',350)
# Add the ESTAB keywordset to the simulation
kw += est
# Execute the simulation
f.run()
# Print the summary table
print(f.summary)
```



<!-- pyscaffold-notes -->

## Note

This project has been set up using PyScaffold. For details and usage
information on PyScaffold see https://pyscaffold.org/.
