# Open-FVS Trunk

This is a continuous integration branch of the Open-FVS/trunk mirror.

This is an unofficial mirror provided as a convenience to the FVS user
community. Users are referred to the USFS [website](https://www.fs.fed.us/fvs/) 
for supported versions of FVS.

SVN - [trunk][trunk_svn]
GitHub
  [trunk](https://github.com/forest-modeling/open-fvs-mirror/tree/trunk)
  [trunk-ci](https://github.com/forest-modeling/open-fvs-mirror/tree/trunk-ci)

# CI Builds
Continuos integration builds are performed as new commits are added 
from the SVN repository. CI builds are provided by AppVeyor and Travis-CI.
Compiled binaries are tested against against assumed good outputs for consistency.
Successful builds are tagged and binary artifacts are uploaded to GitHub releases.

| Branch | AppVeyor | Travis-CI |
| ------ | :------: | :-------: |
|[trunk][trunk_svn]|[![Build status](https://ci.appveyor.com/api/projects/status/eyyqq4a57xk0ttt0/branch/trunk-ci?svg=true)][trunk_appveyor]||

[trunk_svn]: https://sourceforge.net/p/open-fvs/code/HEAD/tree/trunk/
[trunk_appveyor]: https://ci.appveyor.com/project/tharen/open-fvs-mirror/branch/trunk-ci
