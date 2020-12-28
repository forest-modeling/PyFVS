# Open-FVS Mirror

This is a mirror of the official Open-FVS code. This is an unofficial 
mirror provided as a convenience to the FVS user community. Compiled
binaries are provided as-is.

Users are referred to the USFS [website](https://www.fs.fed.us/fvs/) 
for supported versions of FVS.

The mirror was created using Git-SVN. Currently this is intended to be
a one-way copy of the SVN repository. Upstream contributions can be
submitted by cloning/forking this repository and pushing directly to the 
SVN repository. Instructions on setting up a SVN remote on a local 
instance are available [here](docs/mirror_notes.md).

# Mirrored Branches

Only a subset of branches are mirrored. These are kept pure, e.g. 
only SVN commits are included in these branches. Other branches 
can generally be added on request.

 - [trunk](https://github.com/tharen/open-fvs-mirror/tree/trunk)
 - [FMSCrelease](https://github.com/tharen/open-fvs-mirror/tree/FMSCrelease)
 - [FMSCdev](https://github.com/tharen/open-fvs-mirror/tree/FMSCdev)
 - [PyFVS](https://github.com/tharen/open-fvs-mirror/tree/PyFVS)

# CI Builds
Continuos integration builds are performed as new commits are added 
from the SVN repository. CI builds are provided by AppVeyor and Travis-CI.
Successful builds are tagged and binary artifacts are automatically uploaded
to GitHub releases. Each mirrored branch is tracked by a companion '-ci' branch.

| Branch | AppVeyor | Travis-CI |
| ------ | :------: | :-------: |
|[trunk][11]|[![Build status](https://ci.appveyor.com/api/projects/status/eyyqq4a57xk0ttt0/branch/trunk-ci?svg=true)][13]||
|[FMSCrelease][21]|[![Build status](https://ci.appveyor.com/api/projects/status/eyyqq4a57xk0ttt0/branch/FMSCrelease-ci?svg=true)][23]||
|[FMSCdev][31]|[![Build status](https://ci.appveyor.com/api/projects/status/eyyqq4a57xk0ttt0/branch/FMSCdev-ci?svg=true)][33]||
|[PyFVS][41]|[![Build status](https://ci.appveyor.com/api/projects/status/eyyqq4a57xk0ttt0/branch/PyFVS-ci?svg=true)][43]||

[11]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/trunk/
[13]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/trunk-ci

[21]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/FMSCrelease/
[23]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/FMSCrelease-ci

[31]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/FMSCdev/
[33]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/FMSCdev-ci

[41]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/PyFVS/
[43]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/PyFVS-ci

## Main Branch

The "main" branch is an orphan and is maintained for documentation and 
to provide a GitHub landing page. 