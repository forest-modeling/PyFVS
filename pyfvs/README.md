# PyFVS
Python wrappers and utilities for using the Forest Vegetation Simulator


# Repository Notes

Open-FVS
--------
Open-FVS was added using the Git subtree utility.
  '''
  # Add the remote
  git remote add -f open-fvs-mirror https://github.com/forest-modeling/open-fvs-mirror.git
  # Clone the branch to the subdirectory
  git subtree add --prefix open-fvs open-fvs-mirror trunk --squash
  # Pull updates from the branch
  git subtree pull --prefix open-fvs open-fvs-mirror trunk --squash
  '''

# CMake Build

scikit-build is used as the glue for the PyFVS build.

Top level CMakeLists.txt
  open-fvs subdir
  pyfvs subdir

