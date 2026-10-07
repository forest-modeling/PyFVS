def strip_common(path, outpath):
  """Strip common blocks from F2PY signature files."""
  with open(path, 'r') as f:
    lines = f.readlines()
  
  new_lines = []
  in_common = False
  for line in lines:
    _line = line.lower().strip()
    if _line.startswith('common'):
      in_common = True
      continue

    if in_common:
      if _line[0] == '&':
        continue
      else:
        in_common = False
    
    # ## Fix callback signature
    # if (
    #   _line.startswith('subroutine fvs_init') or 
    #   _line.startswith('subroutine fvs_grow')
    #   ):
    #   line = line.replace('irtncd', 'irtncd,grow_callback')

    new_lines.append(line)

  # for i,line in enumerate(new_lines):
  #   _line = line.strip()
  #   if _line.startswith('subroutine fvs('):
  #     new_lines[i+1] = '            integer intent(out) :: irtncd\n'

  with open(outpath, 'w') as f:
    f.writelines(new_lines)

def patch_pyf(path, outpath, wrapper):
  """Apply the manual wrappers.pyf to the auto-generated pyf"""
  with open(path, 'r') as f:
      pyf_lines = f.readlines()

  with open(wrapper, 'r') as f:
      wrapper_lines = f.readlines()

  # Extract the wrapper blocks
  blocks = {}
  block_key = None
  for line in wrapper_lines:
    code = line.split('!')[0].strip()
    if code.startswith('module'):
      block_key = code
      blocks[block_key] = [line,]

    elif code.startswith('end module'):
      blocks[block_key].append(line)
      block_key = None

    elif not block_key is None:
      blocks[block_key].append(line)

  for key,block in blocks.items():
    # print(key)
    i = -1
    j = -1
    for l, line in enumerate(pyf_lines):
      code = line.split('!')[0].strip()
      if code==key:
        i = l
      if i>=0 and code.startswith('end module'):
        j = l+1
        break

    # print(i,j)
    if i>=0 and j>0:
      # print('replace',i,j)
      pyf_lines[i:j] = block

  with open(outpath, 'w') as f:
    f.writelines(pyf_lines)

if __name__ == "__main__":
  import sys
  if len(sys.argv) != 4:
    print("Usage: python strip_common.py <path_to_pyf> <output_pyf> <wrapper_pyf>")
    sys.exit(1)
  
  strip_common(sys.argv[1], sys.argv[2])
  # input and output are now the same file
  patch_pyf(sys.argv[2], sys.argv[2], sys.argv[3])