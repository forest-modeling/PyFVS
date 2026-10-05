# Build PyFVS with Meson+Ninja
# Adapted from SciPy, https://github.com/scipy/scipy/blob/main/meson.build

project(
  'pyfvs',
  'c', 'cpp',
  meson_version: '>= 1.8',
  default_options : [
    'buildtype=debugoptimized',
    'c_std=c99',
    'cpp_std=c++14',
    'fortran_std=legacy',
    # 'fortran_std=f2003',
    #'blas=openblas',
    #'lapack=openblas'
    ],
  version: run_command('python','-m','setuptools_scm', check:true).stdout().strip().split('+')[0],
  # version: '0.3.0.dev0'
  )

fs = import('fs')

# variants = ['pn','op','wc','ca'] #,'so','oc','ec','nc','bm']
# variants = ['pn',]
# variants = ['pn','wc','ca','so']
# variants can be set in meson_options.txt or with command line arguments '-Dfvsvariants=pn,wc,op'
variants = get_option('fvsvariants')

message('******************************************************************')
message('Building FVS variants: @0@'.format(variants))
message('******************************************************************')

project_folder = meson.project_source_root()

sqlite_c_args = ['-DSQLITE_THREADSAFE=0','-DSQLITE_OMIT_LOAD_EXTENSION']

# Compiler settings
mingw = meson.get_compiler('c').get_id() == 'mingw'
cc = meson.get_compiler('c')

# Map variants to library names
variant_libs = {}

## TODO: SciPy suppresses many compiler warnings, copy that here

m_dep = cc.find_library('m', required : false)
if m_dep.found()
  add_project_link_arguments('-lm', language : 'c')
endif

# Adding at project level causes many spurious -lgfortran flags.
add_languages('fortran', native: false)
ff = meson.get_compiler('fortran')
if ff.has_argument('-Wno-conversion')
  add_project_arguments('-Wno-conversion', language: 'fortran')
endif

is_windows = host_machine.system() == 'windows'

# https://mesonbuild.com/Python-module.html
py_mod = import('python')
py3 = py_mod.find_installation(pure: false)
py3_dep = py3.dependency()
message(py3.full_path())
message(py3.get_install_dir())

if ff.get_id() == 'gcc'
  add_global_arguments(
    '-DCMPgcc',
    '-DANSI',
    language:['c','fortran']
    )
  add_project_arguments(
      '-cpp',
      language: 'fortran',
    )

  if is_windows
    add_global_arguments(
      '-DWINDOWS',
      # '-DMS_WIN64',
      language:['c','fortran']
    )
  else
    # TODO: Add elif for Intel Compilers, and Mac
    add_global_arguments(
      '-Dunix',
      language:['c','fortran']
    )

  endif
endif

# src_prefix = '../../'
src_prefix = ''

# f90_gen = generator(
#   py3,
#   output: '@BASENAME@.F90',
#   arguments: [meson.project_source_root() / '_build_utils/convert_f77.py','@INPUT@', '@OUTPUT@', '@OUTDIR@']
# )

#### Set FVS Git version variables ####
# Ported from core fvs CMakeLists.txt 10/5/2026
git = find_program('git', required : false)

fvs_root = meson.current_source_dir() + '\\fvs'
message('FVS Root:  @0@'.format(fvs_root))

# Assumes fvs_root is defined earlier (e.g., fvs_root = meson.current_source_dir() or a custom path)
fvs_git_remote = 'unknown'
fvs_git_org = 'unknown'
fvs_git_version = 'unknown'
fvs_git_hash = 'unknown'
fvs_git_date = 'unknown'
fvs_git_branch = 'unknown'

if git.found()
  # 1. Get remote URL
  res = run_command(git, '-C', fvs_root, 'remote', 'get-url', 'origin', check : false)
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_remote = res.stdout().strip()
  endif

  # Equivalent to CMake's REGEX REPLACE for extracting organization name
  if fvs_git_remote != 'unknown'
    url = fvs_git_remote
    if url.endswith('.git')
      url = url.substring(0, -4)
    endif
    
    parts = url.split('/')
    if parts.length() >= 2
      fvs_git_org = parts[parts.length() - 2]
    else
      colon_parts = url.split(':')
      if colon_parts.length() > 1
        subparts = colon_parts[1].split('/')
        if subparts.length() >= 2
          fvs_git_org = subparts[subparts.length() - 2]
        endif
      endif
    endif
  endif
  if fvs_git_org == ''
    fvs_git_org = 'unknown'
  endif

  # 2. Get version (tags exact match, with fallback to latest tag)
  res = run_command(git, '-C', fvs_root, 'describe', '--tags', '--exact-match', check : false)
  if res.returncode() != 0 or res.stdout().strip() == ''
    res = run_command(git, '-C', fvs_root, 'describe', '--tags', check : false)
  endif
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_version = res.stdout().strip()
  endif

  # 3. Get short commit hash
  res = run_command(git, '-C', fvs_root, 'rev-parse', '--short', 'HEAD', check : false)
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_hash = res.stdout().strip()
  endif

  # 4. Get commit date (YYYYMMDD)
  res = run_command(git, '-C', fvs_root, 'log', '-1', '--format=%cd', '--date=format:%Y%m%d', check : false)
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_date = res.stdout().strip()
  endif

  # 5. Get current branch name
  res = run_command(git, '-C', fvs_root, 'rev-parse', '--abbrev-ref', 'HEAD', check : false)
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_branch = res.stdout().strip()
  endif

  # 6. Check for uncommitted changes (dirty state)
  res = run_command(git, '-C', fvs_root, 'status', '--porcelain', check : false)
  if res.returncode() == 0 and res.stdout().strip() != ''
    fvs_git_version += '-dirty'
    fvs_git_hash += '-dirty'
    warning('WARNING: working tree has uncommitted changes.')
    warning('WARNING: Version will be marked -dirty.')
    warning('WARNING: Do not use this build in production or deliverable contexts.')
  endif
endif

message('FVS_GIT_REMOTE:  @0@'.format(fvs_git_remote))
message('FVS_GIT_ORG:     @0@'.format(fvs_git_org))
message('FVS_GIT_VERSION: @0@'.format(fvs_git_version))
message('FVS_GIT_HASH:    @0@'.format(fvs_git_hash))
message('FVS_GIT_DATE:    @0@'.format(fvs_git_date))
message('FVS_GIT_BRANCH:  @0@'.format(fvs_git_branch))

#### End Git Version Info ####

compiler_args = [
  '-DFVS_GIT_ORG="@0@"'.format(fvs_git_org),
  '-DFVS_GIT_VERSION="@0@"'.format(fvs_git_version),
  '-DFVS_GIT_HASH="@0@"'.format(fvs_git_hash),
  '-DFVS_GIT_DATE="@0@"'.format(fvs_git_date),
  '-DFVS_GIT_BRANCH="@0@"'.format(fvs_git_branch),
  '-DFVS_GIT_REMOTE="@0@"'.format(fvs_git_remote),
]

############## From scipy/meson.build subdir ###################
# Platform detection
is_mingw = is_windows and cc.get_id() == 'gcc'

cython_c_args = []
if is_windows
  # For mingw-w64, link statically against the UCRT.
  #gcc_link_args = ['-lucrt', '-static', '-lquadmath']
  gcc_link_args = ['-static', '-lquadmath']
  if is_mingw
    add_project_link_arguments(gcc_link_args, language: ['c', 'cpp'])
    # Force gcc to float64 long doubles for compatibility with MSVC
    # builds, for C only.
    add_project_arguments('-mlong-double-64', language: 'c')
    # Make fprintf("%zd") work (see https://github.com/rgommers/scipy/issues/118)
    add_project_arguments('-D__USE_MINGW_ANSI_STDIO=1', language: ['c', 'cpp'])

    # Manual add of MS_WIN64 macro when not using MSVC.
    # https://bugs.python.org/issue28267
    # NOTE: gcc -v reports to stderr not stdout
    target = run_command('gcc','-v', check:true).stderr().strip().to_lower()
    if target.contains('target: x86_64')
      message('*** Add MS_WIN64 compiler flag')
      add_project_arguments('-DMS_WIN64', language: ['c', 'cpp', 'fortran'])
    endif

    # Silence warnings emitted by PyOS_snprintf for (%zd), see
    # https://github.com/rgommers/scipy/issues/118.
    # Use as c_args for extensions containing Cython code
    cython_c_args += ['-Wno-format-extra-args', '-Wno-format']
  endif
  if meson.get_compiler('fortran').get_id() == 'gcc'
    add_project_link_arguments(gcc_link_args, language: ['fortran'])
    # Flag needed to work around BLAS and LAPACK Gfortran dependence on
    # undocumented C feature when passing single character string
    # arguments.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=90329
    # https://github.com/wch/r-source/blob/838f9d5a7be08f2a8c08e47bcd28756f5d0aac90/src/gnuwin32/MkRules.rules#L121
    add_project_arguments('-fno-optimize-sibling-calls', language: ['fortran'])
  endif
endif

# add_project_arguments('-fno-second-underscore', language:'fortran')
if is_windows
  add_project_link_arguments('-Wl,--add-stdcall-alias', language:['c','fortran'])
endif

thread_dep = dependency('threads', required: false)

# NumPy include directory - needed in all submodules
incdir_numpy = run_command(py3,
  [
    '-c',
    'import os; import numpy; os.chdir(".."); print(os.path.abspath(numpy.get_include()))'
  ],
  check: true
).stdout().strip()
message('Numpy Include: ' + incdir_numpy)

inc_np = include_directories(fs.relative_to(incdir_numpy, meson.current_source_dir()))

incdir_f2py = run_command(py3,
    ['-c', 'import os; import numpy.f2py; print(os.path.abspath(numpy.f2py.get_include()))'],
    check : true
).stdout().strip()
message('F2PY Include: ' + incdir_f2py)
inc_f2py = include_directories(fs.relative_to(incdir_f2py, meson.current_source_dir()))
fortranobject_c = incdir_f2py / 'fortranobject.c'

cc = meson.get_compiler('c')
npymath_path = incdir_numpy / '..' / 'lib'
npymath_lib = cc.find_library('npymath', dirs: npymath_path)
npyrandom_path = incdir_numpy / '..' / '..' / 'random' / 'lib'
# Note: `required: false` can be removed once numpy 1.19 is the minimum version
npyrandom_lib = cc.find_library('npyrandom', dirs: npyrandom_path, required: false)

numpy_nodepr_api = '-DNPY_NO_DEPRECATED_API=NPY_1_9_API_VERSION'

# Share this object across multiple modules.
fortranobject_lib = static_library('_fortranobject',
  fortranobject_c,
  c_args: numpy_nodepr_api,
  dependencies: py3_dep,
  include_directories: [inc_np, inc_f2py],
  )
fortranobject_dep = declare_dependency(
  link_with: fortranobject_lib,
  include_directories: [inc_np, inc_f2py],
  )


# Fortran warning flags
_fflag_Wno_argument_mismatch = ff.get_supported_arguments('-Wno-argument-mismatch')
_fflag_Wno_conversion = ff.get_supported_arguments('-Wno-conversion')
_fflag_Wno_intrinsic_shadow = ff.get_supported_arguments('-Wno-intrinsic-shadow')
_fflag_Wno_maybe_uninitialized = ff.get_supported_arguments('-Wno-maybe-uninitialized')
_fflag_Wno_surprising = ff.get_supported_arguments('-Wno-surprising')
_fflag_Wno_uninitialized = ff.get_supported_arguments('-Wno-uninitialized')
_fflag_Wno_unused_dummy_argument = ff.get_supported_arguments('-Wno-unused-dummy-argument')
_fflag_Wno_unused_label = ff.get_supported_arguments('-Wno-unused-label')
_fflag_Wno_unused_variable = ff.get_supported_arguments('-Wno-unused-variable')
_fflag_Wno_tabs = ff.get_supported_arguments('-Wno-tabs')
# The default list of warnings to ignore from Fortran code. There is a lot of
# old, vendored code that is very bad and we want to compile it silently (at
# least with GCC and Clang)
fortran_ignore_warnings = ff.get_supported_arguments(
  _fflag_Wno_argument_mismatch,
  _fflag_Wno_conversion,
  _fflag_Wno_maybe_uninitialized,
  _fflag_Wno_unused_dummy_argument,
  _fflag_Wno_unused_label,
  _fflag_Wno_unused_variable,
  _fflag_Wno_tabs,
  )

###########################################################
###########################################################
###########################################################

message('*************** Prepare Variant Builds **************')
message(project_folder)

foreach variant : variants
  # Read the list of source code files
  source_fn = project_folder / 'fvs/bin/FVS@0@_sourceList.txt'.format(variant)
  source_files = run_command('python', '-c',
    '[print(line, end="") for line in open("@0@")]'.format(source_fn)
    , check:true
    ).stdout().strip()
  source_files = source_files.split('\n')

  # # Generate the F90 include files
  # ## TODO: This should be re-run as a dependency
  # run_command(
  #   py3,
  #   '_build_utils\convert_f77.py',
  #   source_fn,
  #   'api\gen\@0@\include'.format(variant),
  #   )

  # Compiler arguments, preprocessor directives, per variant
  variant_args = []

  # Split source files into C and Fortran sources
  c_sources = []
  cpp_sources = []
  f_sources = []
  for_sources = []
  f90_sources = []

  h_include_dirs = []
  f77_include_dirs = []
  f77_include_files = []
  f90_include_files = [] # Include files transformed from F77 to F90, available to included in globals.f90
  inc_include_dirs = []
  f90_inc_dirs = []

  #skip_sources = ['main.f','apisubsc.c']
  skip_sources = ['main.f',]
  skip_funcs = [
    'fvsTreeAttrC', 'fvsSpeciesAttrC', 'fvsEvmonAttrC',
    'fvsSpeciesCodeC', 'fvsCloseFileC', 'fvsSVSObjDataC',
    'fvsFFEAttrsC', 'fvsUnitConversionC',
    #'fvsgetversion', 'fvsgetbuildinfo'
  ]

  api_sources = []
  api_names = [
    'fvs.f',
    # 'apisubs.f',
    'htcalc.f',
    'cmdline.f',
    'forkod.f',
    'revise.f',
    'keywds.f',
    'esblkd.f',
    'blkdat.f',
    'fmcblk.f',
    #'version.f90'
    ]

  # src_root = project_folder / 'fvs'
  foreach f : source_files
    # f = src_root/f.replace('../', '')
    f = f.replace('../', 'fvs/')
    d = fs.parent(f)

    if fs.name(f) in skip_sources
      continue
    endif

    if fs.name(f) in api_names
      api_sources += f
    endif

    if f.to_lower().endswith('.c')
      c_sources += f
    elif f.to_lower().endswith('.cpp')
      cpp_sources += f
    elif f.to_lower().endswith('.f')
      f_sources += f
    elif f.to_lower().endswith('.for')
      for_sources += f
    elif f.to_lower().endswith('.f90')
      f90_sources += f
      # ## FIXME: generated F90 files should be included as a generator
      # if d not in f90_inc_dirs
      #   f90_inc_dirs += d
      # endif

    # Include folders
    elif f.to_lower().endswith('.f77')
      f77_include_files += f
      if d not in f77_include_dirs
        f77_include_dirs += d
      endif
    elif f.to_lower().endswith('.inc')
      if d not in inc_include_dirs
        inc_include_dirs += d
      endif
    elif f.to_lower().endswith('.h')
      if d not in h_include_dirs
        h_include_dirs += d
      endif

    endif
  endforeach

  #####################

  convert_f77 = files('_build_utils/convert_f77.py')
  foreach src: f77_include_files
    configure_file(
      input: src,
      output: variant + '_@BASENAME@.F90'.format(src),
      command: [py3, convert_f77, '@INPUT@', '@OUTPUT@'],
    )
  endforeach

  # FIXME: Need to capture the output folder of generated source files
  #        Can't foreach the generator output list
  # Translate F77 to F90 includes for use in globals.f90
  # f90_include_files = f90_gen.process(
  #   f77_include_files
  #   , preserve_path_from : meson.current_source_dir()
  # )

  # # Declare f90_include_files dependencies
  # f90_gen_files = declare_dependency(
  #   sources: f90_include_files
  # )

  # foreach f77: f77_include_files
  #   f90 = f90_gen.process(f77)
  #   d = fs.parent(f90)
  #   if d not in f90_include_dirs
  #     f90_include_dirs += d
  #   endif
  # endforeach

  # Add variant specific wrappers
  if variant in ['pn','wc']

    variant_args += '-DFVS_MORTS_WRAP'

    # Add the wrappers to the file lists
    f_sources += 'src/api/variant/@0@/morts_fvs.f'.format(variant)
    f90_sources += 'src/api/morts_wrap.f90'

  endif

  #####################

  conf_data = configuration_data()
  conf_data.set('variant', variant)
  configure_file(
    input: 'src/api/globals.f90.in',
    output: variant + '_globals.f90',
    configuration: conf_data
  )

  # f90_sources += variant + '_globals.f90'
  f90_sources += join_paths(meson.project_build_root(), variant + '_globals.f90')

  # Additional API files to compile
  # f90_sources += 'src/api/apisubs.f90'

  #f90_sources += 'src/api/version.f90'
  f90_sources += 'src/api/fvs_api.f90'
  # f90_sources += 'src/api/sim_monitor.f90'
  # f90_sources += 'src/api/initialize.f90'
  f90_sources += 'src/api/inventory_trees.f90'
  f90_sources += 'src/api/fvs_step.f90'
  f90_sources += 'src/api/tree_data.f90'
  f90_sources += 'src/api/snag_data.f90'
  f90_sources += 'src/api/carbon_data.f90'
  f90_sources += 'src/api/downwood_data.f90'
  # f90_sources += 'src/api/step_tregro.f90'
  f90_sources += 'src/api/prtrls_wrap.f90'
  # f90_sources += 'src/api/stop_wrap.f90'
  # f90_sources += 'src/api/foo.f90'
  # f90_sources += 'src/api/test.f90'

  # ## TODO: Auto-generate F90 includes from F77
  # f90_inc_dirs += 'src/api/gen/@0@/include'.format(variant)

  # # Add the include folders as a dependency to trigger
  # inc_dep = declare_dependency(
  #   include_directories: f90_inc_dirs + f77_include_dirs
  # )

  #####################

  # Wrap API files with F2PY
  api_sources += f90_sources

  # Set expected F2PY output module file names
  lib_name = 'fvs@0@'.format(variant)
  mod_c_wrap = '@0@module.c'.format(lib_name)
  mod_f_wrap = '@0@-f2pywrappers.f'.format(lib_name)
  mod_f90_wrap = '@0@-f2pywrappers2.f90'.format(lib_name)

  # F2PY command executes one level deeper, so change the include paths
  f2py_inc_dirs = []
  basedir = meson.current_source_dir()
  foreach d : f77_include_dirs #+ f90_inc_dirs
    if d.startswith('api')
      d = project_folder / d
    elif d.startswith('fvs')
      d = project_folder / d
    endif
    f2py_inc_dirs += d
  endforeach

  f2py_inc_dirs += get_option('prefix') / get_option('localstatedir')
  # f2py_inc_dirs = include_directories(f77_include_dirs)

  f2py_path_sep = ':'
  if is_windows
    f2py_path_sep = ';'
  endif

  # Generate the PYF signature file
  f2py_pyf_pre = '@0@_pre.pyf'.format(lib_name)
  skip_funcs = ' '.join(skip_funcs)
  cmd = [
    py3.full_path(), '-m', 'numpy.f2py',
    '-m', lib_name,
    '-h', f2py_pyf_pre,
    '--overwrite-signature',
    '--lower',
    # '--no-wrap-modules',
    # '--f2cmap',
    # '--include-paths', f2py_path_sep.join(f2py_inc_dirs),
    '@INPUT@',
    f'skip: @skip_funcs@ :'
    # 'only: init_tree_data fvs_init fvs_grow fvs_end :'
  ]

  # Call the F2PY command and collect the PYF
  f2py_pyf_gen = custom_target(
    f2py_pyf_pre,
    input : api_sources + f90_include_files + f77_include_files,
    output : [f2py_pyf_pre],
    # depend_files : [f77_include_files,],
    command : cmd,
    install : false
    )
  f2py_pyf_name = '@0@.pyf'.format(lib_name)

  # 1) Post-process the PYF to strip common blocks
  # 2) Patch the PYF with the manual wrappers
  #    Manually wrapped functions need to be excluded from the automated PYF generation
  strip_common = files('_build_utils/strip_common.py')
  wrapper_pyf = files('src/pyfvs/wrapper.pyf')
  f2py_pyf_strip = custom_target(
    'strip_common_'+variant,
    input: f2py_pyf_gen[0],
    output: [f2py_pyf_name],
    command: [
      py3,
      strip_common, # script
      f2py_pyf_gen[0], # input file
      f2py_pyf_name, # output file
      wrapper_pyf # wrapper patch
      ]
    )

  # Generate the F2PY wrappers
  cmd = [
      py3.full_path(), '-m', 'numpy.f2py',
      # '-m', lib_name,
      # '--include-paths', f2py_path_sep.join(f2py_inc_dirs),
      '@INPUT@',
      ]

  # message(' '.join(cmd))

  # Call the F2PY command and collect outputs
  f2py_source = custom_target(
    mod_c_wrap,
    # input : 'build/cp310/fvspn.pyf',
    # input : api_sources + f90_include_files + f77_include_files,
    input : f2py_pyf_strip[0],
    output : [mod_c_wrap, mod_f_wrap, mod_f90_wrap],
    # output : [mod_c_wrap, mod_f90_wrap],
    depend_files : [f77_include_files,],
    command : cmd,
    install : false
    )

  fvs_include_dirs = include_directories(h_include_dirs + f77_include_dirs + inc_include_dirs + f90_inc_dirs)

  # Link object files into a shared library
  fvs_static_lib = static_library(
    lib_name,
    c_sources + cpp_sources + f_sources + for_sources + f90_sources,
    # dependencies: f90_gen_files,
    include_directories : fvs_include_dirs,
    c_args : variant_args + compiler_args,
    fortran_args : variant_args + compiler_args,
    install : false,
    )

  # f90_inc_dep = declare_dependency(
  #   sources: [f90_include_files, f77_include_files]
  #   # link_with: [fvs_static_lib, f2py_source]
  # )

  fvs_py_extension = py3.extension_module(
    lib_name,
    f2py_source,
    incdir_f2py+'/fortranobject.c',
    link_with: fvs_static_lib,
    include_directories: [inc_np, inc_f2py],
    dependencies: [py3_dep, fortranobject_dep],
    link_language: 'fortran',
    c_args : [numpy_nodepr_api,] + sqlite_c_args,
    fortran_args : fortran_ignore_warnings,
    install : true,
    # install_dir : 'pyfvs',
    subdir: 'pyfvs'
    )

  # Store the variant library name
  variant_libs = variant_libs + {variant:lib_name}

# End variant loop
endforeach

subdir('src/pyfvs')
