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

  with open(outpath, 'w') as f:
    f.writelines(new_lines)

if __name__ == "__main__":
  import sys
  if len(sys.argv) != 3:
    print("Usage: python strip_common.py <path_to_pyf> <output_pyf")
    sys.exit(1)
  
  strip_common(sys.argv[1], sys.argv[2])