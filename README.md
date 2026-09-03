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

```Text
  _____            ______ __      __  _____ 
 |  __ \          |  ____|\ \    / / / ____|
 | |__) | _    _  | |__    \ \  / / | (____  
 |  ___/ | |  | | |  __|    \ \/ /   \___  \ 
 | |     | |__| | | |        \  /    ____) |
 |_|      \____ | |_|         \/    |______/ 
            __/ |                            
           |___/
```

### Project Status
- ![GitHub Tag](https://img.shields.io/github/v/tag/forest-modeling/PyFVS)

- [![Github Actions](https://github.com/forest-modeling/PyFVS/actions/workflows/python-package.yml/badge.svg)](https://github.com/forest-modeling/PyFVS/actions/workflows/python-package.yml)

- [![PyPI-Server](https://img.shields.io/pypi/v/PyFVS.svg)](https://pypi.org/project/PyFVS/)

- [![Monthly Downloads](https://pepy.tech/badge/PyFVS/month)](https://pepy.tech/project/PyFVS)

PyFVS wraps a [fork](https://github.com/forest-modeling/ForestVegetationSimulator) of the official [FVS code](https://github.com/USDAForestService/ForestVegetationSimulator) with minimal, non-core, modifications.

PyFVS currently supports Windows and Linux using the GCC family of compilers.

> **Disclaimer**
> PyFVS is an independent project. It is **not affiliated with or supported by** the USFS staff or service center.

## Features

 - FVS Class
   - FVS Step API
     - Growth cycle interation
     - Within-cycle blocking callbacks for fine-grained inspection and sub-model interaction
   - Initialize inventory trees from arrays and dataframes
   - Runtime interaction with FVS internal arrays and variables
     - Facilitates out-of-core event logic
     - Sub-cycle analysis of model components and data

 - Keyword Generator:
   - Object oriented FVS keyword file generation
   - Automates keyword file formatting and runtime handling

 - Command line interface

## Variants

Not all FVS variants are currently implement. More will be added as time allows.

 - PN - Pacific Northwest Coast
 - WC - Westside Cascades
 - SO - South Central Oregon and Northeast California
 - OP - ORGANON Pacific Northwest
 - OC - ORGANON Southwest
 - EC - East Cascades
 - CA - Inland California and Southern Cascades
 - NC - Klamath Mountains (Northern California)
 - BM - Blue Mountains
 - IE - Inland Empire (Northern Idaho)
 - CI - Central Idaho
 - AK - Alaska
 - WS - Western Sierra Nevada

## Parity with Official Binaries

PyFVS is designed to be consistent with the official FVS 
binaries. Before a release all variants are run through a series 
of unit test to ensure functionality and equivalence with 
official FVS binaries.

 - Variant specific unit tests from official FVS releases
 - Additional unit tests for specific functionality

## Documentation

Check out the AI generated documentation [wiki](https://deepwiki.com/forest-modeling/PyFVS).

## Installation

PyFVS is available through PyPI for Windows and Linux. In addition, packages for OS X are available through conda-forge.

### PyPI

``` bash
>python -m pip install pyfvs
```

or with Pixi 

``` bash
>pixi add --pypi pyfvs
```

### conda-forge
**NOTE:** Releases to conda-forge may lag behind PyPI

``` bash
>conda install pyfvs
```
or with Pixi

``` bash
pixi add pyfvs
```

## Usage

**NOTE:** The PyFVS API is beta. Names and arguments may change as
features evolve. Deprecation warnings will be raised when possible.
However, there is guarantee of backward compatibility.

### Command Line

``` bash
>pyfvs --help
>pyfvs list-variants
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
f.grow_all()
# Print the summary table
print(f.summary)
```

### Development

Clone the 'dev' branch, including all submodules
```bash
git clone --branch dev --recurse-submodules https://github.com/forest-modeling/PyFVS.git
```

For local development a Pixi environment is included in `pyproject.toml`.

```bash
# Install Pixi on Linux
curl -fsSL https://pixi.sh/install.sh | sh
```

```powershell
# Install Pixi on Windows
powershell -ExecutionPolicy Bypass -c "irm -useb https://pixi.sh/install.ps1 | iex"
```

Initialize the environment in the root of the project
```bash
pixi init --pyproject
```
```bash
pixi shell
```

#### Local Development Build
The Pixi environment includes GCC and GFortran compilers from Conda-Forge. Use the included Pixi task to install PyFVS in the
current environment in development mode. Pass an optional comma separated list of lower case variant abbreviations to restrict the build to target variants. Additionally, an optional build mode can be passed, debug or release.

```bash
pixi run dev "pn,wc" debug
```

Development mode in Pixi is consistent with Pip. Additionally, 
PyFVS is built with Meson and Meson-Python. Changes to source files, Python 
or Fortran, will trigger a recompile on the next import. 
Alternatively, you can trigger a build by calling the dev task
again.

#### Run Tests

```bash
pixi run test
```

#### Build Wheels
Wheel files for the current system will be placed in the dist folder along with an sdist source archive.

```bash
pixi run build "pn,wc"
```
