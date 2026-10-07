# Changelog

This changelog records noteable changes to the PyFVS code base.
Changes to the core FVS will not be echoed here unless they result in changes the affecting the PyFVS implementation.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added
### Changed
### Fixed
### Security
### Deprecated
### Removed

## [0.3.10] - 2026-10-05

### Added

- Integrated core FVS release [FS2026.3](https://github.com/USDAForestService/ForestVegetationSimulator/releases/tag/FS2026.3)

- Wrappers for FVS core subroutine `htdbh`, which has utility outside of the FVS runtime and supports bidirectional height-DBH estimation. Two functions were added: `fvs_api.calc_height` and `fvs_api.calc_dbh`. Each takes arguments for forest code, species code, and DBH or height, respectively.

- Properties to return the core FVS version and build info. `fvs.FVS.fvs_version` returns a string representing the core FVS version tag. `fvs.FVS.fvs_build_info` reports the more detail Git commit metadata as a Python dictionary.

- Unit test for

### Changed

- Variant test outputs (tests/rmrs) regenerated with the official FVS software release binaries (20260701).

### Fixed

- `FVS.trees` reports correct values for runtime treelists. Recent changes to FVS core revised the working arrays used for tracking several 
biometrics between growth cycles. The PyFVS API captures these values at runtime in the `tree_data` module. The working array change resulted in 
incorrect values being transferred into the PyFVS data.

- Update MINHARV keyword to reflect changes in core FVS 

### Removed

- Outdated CMakeLists.txt and associated support files. PyFVS is built using Meson and meson-python. 
  Originally PyFVS used a CMake build system adapted from the core FVS build system. This system
  was difficult to maintain relative to Meson and has been abandoned for some time now.

[0.3.10]: https://github.com/forest-modeling/PyFVS/releases/tag/v0.3.10