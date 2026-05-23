# Generate the variants file
conf_data = configuration_data()

pyfvs_install_dir = py3.get_install_dir() / 'pyfvs'

# stringify the variant library dictionary
libs_str = '{'
foreach k,v : variant_libs
  libs_str += '"' + k.to_upper() + '":"' + v + '",'
endforeach
libs_str += '}'

conf_data.set('VARIANT_LIBS', libs_str)
configure_file(
  input: 'variants.py.in',
  output: 'variants.py',
  configuration: conf_data,
  install: true,
  install_dir: pyfvs_install_dir
)

python_sources = [
  '__init__.py',
  '__main__.py',
  # '_version.py',
  'fvs.py',
]

py3.install_sources(
  python_sources,
  subdir: 'pyfvs'
)

install_subdir(
  'keywords',
  install_dir: pyfvs_install_dir,
  exclude_directories : ['__pycache__']
  )

install_data(
  'config_default.yaml',
  install_dir: pyfvs_install_dir,
)

## FIXME: Filter out all the extraneous files
# exclude_files = run_command(py3,'-c', 'import os.path as pth,glob;f=glob.glob("../../tests");print(";".join([pth.basename(p) for p in f if pth.isfile(p) and not pth.splitext(p)[-1] in (".py",".ini")]))').stdout().strip().split(';')
# exclude_dirs = run_command(py3,'-c', 'import os.path as pth,glob;f=glob.glob("../../tests/*");print(";".join([pth.basename(p) for p in f if pth.isdir(p) and not pth.splitext(p)[-1] in ("rmrs","reg_test")]))').stdout().strip().split(';')
# exclude_files += '.pytest_cache' # Because Python interprets this dir as a file???

# message('Exclude Files')
# message(exclude_files)

## TODO: Install FVS FMSC tests

# install_subdir(
#   'test',
#   install_dir: pyfvs_install_dir,
#   # exclude_files: exclude_files,
#   exclude_directories : ['__pycache__','.pytest_cache','notebooks'], #,'reg_test','fia_test','api_test']
#   # exclude_directories: exclude_dirs,
#   )
