python_sources = [
  '__init__.py',
  '__main__.py',
  '_version.py',
  'fvs.py',
]

py3.install_sources(
  python_sources,
  subdir: 'pyfvs'
)

install_subdir('test', install_dir: py.get_install_dir() / 'pyfvs/tests')
