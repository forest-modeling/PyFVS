"""
Convert F77 fixed-form include files to F90 free-form
"""

import sys
import re

def convert(input, output):
  src = open(input).readlines()

  # Strip newlines and trailing whitespace
  src = [l.rstrip() for l in src]

  for i in range(len(src)):
    if src[i][0].lower()=='c':
      src[i] = '!' + src[i]

    if src[i][0]=='*':
      src[i] = '!' + src[i]

    # Replace F77 line continuations
    if len(src[i])>6 and src[i][5]=='&':
      # Strip the continuation character
      src[i] = '      ' + src[i][6:]
      # Continuation goes at the end of the previous line
      src[i-1] = src[i-1] + ' &'

  # Add back the newlines
  src = [l + '\n' for l in src]

  with open(output, 'w') as f:
    f.writelines(src)

if __name__=='__main__':
  convert(sys.argv[1], sys.argv[2])
