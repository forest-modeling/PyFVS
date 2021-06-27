# Open-FVS FMSCrelease-ci

This is a continuous integration branch of the Open-FVS/FMSCrelease mirror.

This is an unofficial mirror provided as a convenience to the FVS user
community. Users are referred to the USFS [website](https://www.fs.fed.us/fvs/) 
for supported versions of FVS.

SVN - [FMSCrelease][sourceforge_url]
  
GitHub - 
[FMSCrelease](https://github.com/forest-modeling/open-fvs-mirror/tree/FMSCrelease)
([FMSCrelease-ci](https://github.com/forest-modeling/open-fvs-mirror/tree/FMSCrelease-ci))

# CI Builds
Continuos integration builds are performed as new commits are added 
from the SVN repository. CI builds are provided by AppVeyor and Travis-CI.
Compiled binaries are tested against assumed good outputs for consistency.
Successful builds are tagged and binary artifacts are uploaded to GitHub releases.

| Branch | AppVeyor | Travis-CI |
| ------ | :------: | :-------: |
|[FMSCrelease-ci][appveyor_url]|[![Build status](https://ci.appveyor.com/api/projects/status/ww7ygykde0kdly3c/branch/FMSCrelease-ci?svg=true)][appveyor_url]||

[sourceforge_url]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/branches/FMSCrelease/
[appveyor_url]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/FMSCrelease-ci
