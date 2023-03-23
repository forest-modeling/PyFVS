"""
Generate the globals.f90 module from F77 include files
"""

import os
import sys
import re

def f77_to_f90(source):
  """
  Return f90 compatible code from a legacy fixed-format F77 file
  """
  # print('*****', input, output, outdir)
  src = open(source).readlines()

  # Strip newlines and trailing whitespace
  src = [l.rstrip() for l in src]

  for i in range(len(src)):
    if not src[i].strip():
      continue

    if src[i][0].lower()=='c':
      src[i] = '!' + src[i]

    if src[i][0]=='*':
      src[i] = '!' + src[i]

    # Replace F77 line continuations
    if len(src[i])>=6 and src[i][5] in ('&','>'):
      if len(src[i][6:].strip())>0:
        # Strip the continuation character
        src[i] = '      ' + src[i][6:]
        # Continuation goes at the end of the previous line
        src[i-1] = src[i-1] + ' &'
      else:
        src[i] = ''

  # Add back the newlines
  src = [l + '\n' for l in src]

  return src


def process_source(srclist, outfile):
  print(f'Process source list: {srclist}')
  src_files = [f.strip() for f in open(srclist).readlines()]
  f77_src = [f for f in src_files if f.endswith('.F77')]

  if not os.path.exists(outdir):
    os.makedirs(outdir)

  for fn in f77_src:
    inpath = os.path.abspath(os.path.dirname(srclist))
    inpath = f'{inpath}/{fn}'

    _ = os.path.split(fn)
    fn,ext = os.path.splitext(_[-1])
    outpath = f'{outdir}/{fn}.F90'
    print(inpath, outpath)
    convert(inpath, outpath)
