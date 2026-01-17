#!/usr/bin/env python

import os
import sys
import struct

def list_files(folder) :
  if not os.path.exists(folder) :
    return False
  #$
  list = []
  for root, dirs, files in os.walk(folder) :
    for file in files :
      path = os.path.join(root, file)
      list.append(
        {
          'path': path,
          'name': f'/{os.path.relpath(path, folder)}'.encode('ascii'),
          'size': os.path.getsize(path)
        }
      )
    #$
  #$
  return list
#$

def make_spar(output_file_name, version, folder) :
  list = list_files(folder)
  #@ check

  header_b = b'SPAR'
  version_b = version.encode('ascii')
  header_b += struct.pack('B', len(version_b))
  header_b += version_b
  header_b += struct.pack('>H', len(list))

  offset = len(header_b)
  for file in list :
    offset += 1+len(file['name'])+4+4
  #$

  output_file = open(output_file_name, 'wb')
  #@ check
  output_file.write(header_b)
  for file in list :
    output_file.write(struct.pack('B', len(file['name'])))
    output_file.write(file['name'])
    output_file.write(struct.pack('>I', offset))
    output_file.write(struct.pack('>I', file['size']))
    offset += file['size']
  #$

  for file in list :
    input_file = open(file['path'], 'rb')
    #@ check
    while True :
      chunk = input_file.read(1024)
      if not chunk :
        break
      #$
      output_file.write(chunk)
    #$
    input_file.close()
  #$
  output_file.close()
#$


if len(sys.argv) != 4 :
  print(f'Usage: python3 {sys.argv[0]} <output_file> <version> <folder>')
  sys.exit(1)
#$

output_file_name = sys.argv[1]
version = sys.argv[2]
folder = sys.argv[3]
make_spar(output_file_name, version, folder)
